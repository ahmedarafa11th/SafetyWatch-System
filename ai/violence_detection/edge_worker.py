import os
import cv2
import time
import requests
import threading
import numpy as np
import tensorflow as tf
from tensorflow.keras.applications import VGG16
from tensorflow.keras.applications.vgg16 import preprocess_input

from configs.config import NUM_FRAMES, FRAME_HEIGHT, FRAME_WIDTH

import json

# -----------------------------
# Configuration & Initialization
# -----------------------------
CONFIG_FILE = "edge_config.json"

def load_or_prompt_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
            
    print("\n" + "="*50)
    print("🚀 SafetyWatch Edge Node - First Time Setup")
    print("="*50)
    
    api_url = input("Enter Laravel API URL (e.g. https://141.144.238.112.nip.io): ").strip()
    api_token = input("Enter your Edge Activation Key (Admin Token): ").strip()
    
    config = {
        "LARAVEL_API_URL": api_url or "http://localhost:8000",
        "API_TOKEN": api_token,
        "THRESHOLD": 0.70
    }
    
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=4)
        
    print("\n✅ Configuration saved to edge_config.json!")
    return config

config_data = load_or_prompt_config()
LARAVEL_API_URL = config_data["LARAVEL_API_URL"]
WEBHOOK_URL = f"{LARAVEL_API_URL}/api/ai/detection"
API_TOKEN = config_data["API_TOKEN"]
THRESHOLD = config_data.get("THRESHOLD", 0.70)


# -----------------------------
# AI Models Loading (Thread Safe)
# -----------------------------
print("Loading VGG16 Feature Extractor...")
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

# Model inference lock for thread safety
model_lock = threading.Lock()

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
        print(f"🚨 Webhook fired for Camera {camera_id}! Status: {response.status_code}")
    except Exception as e:
        print(f"⚠️ Failed to send webhook for Camera {camera_id}: {e}")

def process_stream(camera_id: int, rtsp_url: str):
    print(f"📡 Camera {camera_id}: Connecting to stream: {rtsp_url}")
    
    cap = cv2.VideoCapture(rtsp_url)
    if not cap.isOpened():
        print(f"❌ Camera {camera_id}: Could not connect to the video stream.")
        active_streams[camera_id]["is_streaming"] = False
        return

    frames_buffer = []
    
    while active_streams.get(camera_id, {}).get("is_streaming", False):
        ret, frame = cap.read()
        if not ret:
            print(f"⚠️ Camera {camera_id}: Stream disconnected. Attempting to reconnect in 5s...")
            time.sleep(5)
            cap = cv2.VideoCapture(rtsp_url)
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
                
                print(f"🔍 Camera {camera_id} Evaluated 25 frames. Violence Score: {violence_score:.2f}")
                
                if violence_score >= THRESHOLD:
                    print(f"⚠️ Camera {camera_id}: VIOLENCE DETECTED! Triggering webhook...")
                    trigger_webhook(camera_id, violence_score)
                    time.sleep(5) # Wait 5 seconds to avoid spamming alerts
            
            frames_buffer.clear()

    cap.release()
    print(f"🛑 Camera {camera_id}: Stream processing stopped.")

def poll_backend_cameras():
    """Continuously poll Laravel for active cameras and manage threads."""
    print("🔄 Starting Edge Orchestrator Polling...")
    
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
                
                # Start new streams
                for cam in vd_cameras:
                    cam_id = cam["id"]
                    rtsp_url = cam.get("stream_url")
                    
                    if not rtsp_url:
                        continue
                        
                    if cam_id not in active_streams or not active_streams[cam_id]["is_streaming"]:
                        print(f"🚀 Starting stream thread for Camera {cam_id}")
                        active_streams[cam_id] = {"is_streaming": True}
                        t = threading.Thread(target=process_stream, args=(cam_id, rtsp_url), daemon=True)
                        active_streams[cam_id]["thread"] = t
                        t.start()
                
                # Stop removed or disabled streams
                for cam_id in list(active_streams.keys()):
                    if cam_id not in vd_camera_ids:
                        print(f"🛑 Stopping stream thread for Camera {cam_id} (No longer active or assigned)")
                        active_streams[cam_id]["is_streaming"] = False
                        # Thread will naturally die on next loop iteration
                        del active_streams[cam_id]
                        
            else:
                print(f"⚠️ Failed to fetch cameras from Laravel. Status: {response.status_code}")
                
        except Exception as e:
            print(f"⚠️ Edge Orchestrator polling error: {e}")
            
        time.sleep(30) # Poll every 30 seconds

if __name__ == "__main__":
    print("========================================")
    print("🛡️ SafetyWatch Edge Node Orchestrator 🛡️")
    print("========================================")
    
    # Start the polling thread
    poll_thread = threading.Thread(target=poll_backend_cameras, daemon=True)
    poll_thread.start()
    
    # Keep main thread alive
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down Edge Node Orchestrator...")
        for cam_id in active_streams:
            active_streams[cam_id]["is_streaming"] = False
        print("✅ Shutdown complete.")
