# ParkMinDev.MediaPipeNativeRuntime.UPM

Platform-native MediaPipe binaries and model assets for ParkMinPackages Unity integrations.

This package is the deployment boundary between MediaPipe native distributions and Unity. It does not provide the managed Runner API; use `ParkMinDev.UPM.MediaPipePlugin` for Unity-facing runtime features.

## Installation

```text
https://github.com/ParkMinDev/MediaPipeNativeRuntime.git?path=/UPM
```

## Artifacts

- Windows x86_64: official MediaPipe Tasks C `libmediapipe.dll`
- Android ARM64: source-built MediaPipe Tasks C `libmediapipe.so` with OpenCV 4.12.0 runtime
- WebGL WebAssembly artifacts: planned
- Pose Landmarker Lite, Full, and Heavy float16 v1 task models

Large binary and model files are tracked with Git LFS. Install Git LFS before installing this package from Git.

## Build Provenance

`native-version.json` records the upstream MediaPipe version, source commits, build number, and available platforms for each published package revision.

The model entries in `native-version.json` record each bundled model variant, source version, package path, and SHA-256 digest.

The Android ARM64 artifact is built from the pinned `Source/MediaPipe` commit with Bazel 7.7.0, Android NDK r28b, and the official `android_arm64` configuration. It exports the same MediaPipe Tasks C entry points used by the Windows artifact.
