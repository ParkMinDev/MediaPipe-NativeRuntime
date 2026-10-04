# Rebuilding the native runtime

## Windows x86_64 source build

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

Windows compilation was verified with MSVC 14.51.36231 and JDK 21. Other compiler versions were not verified. This is not an offline build. Tool versions and download hashes are recorded in `build-settings.json`, and module dependency resolution is recorded in `MODULE.bazel.lock`.

### Clone and build

Use a reasonably short local path. Bazel's generated Windows paths can become very long.

```powershell
git -c core.longpaths=true clone --recurse-submodules https://github.com/ParkMinDev/MediaPipeNativeRuntime.git NativeRuntime
cd NativeRuntime
git lfs pull
$env:JAVA_HOME = 'C:/Program Files/Java/your-jdk-21-directory'
pwsh -File Build/Build-Windows.ps1
```

The scripts resolve all repository paths relative to their own location. `Build-Windows.ps1` detects Visual Studio through `vswhere`. If necessary, pass `-VisualCppDirectory 'C:/.../VC'` and `-JavaHome 'C:/.../jdk-21'`. `-Jobs` defaults to 8; `-OutputBase` selects the physical Bazel cache directory. By default the script uses a short per-checkout cache at `%USERPROFILE%/.mpb/<path-hash>` so MSVC can open generated headers. It shuts down its own Bazel server afterwards. Custom cache paths should also be short; the cache is generated data and does not need to be committed.

For tool/source preparation without compilation:

```powershell
pwsh -File Build/Prepare-Windows.ps1
```

### Tracked build inputs

- `build-settings.json`: upstream URL/commit, Bazel and Python versions, tool URLs and SHA-256 hashes.
- `Patches/`: local source modifications applied to the pinned upstream checkout.
- `MODULE.bazel.lock`: Bazel module dependency resolution metadata.
- `Repositories/windows_opencv/`: OpenCV Bazel repository definition and license.
- `Repositories/rules_swift/`: the existing C++-only module configuration and Swift rules license; avoids requiring a Swift compiler for this C/C++ target.
- `Prepare-Windows.ps1` and `Build-Windows.ps1`: preparation and compilation commands.

`Source/MediaPipe` remains a clean upstream submodule. Preparation creates a separate source copy at `Build/MediaPipeNativeBuild/MediaPipe` and applies the tracked patches. It recognizes already-applied patches, rejects conflicts, and rejects a different upstream commit without overwriting local work. Do not delete an existing build copy before exporting additional local edits as tracked patches.

### Windows compatibility settings

The scripts compile UTF-8 sources, enable C11 atomics, and select the standard MSVC preprocessor for MediaPipe source files. Protobuf JSON implementation files use C++17 under MSVC to work around [upstream issue #21310](https://github.com/protocolbuffers/protobuf/issues/21310); other C++ sources retain the upstream C++20 configuration. The approach is also used by [Google SentencePiece](https://github.com/google/sentencepiece/blob/master/CMakeLists.txt).

The tracked MediaPipe patches guard POSIX file-descriptor model reading on Windows, exclude the unused gzip header where the upstream MSVC rule disables zlib, remove redundant non-deducible template parameter packs from two internal visitor helpers, explicitly forward-declare the API3 subgraph template, and represent structural node-name constants as character arrays under MSVC. These changes do not modify the shipped package binaries.

### Local files excluded from Git

`Build/Tools`, `Build/MediaPipeNativeBuild`, `Build/.bazel`, and `Build/Output` are regenerable tools, working copies, caches, and outputs. They do not need to be committed. Their necessary configuration and source differences live in the tracked files above.

### Output and deployment

Successful compilation produces:

- `Build/Output/Windows/libmediapipe.dll`
- `Build/Output/Windows/opencv_world3410.dll`
- `Build/Output/Windows/build-result.json`
- `Build/Output/Windows/build.log`

The build targets `//mediapipe/tasks/c:mediapipe_source` directly; it does not use the prebuilt-library fallback target. It never replaces the package binaries automatically.

The currently shipped Windows DLL originates from the official MediaPipe 1.0.1 wheel. A locally compiled DLL is not expected to be byte-identical to that official artifact. Export comparison and runtime integration tests are required before replacing the shipped binary. The source-built output also needs its OpenCV DLL alongside it. This source target excludes the official wheel's LiteRT/LiteRT-LM exports and the `MpTextProofreader*`/`MpTextSummarizer*` functions; it is not a complete replacement for all features of the official DLL.

## Android artifact

The existing package Android ARM64 library was source-built with the same upstream commit, Bazel 7.7.0, Android NDK r28b, `--config=android_arm64`, and OpenCV 4.12.0. Its binary remains tracked through Git LFS. This Windows preparation script does not configure an Android SDK/NDK or claim to reproduce the Android artifact; Android build automation must be verified separately.

## Verification on 2026-10-04

Windows source compilation succeeded with MSVC 14.51.36231 and JDK 21 in both the existing working folder and a separate clone with independently downloaded tools/source and a separate Bazel cache. Final compatibility fixes were applied to the clone before its successful build. Rebuilding into the same output directory was also verified, including replacement of read-only generated DLL files.

Both source-built DLLs export the same 313 names, but their file hashes differ. The official packaged DLL exports 465 names and is not byte-identical to either source build. The eight functions imported by the current MediaPipePlugin are present in both source builds; DLL loading and 2x2 RGB image creation/freeing succeeded. Pose model inference, Unity execution and Android rebuilding were not tested in this verification.
