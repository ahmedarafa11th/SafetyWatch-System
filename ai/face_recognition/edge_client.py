import cv2
import time
import requests
import sqlite3
import threading
import os
from datetime import datetime, timedelta

# Configuration
RUNPOD_API_URL = os.environ.get("RUNPOD_API_URL", "http://localhost:8000/api/recognize")
LARAVEL_API_URL = os.environ.get("LARAVEL_API_URL", "http://127.0.0.1:8000")
LARAVEL_API_TOKEN = os.environ.get("LARAVEL_API_TOKEN", "your-admin-token")
CAMERA_INDEX = 0
CONFIDENCE_THRESHOLD = 0.65
SYNC_INTERVAL_SECONDS = 5

# Initialize local database for caching
def init_db():
    conn = sqlite3.connect('attendance_cache.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS pending_records
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  timestamp TEXT,
                  image_path TEXT)''')
    conn.commit()
    conn.close()

init_db()

def save_to_cache(image_path):
    conn = sqlite3.connect('attendance_cache.db')
    c = conn.cursor()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    c.execute("INSERT INTO pending_records (timestamp, image_path) VALUES (?, ?)", (timestamp, image_path))
    conn.commit()
    conn.close()
    print(f"📦 Cached record locally at {timestamp}")

def sync_worker():
    """Background thread to constantly try to send cached records to the Runpod server."""
    while True:
        try:
            conn = sqlite3.connect('attendance_cache.db')
            c = conn.cursor()
            c.execute("SELECT id, timestamp, image_path FROM pending_records LIMIT 5")
            records = c.fetchall()
            
            for record in records:
                rec_id, timestamp, img_path = record
                
                try:
                    with open(img_path, 'rb') as f:
                        files = {'file': (img_path, f, 'image/jpeg')}
                        response = requests.post(RUNPOD_API_URL, files=files, timeout=10)
                        
                    if response.status_code == 200:
                        data = response.json()
                        if data.get("recognized"):
                            print(f"✅ Synced: {data['name']} at {timestamp}")
                        else:
                            print(f"❌ Synced (Unknown Face) at {timestamp}")
                            
                        # If successful, delete from cache
                        c.execute("DELETE FROM pending_records WHERE id=?", (rec_id,))
                        conn.commit()
                        
                        # Notify Laravel Backend
                        if data.get("recognized"):
                            emp_code = data.get("employee_code")
                            try:
                                print(f"🚀 Forwarding to Laravel: {emp_code}")
                                headers = {
                                    "Authorization": f"Bearer {LARAVEL_API_TOKEN}",
                                    "Accept": "application/json"
                                }
                                requests.post(f"{LARAVEL_API_URL}/api/admin/attendance/log-via-face", json={
                                    "employee_code": emp_code,
                                    "action": "check_in" # Default action for edge cameras
                                }, headers=headers, timeout=5)
                            except requests.exceptions.RequestException as e:
                                print(f"⚠️ Failed to reach Laravel: {e}")
                        
                except requests.exceptions.RequestException as e:
                    print(f"⚠️ Network error, will retry later: {e}")
                    break # Stop processing this batch if network is down
                    
            conn.close()
        except Exception as e:
            print(f"Sync worker error: {e}")
            
        time.sleep(SYNC_INTERVAL_SECONDS)

def start_attendance_session(duration_hours=1):
    """Start the camera and log attendance for a specific duration."""
    # Use Haar Cascade for fast, lightweight local face detection
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    cap = cv2.VideoCapture(CAMERA_INDEX)
    
    end_time = datetime.now() + timedelta(hours=duration_hours)
    print(f"\n🎥 Starting Attendance Camera. Window closes at {end_time.strftime('%H:%M:%S')}\n")
    
    # Start the sync background thread
    sync_thread = threading.Thread(target=sync_worker, daemon=True)
    sync_thread.start()

    # Cooldown to prevent capturing the same person 50 times in a second
    last_capture_time = time.time()
    
    while datetime.now() < end_time:
        ret, frame = cap.read()
        if not ret:
            continue
            
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.3, 5)
        
        # If face detected and 3 seconds have passed since last capture
        if len(faces) > 0 and (time.time() - last_capture_time) > 3.0:
            # We don't do recognition locally, just save the frame and queue it
            img_filename = f"temp_face_{int(time.time())}.jpg"
            cv2.imwrite(img_filename, frame)
            save_to_cache(img_filename)
            last_capture_time = time.time()

            # Draw rectangle just for visual feedback locally
            for (x, y, w, h) in faces:
                cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)
                cv2.putText(frame, "Captured!", (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
                
        cv2.imshow('Attendance Edge Client', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    print("\n✅ Attendance window closed.")

if __name__ == "__main__":
    start_attendance_session(duration_hours=1)
