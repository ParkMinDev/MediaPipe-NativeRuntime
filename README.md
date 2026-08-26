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
- `Build`: ignored local build tools and intermediate outputs
- `UPMPackage`: installable Unity package containing native binaries and models
