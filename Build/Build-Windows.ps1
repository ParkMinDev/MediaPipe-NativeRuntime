#Requires -Version 7.0
[CmdletBinding()]
param(
    [ValidateRange(1,128)][int]$Jobs = 8,
    [string]$OutputBase,
    [string]$VisualCppDirectory = $env:BAZEL_VC,
    [string]$JavaHome = $env:JAVA_HOME
)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'Prepare-Windows.ps1')
$settings = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'build-settings.json') -Raw | ConvertFrom-Json
$tools = Join-Path $PSScriptRoot 'Tools'
$source = Join-Path $PSScriptRoot 'MediaPipeNativeBuild/MediaPipe'
$output = Join-Path $PSScriptRoot 'Output/Windows'
if ([string]::IsNullOrWhiteSpace($OutputBase)) {
    $cacheId = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($PSScriptRoot))).Substring(0, 8)
    $OutputBase = Join-Path $env:USERPROFILE ".mpb/$cacheId"
}
$OutputBase = [IO.Path]::GetFullPath($OutputBase)

# Locate installed C++ and Java toolchains; never store their absolute paths.
if ([string]::IsNullOrWhiteSpace($VisualCppDirectory)) {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
    if (Test-Path -LiteralPath $vswhere) {
        $installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($installation) { $VisualCppDirectory = Join-Path $installation 'VC' }
    }
}
if ([string]::IsNullOrWhiteSpace($VisualCppDirectory) -or (Test-Path -LiteralPath (Join-Path $VisualCppDirectory 'Tools/MSVC')) -eq $false) { throw 'Install Visual Studio C++ tools, or specify -VisualCppDirectory.' }
if ([string]::IsNullOrWhiteSpace($JavaHome)) {
    $java = Get-Command java -ErrorAction SilentlyContinue
    if ($java) {
        $javaSettings = & $java.Source -XshowSettings:properties -version 2>&1
        $javaProperty = $javaSettings | Select-String -Pattern '^\s*java.home = (.+)$' | Select-Object -First 1
        if ($javaProperty) { $JavaHome = $javaProperty.Matches[0].Groups[1].Value.Trim() }
    }
}
if ([string]::IsNullOrWhiteSpace($JavaHome) -or (Test-Path -LiteralPath (Join-Path $JavaHome 'bin/javac.exe')) -eq $false) { throw 'Install JDK 21 and set JAVA_HOME, or specify -JavaHome.' }
$env:BAZEL_VC = $VisualCppDirectory
$env:JAVA_HOME = $JavaHome
$gitRoot = (Resolve-Path (Join-Path (& git --exec-path) '../../..')).Path
$env:BAZEL_SH = Join-Path $gitRoot 'bin/bash.exe'
$env:USE_BAZEL_VERSION = $settings.bazelVersion
$env:BAZELISK_HOME = Join-Path $tools 'bazelisk-cache'
New-Item -ItemType Directory -Path $output -Force | Out-Null
$arguments = @(
    "--output_base=$($OutputBase.Replace('\','/'))", 'build', '-c', 'opt', "--jobs=$Jobs",
    '--define=MEDIAPIPE_DISABLE_GPU=1', '--define=protobuf_allow_msvc=true',
    '--per_file_copt=.*google/protobuf/json/.*[.]cc@/std:c++17', '--host_per_file_copt=.*google/protobuf/json/.*[.]cc@/std:c++17',
    '--per_file_copt=mediapipe/.*[.]cc@/Zc:preprocessor', '--host_per_file_copt=mediapipe/.*[.]cc@/Zc:preprocessor',
    '--copt=/utf-8', '--host_copt=/utf-8', '--conlyopt=/std:c11', '--conlyopt=/experimental:c11atomics',
    "--repo_env=HERMETIC_PYTHON_VERSION=$($settings.pythonVersion)",
    "--override_repository=windows_opencv=$((Join-Path $tools 'opencv/opencv/build').Replace('\','/'))",
    "--override_module=rules_swift=$((Join-Path $tools 'rules_swift').Replace('\','/'))",
    '//mediapipe/tasks/c:mediapipe_source'
)
New-Item -ItemType Directory -Path $OutputBase -Force | Out-Null
Push-Location $source
try {
    & (Join-Path $tools 'bazelisk-windows-amd64.exe') @arguments 2>&1 | Tee-Object -FilePath (Join-Path $output 'build.log')
    if ($LASTEXITCODE -ne 0) { throw "MediaPipe build failed; see $output/build.log." }
    $binary = Join-Path $OutputBase 'execroot/_main/bazel-out/x64_windows-opt/bin/mediapipe/tasks/c/mediapipe_source.dll'
    Copy-Item -LiteralPath $binary -Destination (Join-Path $output 'libmediapipe.dll')
    Copy-Item -LiteralPath (Join-Path $tools 'opencv/opencv/build/x64/vc15/bin/opencv_world3410.dll') -Destination $output
    $result = [ordered]@{
        sourceCommit = $settings.source.commit
        bazelVersion = $settings.bazelVersion
        compilerDirectory = $VisualCppDirectory
        javaHome = $JavaHome
        arguments = $arguments
        sha256 = (Get-FileHash -LiteralPath (Join-Path $output 'libmediapipe.dll') -Algorithm SHA256).Hash
    }
    $result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $output 'build-result.json') -Encoding utf8
    Write-Host "Built DLL: $output/libmediapipe.dll"
} finally {
    & (Join-Path $tools 'bazelisk-windows-amd64.exe') "--output_base=$OutputBase" shutdown 2>&1 | Out-Null
    Pop-Location
}
