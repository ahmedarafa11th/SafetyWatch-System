import os
import io
import torch
import pickle
import numpy as np
import cv2
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from pydantic import BaseModel
from facenet_pytorch import MTCNN, InceptionResnetV1
from PIL import Image

app = FastAPI(title="SafetyWatch - Face Recognition API")

# Allow CORS for Laravel/Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Configuration & Models
# -----------------------------
EMBEDDING_FILE = "/workspace/embeddings.pkl" if os.environ.get("RUNPOD") else "embeddings.pkl"

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
detector = MTCNN(keep_all=True, device=device)
model = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# Load existing embeddings
known_embeddings = []
known_names = []

def load_embeddings():
    global known_embeddings, known_names
    if os.path.exists(EMBEDDING_FILE):
        with open(EMBEDDING_FILE, 'rb') as f:
            known_embeddings, known_names = pickle.load(f)
        print(f"✅ Loaded {len(known_names)} embeddings from {EMBEDDING_FILE}")
    else:
        known_embeddings, known_names = [], []
        print("No embeddings found, starting fresh.")

load_embeddings()

def save_embeddings():
    with open(EMBEDDING_FILE, 'wb') as f:
        pickle.dump((known_embeddings, known_names), f)

def cosine_similarity(a, b):
    return float(np.dot(a, b.T))

def extract_embedding(image_bytes: bytes):
    # Convert bytes to cv2 image
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        raise Exception("Invalid image data")

    boxes, _ = detector.detect(img)
    if boxes is None or len(boxes) == 0:
        raise Exception("No face detected")

    # Take the largest face if multiple
    x1, y1, x2, y2 = map(int, boxes[0])
    h, w, _ = img.shape
    x1, y1 = max(0, x1), max(0, y1)
    x2, y2 = min(w, x2), min(h, y2)
    if x2 <= x1 or y2 <= y1:
        raise Exception("Invalid bounding box")

    face = cv2.resize(img[y1:y2, x1:x2], (160, 160))
    face_rgb = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
    face_tensor = torch.tensor(face_rgb).permute(2,0,1).float().unsqueeze(0)/255.0

    with torch.no_grad():
        embedding = model(face_tensor.to(device)).cpu().numpy()
        embedding = embedding / np.linalg.norm(embedding)

    return embedding

# -----------------------------
# Endpoints
# -----------------------------

@app.get("/api/debug")
def get_debug():
    return {"names": known_names}

@app.post("/api/register")
async def register_employee(
    name: str = Form(...),
    employee_code: str = Form(...),
    photo_front: UploadFile = File(...),
    photo_left: UploadFile = File(None),
    photo_right: UploadFile = File(None)
):
    """
    Register a new employee with up to 3 photos for higher accuracy.
    """
    global known_embeddings, known_names
    
    unique_identifier = f"{employee_code}_{name}"
    
    # Process multiple images to create multiple embedding vectors for the same person
    photos = [photo_front, photo_left, photo_right]
    added_count = 0
    
    for photo in photos:
        if photo is None:
            continue
            
        try:
            image_bytes = await photo.read()
            embedding = extract_embedding(image_bytes)
            known_embeddings.append(embedding)
            known_names.append(unique_identifier) # E.g., EMP-001_John
            added_count += 1
        except Exception as e:
            print(f"Warning: Failed to extract face from one of the photos: {e}")
            continue

    if added_count == 0:
        raise HTTPException(status_code=400, detail="Could not detect a face in any of the provided photos.")

    # Save to disk/volume
    save_embeddings()
    
    return {"status": "success", "message": f"Successfully registered {name} with {added_count} facial profiles."}

@app.post("/api/recognize")
async def recognize_face(file: UploadFile = File(...)):
    """
    Recognize a face from an uploaded frame. Returns the best match.
    """
    if not known_embeddings:
        raise HTTPException(status_code=400, detail="No embeddings found. Register employees first.")
        
    try:
        image_bytes = await file.read()
        embedding = extract_embedding(image_bytes)
    except Exception as e:
        return {"status": "error", "message": str(e), "recognized": False}

    # Find closest match
    similarities = [cosine_similarity(embedding, e) for e in known_embeddings]
    best_idx = int(np.argmax(similarities))
    similarity_score = float(similarities[best_idx])
    
    identifier = known_names[best_idx]
    
    if similarity_score >= 0.65:
        # Expected format: "EMP-001_John"
        parts = identifier.split('_', 1)
        employee_code = parts[0] if len(parts) > 1 else identifier
        name = parts[1] if len(parts) > 1 else identifier
        
        return {
            "status": "success",
            "recognized": True,
            "employee_code": employee_code,
            "name": name,
            "similarity": similarity_score
        }
    else:
        return {
            "status": "success",
            "recognized": False,
            "name": "Unknown",
            "similarity": similarity_score
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
