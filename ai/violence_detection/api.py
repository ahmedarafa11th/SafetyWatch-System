import os
import cv2
import time
import requests
import threading
import numpy as np
import tensorflow as tf
from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from tensorflow.keras.applications import VGG16
from tensorflow.keras.applications.vgg16 import preprocess_input

from configs.config import NUM_FRAMES, FRAME_HEIGHT, FRAME_WIDTH

app = FastAPI(title="SafetyWatch - Violence Detection API")

# Allow CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Configuration
# -----------------------------
RTSP_URL = os.environ.get("RTSP_URL", "tcp://4.tcp.ngrok.io:12345") # Fallback to example Ngrok
WEBHOOK_URL = os.environ.get("WEBHOOK_URL", "http://localhost:8000/api/ai/detection") # Laravel backend
API_TOKEN = os.environ.get("API_TOKEN", "super-secret-ai-token")
THRESHOLD = 0.70

# -----------------------------
# AI Models Loading
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

# -----------------------------
# RTSP Stream Processing
# -----------------------------
is_streaming = False
stream_thread = None

def trigger_webhook(score: float):
    """Send an alert to the Laravel backend."""
    try:
        payload = {
            "camera_id": 1, # Default camera ID to 1 for now
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
        print(f"🚨 Webhook fired! Status: {response.status_code}")
    except Exception as e:
        print(f"⚠️ Failed to send webhook: {e}")

def process_stream():
    global is_streaming
    print(f"📡 Connecting to stream: {RTSP_URL}")
    
    cap = cv2.VideoCapture(RTSP_URL)
    if not cap.isOpened():
        print("❌ Could not connect to the video stream.")
        is_streaming = False
        return

    frames_buffer = []
    
    while is_streaming:
        ret, frame = cap.read()
        if not ret:
            print("⚠️ Stream disconnected. Attempting to reconnect in 5s...")
            time.sleep(5)
            cap = cv2.VideoCapture(RTSP_URL)
            continue
            
        # Preprocess frame
        frame_resized = cv2.resize(frame, (FRAME_WIDTH, FRAME_HEIGHT))
        frame_rgb = cv2.cvtColor(frame_resized, cv2.COLOR_BGR2RGB)
        frames_buffer.append(frame_rgb)
        
        # Once we have exactly NUM_FRAMES (e.g. 25)
        if len(frames_buffer) == NUM_FRAMES:
            # Prepare batch for VGG16
            sequence = np.array(frames_buffer, dtype=np.float32)
            sequence_preprocessed = preprocess_input(sequence)
            
            # Extract features: Shape becomes (25, 7, 7, 512)
            features = feature_extractor.predict(sequence_preprocessed, verbose=0)
            
            # Add batch dimension: Shape (1, 25, 7, 7, 512)
            features_batch = np.expand_dims(features, axis=0)
            
            # Predict violence
            if violence_model is not None:
                prediction = violence_model.predict(features_batch, verbose=0)
                # Assuming index 1 is Violence, index 0 is NonViolence
                violence_score = float(prediction[0][1])
                
                print(f"🔍 Evaluated 25 frames. Violence Score: {violence_score:.2f}")
                
                if violence_score >= THRESHOLD:
                    print("⚠️ VIOLENCE DETECTED! Triggering webhook...")
                    trigger_webhook(violence_score)
                    
                    # Wait 5 seconds before capturing again to avoid spamming alerts
                    time.sleep(5)
            
            # Clear buffer to start collecting the next 25 frames
            # Or use a sliding window: frames_buffer = frames_buffer[5:]
            frames_buffer.clear()

    cap.release()
    print("🛑 Stream processing stopped.")

# -----------------------------
# Endpoints
# -----------------------------
@app.get("/")
def health_check():
    return {"status": "running", "streaming": is_streaming}

@app.post("/api/stream/start")
def start_stream(background_tasks: BackgroundTasks):
    global is_streaming, stream_thread
    if is_streaming:
        return {"status": "Stream already running."}
    
    is_streaming = True
    stream_thread = threading.Thread(target=process_stream, daemon=True)
    stream_thread.start()
    return {"status": "Stream started successfully."}

@app.post("/api/stream/stop")
def stop_stream():
    global is_streaming
    is_streaming = False
    return {"status": "Stream stopping..."}

if __name__ == "__main__":
    import uvicorn
    # Automatically start streaming on boot if needed
    is_streaming = True
    threading.Thread(target=process_stream, daemon=True).start()
    uvicorn.run(app, host="0.0.0.0", port=8001)
