"""
Centralized configuration for the Violence Detection module.
All hyperparameters, paths, and constants in one place.
"""

import os

# =============================================================================
# PATH CONFIGURATION
# =============================================================================

# Project root (two levels up from configs/)
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Dataset
DATASET_DIR = os.path.join(PROJECT_ROOT, "VDD")
VIOLENCE_DIR = os.path.join(DATASET_DIR, "Violence")
NONVIOLENCE_DIR = os.path.join(DATASET_DIR, "NonViolence")

# Preprocessing outputs
PREPROCESSING_DIR = os.path.join(PROJECT_ROOT, "preprocessing")
FRAMES_DIR = os.path.join(PREPROCESSING_DIR, "frames")
FEATURES_DIR = os.path.join(PREPROCESSING_DIR, "features")

# Model outputs
CHECKPOINTS_DIR = os.path.join(PROJECT_ROOT, "checkpoints")
OUTPUTS_DIR = os.path.join(PROJECT_ROOT, "outputs")
METADATA_DIR = os.path.join(OUTPUTS_DIR, "metadata")
SPLITS_DIR = os.path.join(OUTPUTS_DIR, "splits")
TRAINING_DIR = os.path.join(OUTPUTS_DIR, "training")
EVALUATION_DIR = os.path.join(OUTPUTS_DIR, "evaluation")
FIGURES_DIR = os.path.join(OUTPUTS_DIR, "figures")

# =============================================================================
# VIDEO PROCESSING
# =============================================================================

# Supported video formats (extensible)
SUPPORTED_VIDEO_FORMATS = {".mp4", ".avi", ".mov", ".mkv", ".wmv", ".flv", ".webm"}

# Frame extraction
NUM_FRAMES = 25                     # Uniform sampling: 25 frames per video
FRAME_HEIGHT = 224                  # VGG16 input height
FRAME_WIDTH = 224                   # VGG16 input width
FRAME_CHANNELS = 3                  # RGB

# Frame sequence shape
FRAME_SEQUENCE_SHAPE = (NUM_FRAMES, FRAME_HEIGHT, FRAME_WIDTH, FRAME_CHANNELS)

# =============================================================================
# CLASS LABELS
# =============================================================================

CLASS_NAMES = ["NonViolence", "Violence"]
NUM_CLASSES = len(CLASS_NAMES)
CLASS_TO_INDEX = {name: idx for idx, name in enumerate(CLASS_NAMES)}
INDEX_TO_CLASS = {idx: name for idx, name in enumerate(CLASS_NAMES)}

# =============================================================================
# DATASET SPLIT
# =============================================================================

TRAIN_RATIO = 0.70
VAL_RATIO = 0.15
TEST_RATIO = 0.15
RANDOM_SEED = 42

# =============================================================================
# VGG16 FEATURE EXTRACTION
# =============================================================================

VGG16_FEATURE_LAYER = "block5_pool"         # Output layer for feature extraction
VGG16_FEATURE_SHAPE = (7, 7, 512)           # Per-frame feature shape
FEATURE_SEQUENCE_SHAPE = (NUM_FRAMES, 7, 7, 512)

# =============================================================================
# MODEL ARCHITECTURE
# =============================================================================

# ConvLSTM2D
CONVLSTM_FILTERS = 32
CONVLSTM_KERNEL_SIZE = (3, 3)
CONVLSTM_PADDING = "same"

# CBAM
CBAM_REDUCTION_RATIO = 16

# MaxPooling3D
POOL_SIZE = (2, 2, 2)

# LSTM
LSTM_UNITS = 128

# Dense layers
DENSE_UNITS = 64
DROPOUT_RATE_1 = 0.7                        # After LSTM
DROPOUT_RATE_2 = 0.5                        # After Dense

# =============================================================================
# TRAINING HYPERPARAMETERS
# =============================================================================

# Optimizer
LEARNING_RATE = 1e-4

# Loss: Categorical Focal Loss
FOCAL_LOSS_GAMMA = 2.0
FOCAL_LOSS_ALPHA = 0.25

# Batch size (hardware-aware: RTX 4050, 6GB VRAM)
BATCH_SIZE = 4                              # For feature-based model
BATCH_SIZE_E2E = 2                          # For end-to-end model

# Training
MAX_EPOCHS = 100
SHUFFLE_BUFFER_SIZE = 1000

# EarlyStopping (monitor val_auc per paper methodology, mode=max)
EARLY_STOPPING_PATIENCE = 15
EARLY_STOPPING_MONITOR = "val_auc"

# ReduceLROnPlateau
LR_PATIENCE = 7
LR_FACTOR = 0.5
LR_MIN = 1e-7

# =============================================================================
# AUGMENTATION
# =============================================================================

# Applied only to minority class (NonViolence) in training set
AUGMENTATION_ROTATION_LIMIT = 15            # Degrees
AUGMENTATION_NOISE_VAR_LIMIT = (10.0, 50.0) # Gaussian noise variance range

# =============================================================================
# HARDWARE
# =============================================================================

GPU_MEMORY_GROWTH = True
MIXED_PRECISION = True
PREFETCH_BUFFER = -1                        # tf.data.AUTOTUNE
