# 🧰 Windows Debloat & Optimization Suite

A fully automated PowerShell toolkit to **debloat**, **optimize**, and **harden Windows** — from install to ready-to-use.

Collected from trusted community projects and hand-tuned for minimalism, speed, and portability.  
Great for fresh installs, IT automation, gold images, and power users.

> 💡 Combine with [schneegans.de/autostart](https://schneegans.de) to automatically trigger scripts post-OOBE in a `Autounattend.xml`-based deployment.

---

## 📦 Script Breakdown

| Script                   | Purpose |
|--------------------------|---------|
| `SystemSetup.ps1`        | Core system tweaks (performance, power, Defender, telemetry). Can be run as SYSTEM or Admin. |
| `UI_Tweaks.ps1`          | File Explorer, taskbar layout, privacy settings, app suggestions, and cleanup. |
| `SysPrep_Debloater.ps1`  | Removes provisioned apps (PUWs), Teams, OneDrive, and optional features. |
| `Winget_Apps.ps1`        | Installs your custom app stack using `winget`, and auto-installs `winget` with dependencies if missing. |
| `UserSetup.ps1`          | Applies per-user settings, personalization, and Explorer polish. |
| `Startup.ps1`            | Cleans startup autoloads (e.g. `SecurityHealth`, `MicrosoftEdgeAutoLaunch_*`). Minimal but effective. |
| `WindowsOptimizer.ps1`   | Downloads and runs Optimizer with embedded config. Auto-selects Win10/11, applies tweaks, then cleans up. |
| `WindowsSpyBlocker.ps1`  | Adds [WindowsSpyBlocker](https://github.com/crazy-max/WindowsSpyBlocker) firewall rules to block MS tracking. |
| `CTT_Winutil.ps1`        | Executes a **patched version** of [ChrisTitusTech WinUtil](https://christitus.com/win), running only system tweaks (no software installs). |

---

## ⚙️ Features

- ✅ Fully silent — minimal prompts
- 🔁 Safe to re-run — idempotent tweaks
- 🧠 Automatically detects Windows 10 vs 11
- 🧩 Modular — use what you need, skip what you don’t
- 🌐 Integrates Optimizer, WinUtil, and SpyBlocker
- 💾 App installs via `winget` with **dependency detection**

---

## 🚀 Usage

Run scripts manually or automate them in a deployment chain.

> 🧠 For unattended installs (e.g., via `Autounattend.xml`), use [schneegans.de/autostart](https://schneegans.de) to schedule **one-time execution** at the end of setup — without modifying Task Scheduler or registry.

**Typical Execution Order**:
```text
SystemSetup.ps1        → SYSTEM/Admin-level baseline tweaks
UI_Tweaks.ps1          → Explorer and privacy polish
SysPrep_Debloater.ps1  → Remove bloat and default features
Winget_Apps.ps1        → Install app stack (with auto-winget bootstrap)
UserSetup.ps1          → User-level tweaks and behavior
Startup.ps1            → Remove tray auto-starts (Edge, SecurityHealth)
WindowsOptimizer.ps1   → Full system tuning via embedded Optimizer config
WindowsSpyBlocker.ps1  → Firewall telemetry blocklists
CTT_Winutil.ps1        → Final tweaks via patched WinUtil config
```
