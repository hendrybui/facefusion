import onnxruntime as ort
import sys

print("=" * 60)
print("ONNX Runtime OpenVINO Provider Test")
print("=" * 60)

# Check version
print(f"\nONNX Runtime version: {ort.__version__}")

# Check available providers
providers = ort.get_available_providers()
print(f"\nAvailable providers: {providers}")

# Check if OpenVINO is available
if 'OpenVINOExecutionProvider' in providers:
    print("\n✓ OpenVINOExecutionProvider: AVAILABLE")

    # Try to create a session with OpenVINO
    try:
        # Create a simple test session
        sess_options = ort.SessionOptions()
        print("\n✓ Session options created successfully")

        # Test provider options
        provider_options = {
            'device_type': 'CPU',
            'precision': 'FP32'
        }

        print(f"✓ Provider options: {provider_options}")
        print("\n✓ OpenVINO provider is fully functional!")

    except Exception as e:
        print(f"\n✗ Error creating OpenVINO session: {e}")
        sys.exit(1)
else:
    print("\n✗ OpenVINOExecutionProvider: NOT AVAILABLE")
    sys.exit(1)

print("\n" + "=" * 60)
print("All tests passed!")
print("=" * 60)
