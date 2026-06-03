"""
Data pipeline utilities for tf.data-based loading and preprocessing.
Designed for memory-efficient training on RTX 4050 (6GB VRAM).
"""

import os
import numpy as np
import tensorflow as tf

import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from configs.config import (
    NUM_FRAMES,
    FRAME_HEIGHT,
    FRAME_WIDTH,
    FRAME_CHANNELS,
    VGG16_FEATURE_SHAPE,
    BATCH_SIZE,
    SHUFFLE_BUFFER_SIZE,
    PREFETCH_BUFFER,
    CLASS_TO_INDEX,
    NUM_CLASSES,
)


def load_npy_sample(path_tensor, label):
    """
    TensorFlow-compatible .npy loader using py_function.
    Loads a frame sequence and normalizes to [0, 1].
    """
    def _load(path_bytes):
        path_str = path_bytes.numpy().decode("utf-8")
        data = np.load(path_str).astype(np.float32) / 255.0
        return data

    frames = tf.py_function(_load, [path_tensor], tf.float32)
    frames.set_shape([NUM_FRAMES, FRAME_HEIGHT, FRAME_WIDTH, FRAME_CHANNELS])
    return frames, label


def load_feature_sample(path_tensor, label):
    """
    Load pre-extracted VGG16 feature sequences (.npy, float16).
    """
    def _load(path_bytes):
        path_str = path_bytes.numpy().decode("utf-8")
        data = np.load(path_str).astype(np.float32)
        return data

    features = tf.py_function(_load, [path_tensor], tf.float32)
    features.set_shape([NUM_FRAMES, *VGG16_FEATURE_SHAPE])
    return features, label


def build_dataset(file_paths, labels, loader_fn=None, batch_size=None,
                  shuffle=True, augment=False):
    """
    Build a tf.data.Dataset from file paths and labels.
    
    Args:
        file_paths: List of .npy file paths.
        labels: List of integer labels (0 or 1).
        loader_fn: Loading function (default: load_npy_sample).
        batch_size: Batch size (default: config.BATCH_SIZE).
        shuffle: Whether to shuffle the dataset.
        augment: Reserved for future on-the-fly augmentation.
    
    Returns:
        tf.data.Dataset yielding (data, one_hot_label) batches.
    """
    if loader_fn is None:
        loader_fn = load_npy_sample
    if batch_size is None:
        batch_size = BATCH_SIZE

    # One-hot encode labels
    one_hot_labels = tf.keras.utils.to_categorical(labels, num_classes=NUM_CLASSES)

    dataset = tf.data.Dataset.from_tensor_slices(
        (file_paths, one_hot_labels)
    )

    if shuffle:
        dataset = dataset.shuffle(buffer_size=min(SHUFFLE_BUFFER_SIZE, len(file_paths)))

    dataset = dataset.map(loader_fn, num_parallel_calls=tf.data.AUTOTUNE)
    dataset = dataset.batch(batch_size)
    dataset = dataset.prefetch(PREFETCH_BUFFER)

    return dataset


def build_feature_dataset(file_paths, labels, batch_size=None, shuffle=True):
    """
    Convenience wrapper for pre-extracted VGG16 feature datasets.
    """
    return build_dataset(
        file_paths=file_paths,
        labels=labels,
        loader_fn=load_feature_sample,
        batch_size=batch_size,
        shuffle=shuffle,
    )


def get_split_data(split_csv_path, base_dir=None):
    """
    Load file paths and labels from a split CSV.
    
    Expected CSV format: filename,label,class_name
    
    Args:
        split_csv_path: Path to the split CSV file.
        base_dir: Base directory for resolving relative paths.
                  If None, paths in CSV are treated as absolute.
    
    Returns:
        (file_paths, labels) tuple.
    """
    import pandas as pd

    df = pd.read_csv(split_csv_path)
    file_paths = df["filepath"].tolist()
    labels = df["label"].tolist()

    if base_dir:
        file_paths = [os.path.join(base_dir, fp) for fp in file_paths]

    return file_paths, labels
