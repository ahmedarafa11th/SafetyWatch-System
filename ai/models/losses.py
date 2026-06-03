"""
Categorical Focal Loss implementation for class imbalance handling.

Reference: Lin et al., "Focal Loss for Dense Object Detection", ICCV 2017.
Adapted for binary violence detection on VGG16+ConvLSTM extracted features.
"""

import tensorflow as tf
from tensorflow.keras import backend as K


def categorical_focal_loss(gamma=2.0, alpha=0.25):
    """
    Categorical focal loss for multi-class classification.

    FL(p_t) = -alpha_t * (1 - p_t)^gamma * log(p_t)

    Args:
        gamma: Focusing parameter. Higher values down-weight easy examples more.
               Default 2.0 (paper recommendation).
        alpha: Class balancing weight. Default 0.25.

    Returns:
        Loss function compatible with Keras model.compile().
    """
    def focal_loss(y_true, y_pred):
        # Clip predictions to prevent log(0)
        y_pred = K.clip(y_pred, K.epsilon(), 1.0 - K.epsilon())

        # Compute cross entropy
        cross_entropy = -y_true * K.log(y_pred)

        # Compute focal weight
        focal_weight = K.pow(1.0 - y_pred, gamma)

        # Apply alpha balancing
        loss = alpha * focal_weight * cross_entropy

        return K.sum(loss, axis=-1)

    focal_loss.__name__ = f"focal_loss_g{gamma}_a{alpha}"
    return focal_loss
