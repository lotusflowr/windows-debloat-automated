# 🧰 Windows Debloat & Optimization Suite

A fully automated PowerShell toolkit to **debloat**, **optimize**, and **harden Windows** — from install to ready-to-use.

This suite is purpose-built for **Autounattend.xml deployments** and post-install automation.  
All scripts are compatible with tools like [schneegans.de/autostart](https://schneegans.de) for lightweight, one-time execution during OOBE or after first login.

---

## 📦 Script Breakdown

| Script                   | Purpose |
|--------------------------|---------|
| `SystemSetup.ps1`        | Core system tweaks (performance, Defender, telemetry, power plans). ✅ Can run as SYSTEM or Administrator. |
| `UI_Tweaks.ps1`          | Taskbar layout, File Explorer, privacy and telemetry hardening, plus startup cleanup (e.g., SecurityHealth, EdgeAutoLaunch). |
| `SysPrep_Debloater.ps1`  | Removes provisioned apps (PUWs), OneDrive, Teams, and optional features. Sysprep/FirstLogon safe. |
| `Winget_Apps.ps1`        | Installs your curated app list using `winget`. Auto-installs `winget` + dependencies if missing. |
| `UserSetup.ps1`          | Applies user-level personalization, shell tweaks, and associations. |
| `WindowsOptimizer.ps1`   | Downloads Optimizer, injects dynamic config (Win10/11), applies system tweaks silently, removes tray bloat, then cleans up. |
| `WindowsSpyBlocker.ps1`  | Adds [WindowsSpyBlocker](https://github.com/crazy-max/WindowsSpyBlocker) firewall rules to block Microsoft tracking. |
| `CTT_Winutil.ps1`        | Executes a **patched version** of [ChrisTitusTech WinUtil](https://christitus.com/win) applying only system tweaks (no software installs). |

---

## ⚙️ Features

- ✅ Silent execution — no popups
- 🔁 Safe to re-run — idempotent logic
- 🧠 Detects Windows 10 vs 11 automatically
- 🧩 Modular — use only what you need
- 🌐 Pulls community tools: Optimizer, WinUtil, SpyBlocker
- 💾 Winget bootstrap + install support
- 🧱 Designed specifically for **Autounattend.xml automation**

---

## 🚀 Usage

You can run scripts manually, chain them in SetupComplete/FirstLogon, or automate via OOBE using:

> 💡 [schneegans.de/autostart](https://schneegans.de/autostart)  
> Use it to schedule **one-time execution** of PowerShell scripts during the first user login — no registry or Task Scheduler changes required.  
> Perfect for `Autounattend.xml` deployments.

**Suggested execution order**:
```
SystemSetup.ps1        → SYSTEM-level baseline tweaks
UI_Tweaks.ps1          → UI, taskbar, privacy, and startup cleanup
SysPrep_Debloater.ps1  → Remove built-in apps and features
Winget_Apps.ps1        → Install app stack (auto-installs winget if needed)
UserSetup.ps1          → Per-user personalization
WindowsOptimizer.ps1   → Full Optimizer pass with embedded config
WindowsSpyBlocker.ps1  → Apply telemetry blocklists
CTT_Winutil.ps1        → Final system polish (no software)
```

---

## 📌 Requirements

- 💻 Windows 10 or 11 (22H2+ recommended)
- 🌐 Internet required for Optimizer, WinUtil, SpyBlocker, and winget
- 🛠 PowerShell 5.1+
- 🔓 Unblock scripts before running: `Right-click > Properties > Unblock`

---

## 🤝 Credits

- [Optimizer by hellzerg](https://github.com/hellzerg/optimizer)
- [WinUtil by Chris Titus Tech](https://github.com/ChrisTitusTech/winutil)
- [WindowsSpyBlocker by crazy-max](https://github.com/crazy-max/WindowsSpyBlocker)
- [schneegans.de](https://schneegans.de) for one-time script scheduling

---

## ⚠️ Disclaimer

Most inline comments in the scripts were generated using ChatGPT and may be incomplete or slightly inaccurate.  
Please review and test before relying on them in production or enterprise settings.

> Feedback and forks welcome — this is an evolving deployment suite.
