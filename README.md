# MediaPipe-NativeRuntime

Build and distribution repository for the ParkMinPackages MediaPipe native runtime.

The repository keeps the pinned upstream MediaPipe source and local build workspace separate from the installable Unity Package Manager package.

## Unity Package

Install the package from the `UPMPackage` subdirectory.

```text
https://github.com/ParkMinPackages/MediaPipe-NativeRuntime.git?path=/UPMPackage
```

Package documentation is available at [`UPMPackage/README.md`](UPMPackage/README.md).

## Repository Layout

- `Source/MediaPipe`: pinned upstream MediaPipe source submodule
- `Build`: tracked build scripts, configuration, source patches, and ignored local tools/outputs
- `UPMPackage`: installable Unity package containing native binaries and models

## Rebuild from source

See [`Build/README.md`](Build/README.md) for clean-clone preparation, Windows source compilation, output paths, and toolchain requirements.
