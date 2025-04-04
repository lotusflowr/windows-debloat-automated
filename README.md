# 🧰 Windows Debloat & Optimization Suite

![OS](https://img.shields.io/badge/Windows-10%20%7C%2011-blue)
![Shell](https://img.shields.io/badge/Shell-PowerShell-008fc7)
![Autounattend](https://img.shields.io/badge/Autounattend-Compatible-green)
![License](https://img.shields.io/badge/License-GPL--3.0-green)

A fully automated PowerShell toolkit to **debloat**, **optimize**, and **harden Windows** — from install to ready-to-use.

This suite is purpose-built for Autounattend.xml deployments and post-install automation.  
All scripts are compatible with tools like [schneegans.de](https://schneegans.de/windows/unattend-generator) for lightweight, one-time execution during OOBE or after first login.

---

## 📦 Script Breakdown

| Script                   | Purpose | Key Features |
|--------------------------|---------|--------------|
| `SystemSetup.ps1`        | Core system tweaks | • Disables telemetry tasks and services<br>• Activates Ultimate Performance power plan<br>• Optimizes network and RAM settings<br>• Configures gaming priorities<br>• Disables error reporting and ads<br>• Clears Start menu tiles<br>• Enables ICMP for network diagnostics |
| `UI_Tweaks.ps1`          | User interface optimization | • Removes Widgets and Meet Now<br>• Configures File Explorer behavior<br>• Disables News and Interests<br>• Hardens privacy settings<br>• Removes Edge desktop shortcut<br>• Disables telemetry and feedback |
| `SysPrep_Debloater.ps1`  | App and feature removal | • Removes provisioned apps (PUWs)<br>• Uninstalls optional features<br>• Progress tracking for removals<br>• Error handling for failed removals<br>• Safe for Sysprep/FirstLogon |
| `Winget_Apps.ps1`        | Package management | • Auto-installs winget and dependencies<br>• Installs curated app list<br>• Handles shortcut cleanup<br>• Validates installations<br>• Progress tracking |
| `UserSetup.ps1`          | User personalization | • Configures keyboard layout<br>• Sets wallpaper preferences<br>• Removes startup apps<br>• Creates network shortcuts<br>• Downloads system tools |
| `WindowsOptimizer.ps1`   | System optimization | • Downloads and runs [Optimizer](https://github.com/hellzerg/optimizer)<br>• Applies dynamic config based on OS<br>• Validates downloads<br>• Implements execution timeout<br>• Cleans up temporary files |
| `WindowsSpyBlocker.ps1`  | Privacy protection | • Downloads [WindowsSpyBlocker](https://github.com/crazy-max/WindowsSpyBlocker)<br>• Applies telemetry blocklists<br>• Configures firewall rules<br>• Cleans up installation files |
| `CTT_Winutil.ps1`        | Additional tweaks | • Downloads patched [WinUtil](https://christitus.com/win)<br>• Applies system tweaks only<br>• Validates JSON config<br>• Handles download errors<br>• Cleans up after execution |

---

## ⚙️ Features

- ✅ Silent execution — no popups
- 🔁 Safe to re-run — idempotent logic
- 🧠 Detects Windows 10 vs 11 automatically
- 🧩 Modular — use only what you need
- 🌐 Pulls community tools: [Optimizer](https://github.com/hellzerg/optimizer), [WinUtil](https://christitus.com/win), [WindowsSpyBlocker](https://github.com/crazy-max/WindowsSpyBlocker)
- 💾 Winget bootstrap + install support
- 🧱 Designed specifically for **Autounattend.xml automation**
- 📝 Detailed logging with progress tracking
- 🛡️ Error handling and validation throughout
- 🔄 Progress tracking for long operations

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
CTT_Winutil.ps1        → Additional system tweaks
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
- [schneegans.de](https://schneegans.de/windows/unattend-generator)

---

## ⚠️ Disclaimers

- Always test this suite in a virtual machine (VM) or disposable environment before deploying it to production or real hardware.
- These scripts apply deep system-level changes and may behave differently depending on your Windows version, edition, or configuration. Make sure to create backups before attempting any changes.
- Internet connectivity is required for several features. However, you can definitely adapt them to make them run offline.
- Most inline comments in the scripts and this wiki were generated using ChatGPT and may be incomplete or slightly inaccurate.  

> Feedback and forks welcome — this is an evolving deployment suite.