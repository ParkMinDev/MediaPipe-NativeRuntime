# Changelog

## [0.1.7] - 2026-10-04

### Changed
- Updated the managed integration documentation to the ParkMinDev.UPM.MediaPipePlugin namespace; native artifacts are unchanged.

## [0.1.6] - 2026-10-04

### Changed
- Renamed the repository to MediaPipeNativeRuntime and updated installation and documentation URLs.
- Package identity, native binaries, model paths, and Unity asset GUIDs remain unchanged.

## [0.1.5] - 2026-10-04

### Changed
- Joined the project name in the package identifier and display name: `com.parkmindev.mediapipenativeruntime.upm` / `ParkMinDev.MediaPipeNativeRuntime.UPM`.
- Preserved native artifacts, model paths, and Unity asset GUIDs.

## [0.1.4] - 2026-10-04

### Changed
- Standardized package identity and display name as `com.parkmindev.mediapipe.nativeruntime.upm` / `ParkMinDev.MediaPipe.NativeRuntime.UPM`.
- Synchronized own-package dependency versions for this release; C# namespaces and assembly names remain unchanged.

## [0.1.3] - 2026-10-04

### Changed
- Renamed the installable package directory from UPMPackage to UPM and updated repository documentation links and package-path metadata.
- Kept the Unity package identity, native binaries, models, and asset GUIDs unchanged.

## [0.1.2] - 2026-10-04

### Changed
- Moved repository links and dependency URLs to ParkMinDev while preserving the package identity.
- Replaced repository dependency metadata with parkmin-upm.json and aligned ParkMin dependency release versions.

## [0.1.1] - 2026-08-27

- Moved the installable Unity package into the `UPMPackage` subdirectory.
- Added root package-path metadata for ParkMinPackages Package Manager discovery.
- Added Unity metadata for package root files and updated package documentation URLs.

## [0.1.0] - 2026-08-27

- Added the initial Unity package structure for native MediaPipe artifacts.
- Added platform directories for Windows, Android, and WebGL outputs.
- Added model storage, build provenance metadata, and Git LFS tracking rules.
- Added the official Windows x86_64 MediaPipe Tasks C runtime.
- Added the source-built Android ARM64 MediaPipe Tasks C runtime and its OpenCV 4.12.0 dependency.
- Added the official Pose Landmarker Lite, Full, and Heavy float16 v1 task models.
