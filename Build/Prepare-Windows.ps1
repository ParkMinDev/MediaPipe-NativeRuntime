#Requires -Version 7.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$settings = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'build-settings.json') -Raw | ConvertFrom-Json
$root = Split-Path $PSScriptRoot -Parent
$tools = Join-Path $PSScriptRoot 'Tools'
$source = Join-Path $PSScriptRoot 'MediaPipeNativeBuild/MediaPipe'
New-Item -ItemType Directory -Path $tools -Force | Out-Null

# Git for Windows supplies the utilities used by git-submodule and Bazel.
$git = (Get-Command git -ErrorAction Stop).Source
$gitRoot = (Resolve-Path (Join-Path (& $git --exec-path) '../../..')).Path
$env:PATH = "$(Join-Path $gitRoot 'usr/bin');$(Join-Path $gitRoot 'mingw64/bin');$env:PATH"

# Download only versioned, hash-checked inputs.
foreach ($tool in $settings.tools) {
    $file = Join-Path $tools $tool.file
    if (Test-Path -LiteralPath $file) {
        if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ne $tool.sha256) { throw "Unexpected tool hash: $file" }
    } else {
        Write-Host "Downloading $($tool.file)"
        $temporary = "$file.download"
        Invoke-WebRequest -Uri $tool.url -OutFile $temporary
        if ((Get-FileHash -LiteralPath $temporary -Algorithm SHA256).Hash -ne $tool.sha256) { throw "Download hash mismatch: $temporary" }
        Move-Item -LiteralPath $temporary -Destination $file
    }
}

# Keep the upstream submodule clean and apply local patches in the build copy.
$upstream = Join-Path $root 'Source/MediaPipe'
if ((Test-Path -LiteralPath (Join-Path $upstream 'WORKSPACE')) -eq $false) {
    & $git -C $root -c core.longpaths=true submodule update --init -- Source/MediaPipe
    if ($LASTEXITCODE -ne 0) { throw 'Unable to initialize Source/MediaPipe.' }
}
$upstreamCommit = & $git -C $upstream rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $upstreamCommit -ne $settings.source.commit) { throw 'The upstream submodule does not match build-settings.json.' }
if ((Test-Path -LiteralPath $source) -eq $false) {
    New-Item -ItemType Directory -Path (Split-Path $source -Parent) -Force | Out-Null
    & $git -c core.longpaths=true clone --no-checkout --no-hardlinks $upstream $source
    if ($LASTEXITCODE -ne 0) { throw 'Unable to create the build source copy.' }
    & $git -C $source -c core.longpaths=true checkout --detach $settings.source.commit
    if ($LASTEXITCODE -ne 0) { throw 'Unable to check out the pinned source.' }
}
$sourceCommit = & $git -C $source rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $sourceCommit -ne $settings.source.commit) { throw 'Existing build source uses another commit; it has not been overwritten.' }
foreach ($patch in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Patches') -Filter '*.patch' | Sort-Object Name) {
    & $git -C $source apply --check $patch.FullName 2>$null
    if ($LASTEXITCODE -eq 0) {
        & $git -C $source apply $patch.FullName
        if ($LASTEXITCODE -ne 0) { throw "Unable to apply $($patch.Name)." }
    } else {
        & $git -C $source apply --reverse --check $patch.FullName 2>$null
        if ($LASTEXITCODE -ne 0) { throw "Patch conflicts with existing changes: $($patch.Name)." }
    }
}
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'MODULE.bazel.lock') -Destination (Join-Path $source 'MODULE.bazel.lock')

# Extract portable tool repositories without machine-specific junctions.
$swift = Join-Path $tools 'rules_swift'
if ((Test-Path -LiteralPath (Join-Path $swift 'MODULE.bazel')) -eq $false) {
    New-Item -ItemType Directory -Path $swift -Force | Out-Null
    & (Join-Path $env:SystemRoot 'System32/tar.exe') -xf (Join-Path $tools 'rules_swift.2.3.0.tar.gz') -C $swift
    if ($LASTEXITCODE -ne 0) { throw 'Unable to extract rules_swift.' }
}
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Repositories/rules_swift/MODULE.bazel') -Destination (Join-Path $swift 'MODULE.bazel') -Force
$opencv = Join-Path $tools 'opencv/opencv/build'
if ((Test-Path -LiteralPath (Join-Path $opencv 'x64/vc15/lib/opencv_world3410.lib')) -eq $false) {
    $extract = Join-Path $tools 'opencv'
    New-Item -ItemType Directory -Path $extract -Force | Out-Null
    $process = Start-Process -FilePath (Join-Path $tools 'opencv-3.4.10-vc14_vc15.exe') -ArgumentList @('-y', "-o`"$extract`"") -WindowStyle Hidden -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw 'Unable to extract OpenCV.' }
}
Copy-Item -Path (Join-Path $PSScriptRoot 'Repositories/windows_opencv/*') -Destination $opencv -Force
Write-Host "Build source prepared: $source"
