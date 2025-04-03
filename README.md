# 🧰 Windows Debloat & Optimization Suite

A fully automated PowerShell toolkit to **debloat**, **optimize**, and **harden Windows** from the ground up.  
Collected from trusted community projects and custom-built for repeatable deployment on Windows 10 and 11.

> 💡 Tip: Combine this suite with [schneegans.de/autostart](https://schneegans.de) to run one-time tweaks on first login.

---

## 📦 Script Breakdown

| Script                     | Purpose |
|----------------------------|---------|
| `00_SystemSetup.ps1`       | SYSTEM-level performance, telemetry, power, and gaming tweaks. ✅ Safe to run in admin console (non-SYSTEM fallback). |
| `01_UI_Tweaks.ps1`         | Taskbar, File Explorer, Snap Assist, Alt+Tab, telemetry, and privacy tweaks. Runs as current user. |
| `02_SysPrep_Debloater.ps1` | Removes bloatware (PUWs), Teams, OneDrive, and optional features. FirstLogon or Sysprep-safe. |
| `03_Winget_Apps.ps1`       | Installs a curated list of apps via `winget`. Fully customizable. |
| `04_UserSetup.ps1`         | Per-user polish and associations. Applies user-level personalization. |
| `05_WindowsOptimizer.ps1`  | Downloads Optimizer.exe, injects embedded config (auto-detects Win10/11), removes tray bloat, runs silently, and cleans up. |
| `06_WindowsSpyBlocker.ps1` | Adds [WindowsSpyBlocker](https://github.com/crazy-max/WindowsSpyBlocker) firewall rules to block MS telemetry. |
| `07_CTT_Winutil.ps1`       | Executes a patched [ChrisTitusTech WinUtil](https://christitus.com/win) setup with tweaks only — no software installs. |

---

## ⚙️ Features

- ✅ 100% silent, no pop-ups
- 🔁 Safe to re-run (idempotent registry/tasks)
- 🧠 Intelligently targets Windows 10/11
- 🧹 Uses community tools: Optimizer, WinUtil, SpyBlocker
- 🧩 Modular — use what you need, when you need it
- 💻 Great for fresh installs, gold images, dev machines

---

## 🚀 Usage

You can run each script manually, use `SetupComplete`, or schedule them with tools like [schneegans.de/autostart](https://schneegans.de) for automatic one-time execution after install.

**Recommended order:**
```text
00_SystemSetup.ps1       → Admin-level baseline tweaks (or SYSTEM context)
01_UI_Tweaks.ps1         → UI, Explorer, taskbar, and privacy
02_SysPrep_Debloater.ps1 → Removes default apps and features
03_Winget_Apps.ps1       → Install your app stack
04_UserSetup.ps1         → File types, personalization, shell tweaks
05_WindowsOptimizer.ps1  → Run full Optimizer with pre-config
06_WindowsSpyBlocker.ps1 → Block Microsoft telemetry domains
07_CTT_Winutil.ps1       → Final polish via CTT WinUtil
