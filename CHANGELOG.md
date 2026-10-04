# Repository changelog

## 2026-10-04

- Preserve Windows model-file-descriptor, optional gzip header, internal visitor-template, subgraph declaration and MSVC node-name fixes as tracked patches.
- Require PowerShell 7.2 or later for the build script's .NET hashing APIs.
- Add portable Windows preparation/build scripts with pinned upstream source, tool URLs/hashes and Bazel module lock metadata.
- Preserve the existing C++-only Swift module configuration.
- Generate local tools and source copies without machine-specific folder links; use a short per-checkout cache path for MSVC compilation.
- Scope the standard preprocessor and Protobuf C++17 compatibility settings to their affected source files.
- Document prerequisites, clean-clone commands, outputs, and the distinction between source-built and official package binaries.
- Allow repeated builds to replace read-only generated DLL outputs.
- Keep generated caches and build products ignored; Unity package binaries and package version are unchanged.
