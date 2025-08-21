# Windows Automated Setup Script

A comprehensive PowerShell script that automates the setup of a Windows development environment with all essential tools and configurations.

## 🚀 Features

This script automates the installation and configuration of:

### Core Tools
- **PowerShell 7** - Latest PowerShell version
- **Windows Terminal** - Modern terminal application
- **Visual Studio Code** - Code editor
- **Git & GitHub Desktop** - Version control tools
- **Docker Desktop** - Containerization platform
- **Node.js & npm** - JavaScript runtime and package manager
- **Obsidian** - Note-taking application

### Windows Features
- **Hyper-V** - Virtualization platform
- **WSL (Windows Subsystem for Linux)** - Linux compatibility layer
- **Virtual Machine Platform** - VM support
- **Hypervisor Platform** - Hardware virtualization

### Linux Distributions
- **Kali Linux** - Penetration testing distribution
- **Ubuntu** - Popular Linux distribution
- **Kali Web Tools** - Web security testing tools

### System Configuration
- **Power Settings** - Optimized for development work
- **PowerShell Execution Policy** - Configured for development
- **Environment Variables** - Refreshed for new installations

## 📋 Prerequisites

- **Windows 10/11** (Build 1903 or higher for WSL 2)
- **Administrator privileges** (script requires elevation)
- **Internet connection** for downloading packages
- **Sufficient disk space** (recommended: 10GB+ free space)

## 🛠️ Usage

### Method 1: Direct Execution
1. **Download** the script to your desired location
2. **Right-click** on `Setup-Automation.ps1`
3. **Select** "Run with PowerShell"
4. **Click "Yes"** when prompted for administrator privileges

### Method 2: PowerShell Terminal
1. **Open PowerShell as Administrator**
2. **Navigate** to the script directory:
   ```powershell
   cd "C:\path\to\script\directory"
   ```
3. **Execute** the script:
   ```powershell
   .\Setup-Automation.ps1
   ```

### Method 3: One-Line Remote Execution
```powershell
# Download and run directly (use with caution)
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/your-repo/Setup-Automation.ps1'))
```

## 📊 Expected Outputs

### Successful Installation Output Examples

#### winget installations:
```
Found PowerShell [Microsoft.PowerShell]
This application is licensed to you by its owner.
...
Successfully installed
```

#### Windows Features:
```
Deployment Image Servicing and Management tool
...
The operation completed successfully.
```

#### WSL Setup:
```
Installing: Virtual Machine Platform
Installing: Windows Subsystem for Linux
...
The requested operation is successful. Changes will not be effective until the system is rebooted.
```

#### npm installations:
```
+ npm@10.2.4
added 1 package in 2s
+ next@14.0.3
added 245 packages in 15s
```

## ⚙️ Command Options Reference

### winget Options
- `-e, --exact` - Match exact package ID
- `--silent` - Install without user prompts
- `--accept-package-agreements` - Accept package license agreements
- `--accept-source-agreements` - Accept source agreements

### DISM Options
- `/All` - Enable all parent features
- `/NoRestart` - Prevent automatic restart
- `/online` - Target the running operating system

### WSL Options
- `--install` - Install WSL and default distribution
- `--install -d <Distro>` - Install specific distribution
- `--update` - Update WSL kernel
- `--set-default-version <version>` - Set default WSL version
- `--list --online` - List available distributions

### PowerCfg Options
- `-change monitor-timeout-ac <minutes>` - Monitor timeout on AC power
- `-change monitor-timeout-dc <minutes>` - Monitor timeout on battery
- `-change standby-timeout-ac <minutes>` - Standby timeout on AC power
- `-change standby-timeout-dc <minutes>` - Standby timeout on battery

### npm Options
- `-g, --global` - Install packages globally
- `--save-dev` - Save as development dependency
- `--save` - Save as production dependency

## 🔧 Post-Installation Steps

### 1. **RESTART REQUIRED**
The system **must be restarted** after running this script to complete:
- Windows Features installation
- WSL kernel updates
- Environment variable refreshes

### 2. **Configure WSL Distributions**
After restart, initialize your Linux distributions:
```bash
# Launch Kali Linux
wsl -d Kali-Linux

# Launch Ubuntu
wsl -d Ubuntu
```

### 3. **Configure Git**
Set up your Git credentials:
```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 4. **Start Docker Desktop**
- Launch Docker Desktop from the Start menu
- Complete the initial setup wizard
- Sign in with your Docker Hub account (optional)

### 5. **Verify Installations**
Check that everything is working:
```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Check Node.js and npm
node --version
npm --version

# Check Git
git --version

# Check WSL distributions
wsl --list --verbose

# Check Docker
docker --version
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### **"Execution Policy" Error**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### **WSL Installation Fails**
- Ensure Windows version supports WSL 2 (Build 1903+)
- Enable virtualization in BIOS/UEFI
- Run Windows Update before attempting installation

#### **winget Not Found**
- Install App Installer from Microsoft Store
- Or download from: https://github.com/microsoft/winget-cli

#### **Package Installation Fails**
- Check internet connection
- Try running with `--silent` flag
- Check Windows Update status

#### **Docker Desktop Won't Start**
- Ensure Hyper-V is enabled
- Restart after Windows Features installation
- Check BIOS virtualization settings

### **Log Files**
The script generates a summary log file: `setup-summary.log`
Check this file for detailed installation results.

## 🔒 Security Considerations

- **Run as Administrator** - Required for system-level changes
- **Execution Policy** - Script modifies PowerShell execution policy
- **Package Sources** - Uses official winget and Chocolatey repositories
- **Network Access** - Downloads packages from internet sources

## 📝 Customization

### Adding Additional Packages
To add more winget packages, append to the installation section:
```powershell
winget install --id Publisher.PackageName --source winget -e
```

### Modifying Power Settings
Adjust the power configuration values:
```powershell
powercfg -change monitor-timeout-ac 30  # 30 minutes instead of never
```

### Adding WSL Distributions
Install additional Linux distributions:
```powershell
wsl --install -d Debian
wsl --install -d openSUSE-42
```

## 📋 Installation Summary

After successful completion, you'll have:

- ✅ **10+ Development Tools** installed and configured
- ✅ **4 Windows Features** enabled for virtualization
- ✅ **2 Linux Distributions** ready for use
- ✅ **Power Settings** optimized for development
- ✅ **Package Managers** (winget, npm, apt) configured
- ✅ **Development Environment** ready for coding

## 🤝 Contributing

Feel free to modify this script for your specific needs. Common customizations include:
- Adding organization-specific tools
- Configuring additional Windows features
- Installing specific development frameworks
- Setting up custom environment variables

## 📄 License

This script is provided as-is for educational and automation purposes. Please review and test before using in production environments.

---

**Generated on:** August 21, 2025  
**Compatible with:** Windows 10/11  
**PowerShell Version:** 5.1+ (Script installs PowerShell 7)
