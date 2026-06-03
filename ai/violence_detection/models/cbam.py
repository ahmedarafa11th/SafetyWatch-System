"""
Convolutional Block Attention Module (CBAM) - Custom Keras Layer.

Reference: Woo et al., "CBAM: Convolutional Block Attention Module", ECCV 2018.
Adapted specifically for refining VGG16 spatial feature maps after temporal
processing with ConvLSTM2D in the Violence Detection architecture.
"""

import tensorflow as tf
from tensorflow.keras import layers


class ChannelAttention(layers.Layer):
    """
    Channel attention sub-module.
    Applies shared MLP to both average-pooled and max-pooled features,
    then combines with sigmoid activation.
    """

    def __init__(self, reduction_ratio=16, **kwargs):
        super().__init__(**kwargs)
        self.reduction_ratio = reduction_ratio

    def build(self, input_shape):
        channels = input_shape[-1]
        reduced = max(channels // self.reduction_ratio, 1)

        self.global_avg = layers.GlobalAveragePooling2D(keepdims=True)
        self.global_max = layers.GlobalMaxPooling2D(keepdims=True)

        self.fc1 = layers.Dense(reduced, activation="relu", use_bias=False)
        self.fc2 = layers.Dense(channels, use_bias=False)

    def call(self, inputs):
        avg_pool = self.global_avg(inputs)
        max_pool = self.global_max(inputs)

        avg_out = self.fc2(self.fc1(avg_pool))
        max_out = self.fc2(self.fc1(max_pool))

        attention = tf.nn.sigmoid(avg_out + max_out)
        return inputs * attention

    def get_config(self):
        config = super().get_config()
        config.update({"reduction_ratio": self.reduction_ratio})
        return config


class SpatialAttention(layers.Layer):
    """
    Spatial attention sub-module.
    Applies a 7x7 convolution on channel-wise average and max pooled features.
    """

    def __init__(self, kernel_size=7, **kwargs):
        super().__init__(**kwargs)
        self.kernel_size = kernel_size

    def build(self, input_shape):
        self.conv = layers.Conv2D(
            filters=1,
            kernel_size=self.kernel_size,
            padding="same",
            activation="sigmoid",
            use_bias=False,
        )

    def call(self, inputs):
        avg_pool = tf.reduce_mean(inputs, axis=-1, keepdims=True)
        max_pool = tf.reduce_max(inputs, axis=-1, keepdims=True)

        concat = tf.concat([avg_pool, max_pool], axis=-1)
        attention = self.conv(concat)
        return inputs * attention

    def get_config(self):
        config = super().get_config()
        config.update({"kernel_size": self.kernel_size})
        return config


class CBAMBlock(layers.Layer):
    """
    Complete CBAM block: Channel Attention -> Spatial Attention.

    Args:
        reduction_ratio: Channel reduction ratio for the shared MLP (default: 16).
        kernel_size: Spatial convolution kernel size (default: 7).

    Input shape: (batch, height, width, channels)
    Output shape: same as input
    """

    def __init__(self, reduction_ratio=16, kernel_size=7, **kwargs):
        super().__init__(**kwargs)
        self.reduction_ratio = reduction_ratio
        self.kernel_size = kernel_size
        self.channel_attention = ChannelAttention(reduction_ratio)
        self.spatial_attention = SpatialAttention(kernel_size)

    def call(self, inputs):
        x = self.channel_attention(inputs)
        x = self.spatial_attention(x)
        return x

    def get_config(self):
        config = super().get_config()
        config.update({
            "reduction_ratio": self.reduction_ratio,
            "kernel_size": self.kernel_size,
        })
        return config


class TimeDistributedCBAM(layers.Layer):
    """
    Applies CBAM independently to each timestep of a 5D tensor.

    Input shape: (batch, timesteps, height, width, channels)
    Output shape: same as input
    """

    def __init__(self, reduction_ratio=16, kernel_size=7, **kwargs):
        super().__init__(**kwargs)
        self.cbam = CBAMBlock(reduction_ratio, kernel_size)

    def call(self, inputs):
        # inputs: (batch, time, h, w, c)
        return tf.map_fn(self.cbam, inputs)

    def get_config(self):
        config = super().get_config()
        config.update({
            "reduction_ratio": self.cbam.reduction_ratio,
            "kernel_size": self.cbam.kernel_size,
        })
        return config
