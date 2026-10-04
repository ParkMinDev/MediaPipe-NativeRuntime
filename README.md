# MediaPipe-NativeRuntime

Build and distribution repository for the ParkMinPackages MediaPipe native runtime.

The repository keeps the pinned upstream MediaPipe source and local build workspace separate from the installable Unity Package Manager package.

## Unity Package

Install the package from the `UPMPackage` subdirectory.

```text
https://github.com/ParkMinDev/MediaPipe-NativeRuntime.git?path=/UPMPackage
```

Package documentation is available at [`UPMPackage/README.md`](UPMPackage/README.md).

## Repository Layout

- `Source/MediaPipe`: pinned upstream MediaPipe source submodule
- `Build`: tracked build scripts, configuration, source patches, and ignored local tools/outputs
- `UPMPackage`: installable Unity package containing native binaries and models

## Rebuild from source

### Windows build prerequisites

Install the following dependencies manually in a new environment:

| Dependency | Required setup | Purpose / installation check |
| --- | --- | --- |
| PowerShell | 7.2 or later; use `pwsh`, not Windows PowerShell 5.1 | Runs build scripts; check with `pwsh -NoProfile -Command '$PSVersionTable.PSVersion'` |
| Git for Windows | Available on `PATH` | Retrieves source repositories; check with `git --version` |
| Git LFS (Large File Storage) | Install and run `git lfs install` | Retrieves tracked binary/model files; check with `git lfs version` |
| Visual Studio | **Desktop development with C++**, including MSVC (Microsoft Visual C++) x64/x86 build tools | Compiles the native library; confirm the workload in Visual Studio Installer |
| Windows SDK (Software Development Kit) | Include a Windows SDK with the Visual Studio C++ workload | Provides Windows headers and libraries; confirm it in Visual Studio Installer |
| JDK (Java Development Kit) | Version 21; set `JAVA_HOME` or pass `-JavaHome` to the build script | Runs Bazel; check with `& "$env:JAVA_HOME/bin/java.exe" -version` |
| Internet access | Required for initial preparation and dependency fetching | Downloads pinned tools and external dependencies |

The scripts prepare Bazelisk 1.29.0, Bazel 7.7.0, OpenCV 3.4.10, Swift rules 2.3.0, and the configured Python 3.11 build runtime. These do not need separate manual installation; a Swift compiler is not required for this Windows C/C++ target.

Windows compilation was verified with MSVC 14.51.36231 and JDK 21. Other compiler versions were not verified. This is not an offline build. Tool versions and download hashes are recorded in `Build/build-settings.json`, and module dependency resolution is recorded in `Build/MODULE.bazel.lock`.

See [`Build/README.md`](Build/README.md) for clean-clone preparation, Windows source compilation, output paths, and toolchain requirements.
