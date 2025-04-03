# 🧰 Windows Debloat & Optimization Suite

![OS](https://img.shields.io/badge/Windows-10%20%7C%2011-blue)
![Shell](https://img.shields.io/badge/Shell-PowerShell-008fc7)
![Autounattend](https://img.shields.io/badge/Autounattend-Compatible-green)

A fully automated PowerShell toolkit to **debloat**, **optimize**, and **harden Windows** — from install to ready-to-use.

This suite is purpose-built for **Autounattend.xml deployments** and post-install automation.  
All scripts are compatible with tools like [schneegans.de](https://schneegans.de/windows/unattend-generator) for lightweight, one-time execution during OOBE or after first login.

---

## 📦 Script Breakdown

| Script                   | Purpose |
|--------------------------|---------|
| `SystemSetup.ps1`        | Core system tweaks (performance, Defender, telemetry, power plans). ✅ Can run as SYSTEM or Administrator. |
| `UI_Tweaks.ps1`          | Taskbar layout, File Explorer, privacy and telemetry hardening, plus startup cleanup (e.g., SecurityHealth, EdgeAutoLaunch). |
| `SysPrep_Debloater.ps1`  | Removes provisioned apps (PUWs), OneDrive, Teams, and optional features. Sysprep/FirstLogon safe. |
| `Winget_Apps.ps1`        | Auto-installs `winget` + dependencies and your curated app list. |
| `UserSetup.ps1`          | Applies user-level personalization, shell tweaks, and associations. |
| `WindowsOptimizer.ps1`   | Downloads [Optimizer](https://github.com/hellzerg/optimizer), injects dynamic config (Win10/11), applies system tweaks silently, removes tray bloat, then cleans up. |
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

> 💡 [schneegans.de](https://schneegans.de/windows/unattend-generator/)  
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

### 📦 Autounattend Integration

This project includes and supports a fully configured `Autounattend.xml` for hands-free deployment.

You can use [schneegans.de's Unattended Generator](https://schneegans.de/windows/unattend-generator/) to modify or inspect the unattended configuration.

To apply this to your install media, simply place the provided [`Autounattend.xml`](./autounattend.xml) at the root of a bootable Windows ISO or USB

You can find a copy of the example [`Autounattend.xml`](./autounattend.xml) in this repository.

More info in the [Wiki/Autounattend-Integration](https://github.com/lotusflowr/windows-debloat-automated/wiki/Autounattend-Integration).

## 📌 Requirements

- 💻 Windows 10 or 11 (22H2+ recommended)
- 🌐 Internet required for Optimizer, WinUtil, SpyBlocker, and winget
- 🛠 PowerShell 5.1+
- 🔓 If running from a PowerShell window, use: `powershell.exe -ExecutionPolicy Bypass -File .\ScriptName.ps1`

---

## 🤝 Credits

- [Optimizer by hellzerg](https://github.com/hellzerg/optimizer)
- [WinUtil by Chris Titus Tech](https://github.com/ChrisTitusTech/winutil)
- [WindowsSpyBlocker by crazy-max](https://github.com/crazy-max/WindowsSpyBlocker)
- [schneegans.de](https://schneegans.de) for one-time script scheduling

---

## ⚠️ Disclaimers

- Always test this suite in a virtual machine (VM) or disposable environment before deploying it to production or real hardware.
- These scripts apply deep system-level changes and may behave differently depending on your Windows version, edition, or configuration. Make sure to create backups before attempting any changes.
- Most inline comments in the scripts and this wiki were generated using ChatGPT and may be incomplete or slightly inaccurate.  

> Feedback and forks welcome — this is an evolving deployment suite.
