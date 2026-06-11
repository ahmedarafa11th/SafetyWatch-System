import os
import cv2
import time
import json
import requests
import threading
import numpy as np
import tensorflow as tf
from tensorflow.keras.applications import VGG16
from tensorflow.keras.applications.vgg16 import preprocess_input

from configs.config import NUM_FRAMES, FRAME_HEIGHT, FRAME_WIDTH

# -----------------------------
# Configuration & Initialization
# -----------------------------
CONFIG_FILE = "edge_config.json"

def login_to_backend(api_url, email, password):
    """Authenticate with the Laravel backend using email/password and return a token."""
    try:
        response = requests.post(f"{api_url}/api/auth/login", json={
            "email": email,
            "password": password
        }, headers={"Accept": "application/json"}, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            token = data.get("data", {}).get("token") or data.get("token")
            if token:
                return token, None
            return None, "Login succeeded but no token was returned."
        elif response.status_code == 401 or response.status_code == 422:
            return None, "Invalid email or password. Please try again."
        else:
            return None, f"Server returned status {response.status_code}"
    except requests.exceptions.ConnectionError:
        return None, f"Cannot reach server at {api_url}. Check the address and try again."
    except Exception as e:
        return None, str(e)

def load_or_prompt_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            config = json.load(f)
            print(f"✅ Configuration loaded from {CONFIG_FILE}")
            return config
            
    print("\n" + "="*50)
    print("🚀 SafetyWatch Edge Node - First Time Setup")
    print("="*50)
    print("Enter your SafetyWatch admin credentials below.\n")
    
    api_url = input("Server Address (e.g. https://141.144.238.112.nip.io): ").strip().rstrip("/")
    if not api_url:
        api_url = "http://localhost:8000"
    
    # Login loop - keep asking until credentials are correct
    while True:
        email = input("Admin Email: ").strip()
        password = input("Password: ").strip()
        
        print("\n🔄 Logging in...")
        token, error = login_to_backend(api_url, email, password)
        
        if token:
            print("✅ Login successful!")
            break
        else:
            print(f"❌ {error}")
            print("Please try again.\n")
    
    config = {
        "LARAVEL_API_URL": api_url,
        "API_TOKEN": token,
        "email": email,
        "password": password,
        "THRESHOLD": 0.70
    }
    
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=4)
        
    print("✅ Configuration saved! You won't need to enter this again.\n")
    return config

config_data = load_or_prompt_config()
LARAVEL_API_URL = config_data["LARAVEL_API_URL"]
WEBHOOK_URL = f"{LARAVEL_API_URL}/api/ai/detection"
API_TOKEN = config_data["API_TOKEN"]
THRESHOLD = config_data.get("THRESHOLD", 0.70)

def auto_refresh_token():
    """Silently re-authenticate and update the global token when it expires."""
    global API_TOKEN, config_data
    email = config_data.get("email")
    password = config_data.get("password")
    
    if not email or not password:
        print("⚠️ No saved credentials found. Delete edge_config.json and re-run to re-login.")
        return False
    
    print("🔄 Token expired. Re-authenticating automatically...")
    token, error = login_to_backend(LARAVEL_API_URL, email, password)
    
    if token:
        API_TOKEN = token
        config_data["API_TOKEN"] = token
        with open(CONFIG_FILE, "w") as f:
            json.dump(config_data, f, indent=4)
        print("✅ Token refreshed successfully!")
        return True
    else:
        print(f"❌ Auto-refresh failed: {error}")
        return False

# Frame skipping: only process every Nth frame to avoid GPU bottleneck
# with multiple cameras. Higher = less GPU load, slightly slower detection.
FRAME_SKIP = 3

