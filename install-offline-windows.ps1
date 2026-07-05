param(
  [string]$InstallDir = "C:\Tools\codex-cli",
  [switch]$SkipPathUpdate
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionFile = Join-Path $ScriptDir "VERSION.txt"

if (-not (Test-Path $VersionFile)) {
  throw "VERSION.txt not found in $ScriptDir"
}

$Version = (Get-Content $VersionFile -Raw).Trim()
$MainPackage = Join-Path $ScriptDir "openai-codex-$Version.tgz"
$PlatformPackage = Join-Path $ScriptDir "openai-codex-$Version-win32-x64.tgz"

if (-not (Test-Path $MainPackage)) {
  throw "Main package not found: $MainPackage"
}

if (-not (Test-Path $PlatformPackage)) {
  throw "Windows x64 platform package not found: $PlatformPackage"
}

$PkgDir = Join-Path $InstallDir "pkg"
$BinDir = Join-Path $InstallDir "bin"
$TempDir = Join-Path $env:TEMP "codex-cli-win32-x64-$Version"

New-Item -ItemType Directory -Force $PkgDir, $BinDir | Out-Null
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $TempDir | Out-Null

Write-Host "Installing Codex CLI $Version to $InstallDir"

tar -xzf $MainPackage -C $PkgDir --strip-components 1
tar -xzf $PlatformPackage -C $TempDir --strip-components 1

$VendorSource = Join-Path $TempDir "vendor"
$VendorTarget = Join-Path $PkgDir "vendor"

if (-not (Test-Path $VendorSource)) {
  throw "Platform vendor directory not found after extraction: $VendorSource"
}

Remove-Item $VendorTarget -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item $VendorSource $VendorTarget -Recurse -Force

$CmdPath = Join-Path $BinDir "codex.cmd"
$CmdContent = @'
@echo off
node "%~dp0..\pkg\bin\codex.js" %*
'@
Set-Content -Path $CmdPath -Value $CmdContent -Encoding ASCII

if (-not $SkipPathUpdate) {
  $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $PathParts = @()
  if ($CurrentPath) {
    $PathParts = $CurrentPath -split ";" | Where-Object { $_ -ne "" }
  }

  if ($PathParts -notcontains $BinDir) {
    $NewPath = (($PathParts + $BinDir) -join ";")
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Host "Added $BinDir to the user PATH. Open a new PowerShell window before running codex."
  } else {
    Write-Host "$BinDir is already in the user PATH."
  }
}

Write-Host "Done."
Write-Host "Verify in a new PowerShell window:"
Write-Host "  codex --version"
Write-Host "  codex doctor"
