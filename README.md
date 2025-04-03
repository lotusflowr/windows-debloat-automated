# 🧰 Windows Debloat & Optimization Suite

![OS](https://img.shields.io/badge/Windows-10%20%7C%2011-blue)
![Shell](https://img.shields.io/badge/Shell-PowerShell-008fc7)
![Autounattend](https://img.shields.io/badge/Autounattend-Compatible-green)

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


---


---

### 📦 Autounattend Integration

This project includes and supports a fully configured `Autounattend.xml` for hands-free deployment.

You can use [schneegans.de's Unattended Generator](https://schneegans.de/windows/unattend-generator/?LanguageMode=Unattended&UILanguage=en-US&Locale=en-CA&Keyboard=00011009&GeoLocation=39&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&BypassNetworkCheck) to modify or inspect the unattended configuration.

To apply this to your install media:
- Place the provided `Autounattend.xml` at the root of a bootable Windows ISO or USB
- We recommend using [NTLite](https://www.ntlite.com/) to inject the file and repackage the ISO quickly

You can find a copy of the example [`Autounattend.xml`](./Autounattend.xml) in this repository.



---

### 📦 Autounattend Integration (Unattended Setup)

This project is built to integrate seamlessly with `Autounattend.xml` for **fully automated Windows installations** — including post-setup script execution.

#### 🗂 Where to Place Files in the ISO

To prepare your installation media:

```
📁 ISO_ROOT/
├── Autounattend.xml           ← 🟢 Place this at the root of the ISO or USB
├── $OEM$/
│   └── $$/
│       └── Scripts/           ← 📁 Your PowerShell scripts (run post-setup)
│           ├── UI_Tweaks.ps1
│           ├── SystemSetup.ps1
│           └── ...
├── boot/
├── sources/
├── setup.exe
└── ...
```

This structure ensures your scripts are copied to `C:\Scripts\` on the installed OS.

#### 🛠 Autounattend Execution Method

Your `Autounattend.xml` should contain a `FirstLogonCommands` section that triggers your chosen script once setup completes:

```xml
<FirstLogonCommands>
  <SynchronousCommand wcm:action="add">
    <Order>1</Order>
    <Description>Run UI Tweaks</Description>
    <CommandLine>cmd /c start /min powershell.exe -ExecutionPolicy Bypass -File "%SystemDrive%\Scripts\UI_Tweaks.ps1"</CommandLine>
  </SynchronousCommand>
</FirstLogonCommands>
```

💡 You may trigger any script placed under `Scripts\` using this method. Just update the filename in the `CommandLine`.

#### 🧰 ISO Repackaging Tools

Once files are added, use one of the following to repackage the ISO:

- [NTLite](https://www.ntlite.com/) — easy drag-and-drop GUI
- [oscdimg](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options) — CLI tool from Windows ADK
- Rufus (if deploying via USB)

#### 🧪 Customize Your XML

Use [schneegans.de's Unattended Generator](https://schneegans.de/windows/unattend-generator/?LanguageMode=Unattended&UILanguage=en-US&Locale=en-CA&Keyboard=00011009&GeoLocation=39&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&BypassNetworkCheck) to inspect or generate your own `Autounattend.xml`.

📄 A working example is included in this repository: [`Autounattend.xml`](./Autounattend.xml)


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

## ⚠️ Disclaimer

Most inline comments in the scripts were generated using ChatGPT and may be incomplete or slightly inaccurate.  
Please review and test before relying on them in production or enterprise settings.

> Feedback and forks welcome — this is an evolving deployment suite.