# -----------------------------
# Startup Validation
# -----------------------------
def validate_connection():
    """Verify the backend is reachable and the token is valid before starting."""
    print("\n🔍 Validating connection to backend...")
    try:
        headers = {
            "Authorization": f"Bearer {API_TOKEN}",
            "Accept": "application/json"
        }
        response = requests.get(f"{LARAVEL_API_URL}/api/ai/cameras", headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            cameras = data.get("data", {}).get("cameras", [])
            print(f"✅ Connected to backend successfully! Found {len(cameras)} active camera(s).")
            return True
        elif response.status_code == 401:
            print("❌ ERROR: Invalid or expired Edge Activation Key (Token).")
            print("   Please delete edge_config.json and re-run the script to enter a new token.")
            return False
        else:
            print(f"❌ ERROR: Backend returned status {response.status_code}")
            print(f"   URL: {LARAVEL_API_URL}/api/ai/cameras")
            return False
    except requests.exceptions.ConnectionError:
        print(f"❌ ERROR: Cannot reach backend at {LARAVEL_API_URL}")
        print("   Make sure the server is running and the URL is correct.")
        return False
    except Exception as e:
        print(f"❌ ERROR: Unexpected error during validation: {e}")
        return False

# -----------------------------
# AI Models Loading (Thread Safe)
# -----------------------------
print("\nLoading VGG16 Feature Extractor...")
base_vgg16 = VGG16(weights="imagenet", include_top=False, input_shape=(FRAME_HEIGHT, FRAME_WIDTH, 3))
feature_extractor = tf.keras.Model(inputs=base_vgg16.input, outputs=base_vgg16.get_layer("block5_pool").output)

print("Loading Violence Detection Model...")
MODEL_PATH = "checkpoints/best_model.keras"
try:
    violence_model = tf.keras.models.load_model(MODEL_PATH, compile=False)
    print("✅ Model loaded successfully.")
except Exception as e:
    print(f"⚠️ Failed to load model from {MODEL_PATH}: {e}")
    violence_model = None

# Thread-safety locks
model_lock = threading.Lock()      # Protects GPU inference calls
streams_lock = threading.Lock()    # Protects the active_streams dictionary

# State
active_streams = {}  # { camera_id: {"thread": Thread, "is_streaming": True} }

def trigger_webhook(camera_id: int, score: float):
    """Send an alert to the Laravel backend."""
    try:
        payload = {
            "camera_id": camera_id,
            "detection_type": "violence",
            "is_threat": True,
            "confidence": float(score * 100),
            "processed_at": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        headers = {
            "Authorization": f"Bearer {API_TOKEN}",
            "Accept": "application/json"
        }
        response = requests.post(WEBHOOK_URL, json=payload, headers=headers, timeout=5)
        if response.status_code == 401:
            if auto_refresh_token():
                # Retry with the new token
                headers["Authorization"] = f"Bearer {API_TOKEN}"
                response = requests.post(WEBHOOK_URL, json=payload, headers=headers, timeout=5)
                print(f"🚨 Webhook fired for Camera {camera_id}! Status: {response.status_code}")
        else:
            print(f"🚨 Webhook fired for Camera {camera_id}! Status: {response.status_code}")
    except Exception as e:
        print(f"⚠️ Failed to send webhook for Camera {camera_id}: {e}")

def process_stream(camera_id: int, rtsp_url: str):
    print(f"📡 Camera {camera_id}: Connecting to stream: {rtsp_url}")
    
    cap = cv2.VideoCapture(rtsp_url)
    if not cap.isOpened():
        print(f"❌ Camera {camera_id}: Could not connect to the video stream.")
        with streams_lock:
            if camera_id in active_streams:
                active_streams[camera_id]["is_streaming"] = False
        return

    print(f"✅ Camera {camera_id}: Stream connected successfully!")
    frames_buffer = []
    frame_counter = 0
    
    while True:
        # Thread-safe check if we should still be streaming
        with streams_lock:
            if not active_streams.get(camera_id, {}).get("is_streaming", False):
                break
        
        ret, frame = cap.read()
        if not ret:
            print(f"⚠️ Camera {camera_id}: Stream disconnected. Attempting to reconnect in 5s...")
            cap.release()
            time.sleep(5)
            cap = cv2.VideoCapture(rtsp_url)
            if not cap.isOpened():
                print(f"❌ Camera {camera_id}: Reconnection failed. Will retry...")
            continue
        
        # Frame skipping: only process every Nth frame to reduce GPU load
        frame_counter += 1
        if frame_counter % FRAME_SKIP != 0:
            continue
            
        # Preprocess frame
        frame_resized = cv2.resize(frame, (FRAME_WIDTH, FRAME_HEIGHT))
        frame_rgb = cv2.cvtColor(frame_resized, cv2.COLOR_BGR2RGB)
        frames_buffer.append(frame_rgb)
        
        # Once we have exactly NUM_FRAMES (e.g. 25)
        if len(frames_buffer) == NUM_FRAMES:
            sequence = np.array(frames_buffer, dtype=np.float32)
            sequence_preprocessed = preprocess_input(sequence)
            
            if violence_model is not None:
                # Thread-safe inference
                with model_lock:
                    features = feature_extractor.predict(sequence_preprocessed, verbose=0)
                    features_batch = np.expand_dims(features, axis=0)
                    prediction = violence_model.predict(features_batch, verbose=0)
                
                violence_score = float(prediction[0][1])
                
                print(f"🔍 Camera {camera_id}: Evaluated {NUM_FRAMES} frames. Violence Score: {violence_score:.2f}")
                
                if violence_score >= THRESHOLD:
                    print(f"⚠️ Camera {camera_id}: VIOLENCE DETECTED! Triggering webhook...")
                    trigger_webhook(camera_id, violence_score)
                    time.sleep(5) # Wait 5 seconds to avoid spamming alerts
            
            frames_buffer.clear()

    cap.release()
    print(f"🛑 Camera {camera_id}: Stream processing stopped.")

def poll_backend_cameras():
    """Continuously poll Laravel for active cameras and manage threads."""
    print("🔄 Starting Edge Orchestrator Polling...\n")
    
    while True:
        try:
            headers = {
                "Authorization": f"Bearer {API_TOKEN}",
                "Accept": "application/json"
            }
            response = requests.get(f"{LARAVEL_API_URL}/api/ai/cameras", headers=headers, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                cameras = data.get("data", {}).get("cameras", [])
                
                # Filter for Violence Detection cameras (not entrance)
                vd_cameras = [c for c in cameras if not c.get("is_entrance", False)]
                vd_camera_ids = [c["id"] for c in vd_cameras]
                
                with streams_lock:
                    # Start new streams
                    for cam in vd_cameras:
                        cam_id = cam["id"]
                        rtsp_url = cam.get("stream_url")
                        
                        if not rtsp_url:
                            continue
                            
                        if cam_id not in active_streams or not active_streams[cam_id]["is_streaming"]:
                            print(f"🚀 Starting stream thread for Camera {cam_id}: {cam.get('name', 'Unknown')}")
                            active_streams[cam_id] = {"is_streaming": True}
                            t = threading.Thread(target=process_stream, args=(cam_id, rtsp_url), daemon=True)
                            active_streams[cam_id]["thread"] = t
                            t.start()
                    
                    # Stop removed or disabled streams
                    for cam_id in list(active_streams.keys()):
                        if cam_id not in vd_camera_ids:
                            print(f"🛑 Stopping stream thread for Camera {cam_id} (No longer active)")
                            active_streams[cam_id]["is_streaming"] = False
                            del active_streams[cam_id]

                with streams_lock:
                    active_count = sum(1 for s in active_streams.values() if s["is_streaming"])
                print(f"📊 Status: {active_count} camera(s) actively streaming | Next poll in 30s")
                            
            elif response.status_code == 401:
                if auto_refresh_token():
                    continue  # Immediately retry with fresh token
                else:
                    print("⚠️ Could not refresh token. Will retry in 30s.")
                
            else:
                print(f"⚠️ Failed to fetch cameras from Laravel. Status: {response.status_code}")
                
        except Exception as e:
            print(f"⚠️ Edge Orchestrator polling error: {e}")
            
        time.sleep(30) # Poll every 30 seconds

if __name__ == "__main__":
    print("="*50)
    print("🛡️  SafetyWatch Edge Node Orchestrator  🛡️")
    print("="*50)
    
    # Step 1: Validate connection before doing anything
    if not validate_connection():
        print("\n💡 Tip: Delete edge_config.json and re-run to reconfigure.")
        exit(1)
    
    # Step 2: Start the polling thread
    poll_thread = threading.Thread(target=poll_backend_cameras, daemon=True)
    poll_thread.start()
    
    # Keep main thread alive
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down Edge Node Orchestrator...")
        with streams_lock:
            for cam_id in active_streams:
                active_streams[cam_id]["is_streaming"] = False
        time.sleep(2) # Give threads time to clean up
        print("✅ Shutdown complete.")
