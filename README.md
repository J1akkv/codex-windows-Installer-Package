# Codex CLI Windows x64 Offline Installer

This package installs Codex CLI on an offline Windows x64 host.

## Included Files

- `openai-codex-0.142.5.tgz`: Codex CLI npm wrapper.
- `openai-codex-0.142.5-win32-x64.tgz`: Windows x64 native Codex CLI package.
- `install-offline-windows.ps1`: Offline installation script.
- `VERSION.txt`: Codex CLI version.
- `SHA256SUMS.txt`: SHA-256 checksums.

## Install

Open PowerShell in this folder and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\install-offline-windows.ps1
```

By default, Codex CLI is installed to:

```text
C:\Tools\codex-cli
```

The installer creates:

```text
C:\Tools\codex-cli\bin\codex.cmd
```

and adds this `bin` folder to the current user's PATH.

Open a new PowerShell window and verify:

```powershell
codex --version
codex doctor
```

To install to another directory:

```powershell
.\install-offline-windows.ps1 -InstallDir "D:\Tools\codex-cli"
```

To skip PATH modification:

```powershell
.\install-offline-windows.ps1 -SkipPathUpdate
```
