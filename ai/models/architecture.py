import tensorflow as tf
from tensorflow.keras import layers, Model

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from configs.config import (
    NUM_FRAMES,
    VGG16_FEATURE_SHAPE,
    CONVLSTM_FILTERS,
    CONVLSTM_KERNEL_SIZE,
    CONVLSTM_PADDING,
    CBAM_REDUCTION_RATIO,
    POOL_SIZE,
    LSTM_UNITS,
    DENSE_UNITS,
    DROPOUT_RATE_1,
    DROPOUT_RATE_2,
    NUM_CLASSES,
)
from models.cbam import TimeDistributedCBAM


def build_feature_model(input_shape=None, name="VGG16_ConvLSTM_Violence_Detection"):
    """
    VGG16-based Feature Model for Violence Detection.
    Input: Pre-extracted VGG16 spatial features (25, 7, 7, 512).

    Architecture:
        Input -> Bidirectional(ConvLSTM2D) -> CBAM -> MaxPooling3D
        -> TimeDistributed(Flatten) -> LSTM -> Dropout -> Dense -> Dropout -> Softmax

    Returns:
        Compiled-ready Keras Model optimized for consumer-grade GPUs.
    """
    if input_shape is None:
        input_shape = (NUM_FRAMES, *VGG16_FEATURE_SHAPE)

    inputs = layers.Input(shape=input_shape, name="vgg16_feature_input")

    # Bidirectional ConvLSTM2D for temporal feature extraction
    x = layers.Bidirectional(
        layers.ConvLSTM2D(
            filters=CONVLSTM_FILTERS,
            kernel_size=CONVLSTM_KERNEL_SIZE,
            padding=CONVLSTM_PADDING,
            return_sequences=True,
            dropout=0.2,
            recurrent_dropout=0.0,  # Must be 0 for cuDNN hardware acceleration
        ),
        name="bidirectional_convlstm2d",
    )(inputs)

    # CBAM attention (applied per timestep) to refine VGG16 spatial maps
    x = TimeDistributedCBAM(
        reduction_ratio=CBAM_REDUCTION_RATIO,
        name="cbam_attention",
    )(x)

    # MaxPooling3D to reduce spatial and temporal dimensions
    x = layers.MaxPooling3D(
        pool_size=POOL_SIZE,
        name="max_pool_3d",
    )(x)

    # Flatten spatial dimensions per timestep
    x = layers.TimeDistributed(
        layers.Flatten(),
        name="td_flatten",
    )(x)

    # LSTM for final sequence encoding
    x = layers.LSTM(
        LSTM_UNITS,
        name="lstm_encoder",
    )(x)

    x = layers.Dropout(DROPOUT_RATE_1, name="dropout_1")(x)
    x = layers.Dense(DENSE_UNITS, activation="relu", name="dense_1")(x)
    x = layers.Dropout(DROPOUT_RATE_2, name="dropout_2")(x)

    # Classification output layer
    outputs = layers.Dense(
        NUM_CLASSES,
        activation="softmax",
        name="output",
    )(x)

    model = Model(inputs=inputs, outputs=outputs, name=name)
    return model


def get_model_summary(model):
    """Print model summary with parameter counts."""
    model.summary()
    trainable = sum(
        tf.keras.backend.count_params(w) for w in model.trainable_weights
    )
    non_trainable = sum(
        tf.keras.backend.count_params(w) for w in model.non_trainable_weights
    )
    print(f"\nTrainable parameters: {trainable:,}")
    print(f"Non-trainable parameters: {non_trainable:,}")
    print(f"Total parameters: {trainable + non_trainable:,}")

