"""
GPU utilities for environment validation and memory configuration.
Used as the first cell in every TensorFlow-dependent notebook.
"""

import sys
import os


def setup_environment():
    """
    Combined GPU configuration + environment check.
    Standard entry point for all notebooks.

    IMPORTANT: Memory growth MUST be set before any other TF operation
    that triggers GPU initialization. This function handles the correct
    ordering internally.

    Returns True if GPU is ready for training.
    """
    print("=" * 60)
    print("ENVIRONMENT VALIDATION")
    print("=" * 60)

    # 1. Python version
    py_version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    print(f"\nPython Version: {py_version}")
    if sys.version_info[:2] == (3, 10):
        print("  Status: PASSED")
    else:
        print(f"  Status: WARNING - Expected 3.10.x, got {py_version}")

    # 2. TensorFlow import
    try:
        import tensorflow as tf
        tf_version = tf.__version__
        print(f"\nTensorFlow Version: {tf_version}")
        print("  Status: PASSED")
    except ImportError:
        print("\nTensorFlow: NOT INSTALLED")
        print("  Status: FAILED")
        return False

    # 3. CUDA built
    cuda_built = tf.test.is_built_with_cuda()
    print(f"\nCUDA Built: {cuda_built}")
    if cuda_built:
        print("  Status: PASSED")
    else:
        print("  Status: FAILED - TensorFlow not built with CUDA support")

    # 4. GPU detection
    gpus = tf.config.list_physical_devices("GPU")
    print(f"\nGPU Devices: {len(gpus)} detected")
    for gpu in gpus:
        print(f"  - {gpu.name} ({gpu.device_type})")

    if not gpus:
        print("  Status: FAILED - No GPU detected")
        print("\n  Diagnostics:")
        print(f"    CUDA_VISIBLE_DEVICES = {os.environ.get('CUDA_VISIBLE_DEVICES', 'not set')}")
        print("    Possible causes:")
        print("    - CUDA toolkit not installed or wrong version")
        print("    - cuDNN not installed or wrong version")
        print("    - GPU driver outdated")
        print("    - TensorFlow version incompatible with CUDA version")
        return False
    else:
        print("  Status: PASSED")

    # 5. Configure memory growth BEFORE any GPU-initializing operation
    memory_growth_ok = True
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print("\nGPU memory growth: ENABLED")
    except RuntimeError:
        # Already initialized (e.g., kernel restart without full reset)
        # This is non-fatal: memory growth may already be set, or TF
        # allocated the full GPU. We continue with a warning.
        print("\nGPU memory growth: SKIPPED (GPU already initialized)")
        print("  This is normal if the kernel was restarted.")
        print("  For fresh configuration, restart the kernel fully.")
        memory_growth_ok = False

    # 6. Mixed precision
    try:
        policy = tf.keras.mixed_precision.set_global_policy("mixed_float16")
        print(f"\nMixed precision (float16): ENABLED")
        print(f"  Compute dtype:  {tf.keras.mixed_precision.global_policy().compute_dtype}")
        print(f"  Variable dtype: {tf.keras.mixed_precision.global_policy().variable_dtype}")
    except Exception as e:
        print(f"\nMixed precision: FAILED - {e}")

    # 7. VRAM info (this initializes the GPU if not already done)
    print(f"\nVRAM Information:")
    try:
        for gpu in gpus:
            device_name = gpu.name.replace("physical_device:", "")
            mem_info = tf.config.experimental.get_memory_info(device_name)
            current_mb = mem_info.get("current", 0) / (1024 ** 2)
            peak_mb = mem_info.get("peak", 0) / (1024 ** 2)
            print(f"  Current usage: {current_mb:.0f} MB")
            print(f"  Peak usage:    {peak_mb:.0f} MB")
    except Exception:
        print("  (Memory info not available)")

    print("\n" + "=" * 60)
    print("ENVIRONMENT CHECK COMPLETE")
    print("=" * 60)
    print("\nGPU environment ready for training.")
    return True
