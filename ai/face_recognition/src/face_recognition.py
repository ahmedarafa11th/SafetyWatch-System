import os
import cv2
import torch
import pickle
import numpy as np
import csv
from datetime import datetime, timedelta
from facenet_pytorch import MTCNN, InceptionResnetV1
from win10toast import ToastNotifier

# -----------------------------
# Paths
# -----------------------------
new_people_path = "data/New_employees"
embedding_file = "embeddings.pkl"
csv_file = "results.csv"

# -----------------------------
# Device & Models
# -----------------------------
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
detector = MTCNN(keep_all=True, device=device)
model = InceptionResnetV1(pretrained='vggface2').eval().to(device)
notifier = ToastNotifier()

# -----------------------------
# Load or initialize embeddings
# -----------------------------
if os.path.exists(embedding_file):
    with open(embedding_file, 'rb') as f:
        known_embeddings, known_names = pickle.load(f)
    print(f"✅ Loaded {len(known_names)} embeddings from {embedding_file}")
else:
    known_embeddings, known_names = [], []
    print("No embeddings found, will generate new ones.")

# -----------------------------
# Cosine similarity
# -----------------------------
def cosine_similarity(a, b):
    return float(np.dot(a, b.T))

# -----------------------------
# Add a single person from folder
# -----------------------------
def add_new_person(name, images_folder):
    global known_embeddings, known_names
    if not os.path.exists(images_folder):
        print(f"❌ Folder {images_folder} not found.")
        return

    if name in known_names:
        print(f"ℹ️ Person '{name}' already exists, skipping...")
        return

    images = [img for img in os.listdir(images_folder)]
    print(f"\nAdding new person '{name}' with {len(images)} images.")

    for img_name in images:
        img_path = os.path.join(images_folder, img_name)
        img = cv2.imread(img_path)
        if img is None:
            print(f" ⚠️ Cannot read {img_name}, skipping")
            continue

        boxes, _ = detector.detect(img)
        if boxes is None or len(boxes) == 0:
            print(f" ⚠️ No face detected in {img_name}, skipping")
            continue

        x1, y1, x2, y2 = map(int, boxes[0])
        h, w, _ = img.shape
        x1, y1 = max(0, x1), max(0, y1)
        x2, y2 = min(w, x2), min(h, y2)
        if x2 <= x1 or y2 <= y1:
            print(f" ⚠️ Invalid bounding box in {img_name}, skipping")
            continue

        face = cv2.resize(img[y1:y2, x1:x2], (160, 160))
        face_rgb = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
        face_tensor = torch.tensor(face_rgb).permute(2,0,1).float().unsqueeze(0)/255.0

        with torch.no_grad():
            embedding = model(face_tensor.to(device)).cpu().numpy()
            embedding = embedding / np.linalg.norm(embedding)

        known_embeddings.append(embedding)
        known_names.append(name)
        print(f" ✅ Added image {img_name}")

    # Save embeddings
    with open(embedding_file, 'wb') as f:
        pickle.dump((known_embeddings, known_names), f)
    print(f"✅ Updated embeddings saved to {embedding_file}")

# -----------------------------
# Add all new people in folder
# -----------------------------
def add_all_new_people():
    if not os.path.exists(new_people_path):
        print(f"❌ New employees folder '{new_people_path}' not found.")
        return
    for person_name in os.listdir(new_people_path):
        person_folder = os.path.join(new_people_path, person_name)
        if os.path.isdir(person_folder):
            add_new_person(person_name, person_folder)

# -----------------------------
# Real-time camera recognition with single attendance record
# -----------------------------
def camera_recognition():
    if not known_embeddings:
        print("❌ No known embeddings. Add persons first.")
        return

    csv_exists = os.path.exists(csv_file)
    csv_handle = open(csv_file, mode='a', newline='', encoding='utf-8')
    csv_writer = csv.writer(csv_handle)
    if not csv_exists:
        csv_writer.writerow(["Timestamp", "Face_ID", "Name", "Similarity"])

    cap = cv2.VideoCapture(0)
    print("\n🎥 Starting camera recognition for 1 hour. Press 'q' to quit early.\n")
    face_id_counter = 1
    recorded_names = set()  # لحفظ أسماء الموظفين أو Unknown المسجلين

    end_time = datetime.now() + timedelta(hours=1)  # إغلاق الكاميرا بعد ساعة

    while True:
        ret, frame = cap.read()
        if not ret:
            continue

        boxes, _ = detector.detect(frame)
        if boxes is not None and len(boxes) > 0:
            for box in boxes:
                x1, y1, x2, y2 = map(int, box)
                h, w, _ = frame.shape
                x1, y1 = max(0, x1), max(0, y1)
                x2, y2 = min(w, x2), min(h, y2)
                if x2 <= x1 or y2 <= y1:
                    continue

                face = cv2.resize(frame[y1:y2, x1:x2], (160, 160))
                face_rgb = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
                face_tensor = torch.tensor(face_rgb).permute(2,0,1).float().unsqueeze(0)/255.0

                with torch.no_grad():
                    embedding = model(face_tensor.to(device)).cpu().numpy()
                    embedding = embedding / np.linalg.norm(embedding)

                if known_embeddings:
                    similarities = [cosine_similarity(embedding, e) for e in known_embeddings]
                    best_idx = int(np.argmax(similarities))
                    name = known_names[best_idx]
                    similarity_score = float(similarities[best_idx])
                else:
                    name = "Unknown"
                    similarity_score = 0.0

                if similarity_score < 0.6:
                    name = "Unknown"

                # اللون حسب نسبة التطابق
                if similarity_score >= 0.85:
                    color = (0, 200, 0)
                elif similarity_score >= 0.65:
                    color = (0, 200, 200)
                else:
                    color = (0, 0, 255)

                cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                cv2.putText(frame, f"{name} ({similarity_score:.2f})", (x1, y1-10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)

                # تسجيل الحضور مرة واحدة فقط لكل شخص أو Unknown
                if name not in recorded_names and (similarity_score >= 0.65 or name == "Unknown"):
                    csv_writer.writerow([datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                         face_id_counter, name, similarity_score])
                    face_id_counter += 1
                    recorded_names.add(name)
                    print(f"📝 Attendance recorded for {name} ({similarity_score:.2f})")

                    # إرسال Notification عند اكتشاف الوجه لأول مرة
                    notifier.show_toast("Face Detected", f"{name} detected ({similarity_score:.2f})",
                                        duration=5, threaded=True)

        cv2.imshow("Camera Recognition", frame)

        # إغلاق الكاميرا تلقائيًا بعد ساعة
        if datetime.now() >= end_time:
            print("\n⏱ 1 hour elapsed. Closing camera.")
            break

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    csv_handle.close()
    cv2.destroyAllWindows()
    print("\n✅ Camera recognition ended. Results saved to", csv_file)

# -----------------------------
# Main
# -----------------------------
if __name__ == "__main__":
    add_all_new_people()        # load all new employees
    camera_recognition()        # live camera recognition
