<#
.SYNOPSIS
    Builds the Flutter Windows release and packages it into an .exe installer using Inno Setup.

.DESCRIPTION
    This script automates:
    1. Reading the version from pubspec.yaml.
    2. Building the Windows Flutter desktop app (release mode).
    3. Locating the Inno Setup compiler (ISCC.exe).
    4. Compiling the .iss script into a standalone .exe installer.

.PARAMETER SkipBuild
    Skips running 'flutter build windows --release' if the binary is already built.

.PARAMETER Version
    Custom version string (defaults to version from pubspec.yaml).

.EXAMPLE
    .\tool\build_windows_installer.ps1
    .\tool\build_windows_installer.ps1 -SkipBuild
    .\tool\build_windows_installer.ps1 -Version "1.2.0"
#>

[CmdletBinding()]
param (
    [switch]$SkipBuild,
    [string]$Version
)

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  YOLO VOZILO - Inno Setup Windows Installer Builder   " -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# 1. Resolve Version
if (-not $Version) {
    $PubspecPath = Join-Path $RootDir "pubspec.yaml"
    if (Test-Path $PubspecPath) {
        $VersionLine = (Get-Content $PubspecPath | Select-String "^version:\s*(\S+)").Matches.Groups[1].Value
        if ($VersionLine) {
            $Version = ($VersionLine -split '\+')[0]
        }
    }
}
if (-not $Version) {
    $Version = "1.0.0"
}
Write-Host "» Target Version: $Version" -ForegroundColor Green

# 2. Locate Inno Setup Compiler (ISCC.exe)
$CommandResult = Get-Command iscc -ErrorAction SilentlyContinue
$IsccCandidate = if ($CommandResult) { $CommandResult.Source } else { $null }
if (-not $IsccCandidate) {
    $KnownPaths = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
        "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe"
    )
    foreach ($Path in $KnownPaths) {
        if ($Path -and (Test-Path $Path)) {
            $IsccCandidate = $Path
            break
        }
    }
}

if (-not $IsccCandidate) {
    Write-Host ""
    Write-Host "[ERROR] Inno Setup compiler (ISCC.exe) was not found on your system." -ForegroundColor Red
    Write-Host "Please install Inno Setup 6 using one of the following methods:" -ForegroundColor Yellow
    Write-Host "  1. Winget:  winget install --id JRSoftware.InnoSetup -e" -ForegroundColor White
    Write-Host "  2. Choco:   choco install innosetup -y" -ForegroundColor White
    Write-Host "  3. Manual:  https://jrsoftware.org/isdl.php" -ForegroundColor White
    Write-Host ""
    exit 1
}
Write-Host "» Using Inno Setup Compiler: $IsccCandidate" -ForegroundColor Green

# 3. Build Windows Desktop App
$BuildDir = Join-Path $RootDir "build\windows\x64\runner\Release"

if (-not $SkipBuild) {
    Write-Host "» Building Flutter Windows Desktop release..." -ForegroundColor Yellow
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Flutter build failed." -ForegroundColor Red
        exit $LASTEXITCODE
    }
} else {
    Write-Host "» Skipping Flutter build (-SkipBuild specified)." -ForegroundColor DarkGray
}

if (-not (Test-Path $BuildDir)) {
    # Fallback path if x64 folder is omitted
    $FallbackDir = Join-Path $RootDir "build\windows\runner\Release"
    if (Test-Path $FallbackDir) {
        $BuildDir = $FallbackDir
    } else {
        Write-Host "[ERROR] Release build directory not found at $BuildDir" -ForegroundColor Red
        exit 1
    }
}

$ExePath = Join-Path $BuildDir "multiplatform.exe"
if (-not (Test-Path $ExePath)) {
    Write-Host "[ERROR] Executable not found at $ExePath" -ForegroundColor Red
    exit 1
}

# 4. Compile Installer
$IssFile = Join-Path $RootDir "windows\installer\yolo_vozilo_setup.iss"
if (-not (Test-Path $IssFile)) {
    Write-Host "[ERROR] Inno Setup script not found at $IssFile" -ForegroundColor Red
    exit 1
}

$InstallerOutputDir = Join-Path $RootDir "build\windows\installer"
if (-not (Test-Path $InstallerOutputDir)) {
    New-Item -ItemType Directory -Path $InstallerOutputDir -Force | Out-Null
}

Write-Host "» Compiling Inno Setup installer..." -ForegroundColor Yellow
$IsccArgs = @(
    "/DMyAppVersion=$Version",
    "/DBuildDir=$BuildDir",
    "/O$InstallerOutputDir",
    $IssFile
)

& $IsccCandidate $IsccArgs

if ($LASTEXITCODE -eq 0) {
    $FinalInstaller = Join-Path $InstallerOutputDir "yolo-vozilo-windows-installer.exe"
    Write-Host ""
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "  BUILD SUCCESSFUL!                                    " -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "Installer created at:" -ForegroundColor Cyan
    Write-Host "  $FinalInstaller" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[ERROR] Inno Setup compilation failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
