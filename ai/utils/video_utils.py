"""
Video utilities for scanning, validation, and frame extraction.
"""

import os
import cv2
import numpy as np
from tqdm import tqdm

import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from configs.config import (
    SUPPORTED_VIDEO_FORMATS,
    NUM_FRAMES,
    FRAME_HEIGHT,
    FRAME_WIDTH,
)


def scan_videos(directory, supported_formats=None):
    """
    Recursively scan a directory for video files.
    
    Args:
        directory: Root directory to scan.
        supported_formats: Set of extensions (e.g., {'.mp4', '.avi'}).
                          Defaults to config.SUPPORTED_VIDEO_FORMATS.
    
    Returns:
        List of absolute paths to video files.
    """
    if supported_formats is None:
        supported_formats = SUPPORTED_VIDEO_FORMATS

    video_paths = []
    for root, _, files in os.walk(directory):
        for fname in sorted(files):
            ext = os.path.splitext(fname)[1].lower()
            if ext in supported_formats:
                video_paths.append(os.path.join(root, fname))
    return video_paths


def validate_video(video_path):
    """
    Validate a single video file.
    
    Returns:
        dict with keys: valid (bool), fps, total_frames, duration, 
        width, height, error (str or None)
    """
    result = {
        "path": video_path,
        "valid": False,
        "fps": None,
        "total_frames": None,
        "duration": None,
        "width": None,
        "height": None,
        "error": None,
    }

    try:
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            result["error"] = "Cannot open video file"
            return result

        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        if total_frames <= 0 or fps <= 0:
            result["error"] = f"Invalid metadata: frames={total_frames}, fps={fps}"
            cap.release()
            return result

        # Try reading the first frame to confirm readability
        ret, frame = cap.read()
        if not ret or frame is None:
            result["error"] = "Cannot read first frame"
            cap.release()
            return result

        duration = total_frames / fps if fps > 0 else 0

        result.update({
            "valid": True,
            "fps": round(fps, 2),
            "total_frames": total_frames,
            "duration": round(duration, 2),
            "width": width,
            "height": height,
        })

        cap.release()
    except Exception as e:
        result["error"] = str(e)

    return result


def _find_action_window(cap, total_frames, window_size=150, step=15):
    """
    Find the 5-second window (default 150 frames) with the highest motion
    using frame differencing on heavily downsampled frames.
    """
    motion_scores = []
    indices = list(range(0, total_frames, step))
    
    cap.set(cv2.CAP_PROP_POS_FRAMES, indices[0])
    ret, prev_frame = cap.read()
    if not ret: return 0, window_size
    prev_gray = cv2.cvtColor(cv2.resize(prev_frame, (64, 64)), cv2.COLOR_BGR2GRAY)
    
    for idx in indices[1:]:
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ret, frame = cap.read()
        if not ret: break
        gray = cv2.cvtColor(cv2.resize(frame, (64, 64)), cv2.COLOR_BGR2GRAY)
        diff = cv2.absdiff(gray, prev_gray)
        motion_scores.append(np.sum(diff))
        prev_gray = gray
        
    samples_in_window = window_size // step
    if len(motion_scores) < samples_in_window:
        return 0, window_size
        
    window_sums = np.convolve(motion_scores, np.ones(samples_in_window), mode='valid')
    best_sample_start = int(np.argmax(window_sums))
    best_frame_start = indices[best_sample_start]
    
    return best_frame_start, min(best_frame_start + window_size, total_frames)


def extract_frames(video_path, num_frames=None, height=None, width=None):
    """
    Extract uniformly sampled frames from a 5-second window of highest motion.
    
    Args:
        video_path: Path to the video file.
        num_frames: Number of frames to extract (default: config.NUM_FRAMES).
        height: Target frame height (default: config.FRAME_HEIGHT).
        width: Target frame width (default: config.FRAME_WIDTH).
    
    Returns:
        numpy array of shape (num_frames, height, width, 3), dtype uint8.
        Returns None if extraction fails.
    """
    if num_frames is None:
        num_frames = NUM_FRAMES
    if height is None:
        height = FRAME_HEIGHT
    if width is None:
        width = FRAME_WIDTH

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        return None

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    window_size = 150  # Enforce ~5 second window at 30fps
    
    if total_frames <= window_size:
        frame_indices = np.linspace(0, max(0, total_frames - 1), num_frames, dtype=int)
    else:
        start_frame, end_frame = _find_action_window(cap, total_frames, window_size)
        frame_indices = np.linspace(start_frame, end_frame - 1, num_frames, dtype=int)

    frames = []
    for idx in frame_indices:
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ret, frame = cap.read()
        if not ret or frame is None:
            # Fallback: use last valid frame or black frame
            if frames:
                frames.append(frames[-1].copy())
            else:
                frames.append(np.zeros((height, width, 3), dtype=np.uint8))
            continue

        # Convert BGR to RGB
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        # Resize
        frame = cv2.resize(frame, (width, height), interpolation=cv2.INTER_AREA)
        frames.append(frame)

    cap.release()

    if len(frames) != num_frames:
        return None

    return np.array(frames, dtype=np.uint8)


def batch_extract_frames(video_paths, output_dir, num_frames=None,
                         height=None, width=None, skip_existing=True):
    """
    Extract frames from multiple videos and save as .npy files.
    
    Args:
        video_paths: List of video file paths.
        output_dir: Directory to save .npy files.
        num_frames, height, width: Override config defaults.
        skip_existing: Skip videos whose .npy file already exists.
    
    Returns:
        dict with 'success' (list), 'failed' (list of (path, error)).
    """
    os.makedirs(output_dir, exist_ok=True)

    success = []
    failed = []

    for vpath in tqdm(video_paths, desc="Extracting frames"):
        basename = os.path.splitext(os.path.basename(vpath))[0]
        out_path = os.path.join(output_dir, f"{basename}.npy")

        if skip_existing and os.path.exists(out_path):
            success.append(out_path)
            continue

        try:
            frames = extract_frames(vpath, num_frames, height, width)
            if frames is not None:
                np.save(out_path, frames)
                success.append(out_path)
            else:
                failed.append((vpath, "Frame extraction returned None"))
        except Exception as e:
            failed.append((vpath, str(e)))

    return {"success": success, "failed": failed}
