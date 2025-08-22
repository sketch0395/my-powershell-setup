# Windows Automated Setup Script

A comprehensive PowerShell script that automates the setup of a Windows dev### Interactive Setup
For step-by-step confirmation of each installation:
```powershell
.\Setup-Automation.ps1
```

### Script Validation
Test script syntax before running:
```powershell
.\Test-Syntax.ps1
```

### Method 1: Direct Execution
1. **Download** the script to your desired location
2. **Right-click** on `Setup-Automation.ps1`
3. **Select** "Run with PowerShell"
4. **Click "Yes"** when prompted for administrator privilegesent with all essential tools and configurations.

## 📁 Project Structure

```
my-powershell/
├── Setup-Automation.ps1         # Main interactive setup script
├── Setup-Automation-Clean.ps1   # Clean version (no WSL/Kali)
├── Test-Syntax.ps1              # Script validation utility
├── README.md                    # This documentation
├── COMMAND-REFERENCE.md         # Detailed command examples
├── APPLICATION-CATALOG.md       # Complete application reference guide
├── BLOATWARE-REMOVAL-CATALOG.md # Detailed bloatware removal documentation
├── ENHANCEMENT-IDEAS.md         # Future improvement suggestions
└── setup-summary.log           # Installation log (generated)
```

## 🚀 Features

This script automates the installation and configuration of:

### 📱 Application Categories (35+ Applications)
- **Essential** (5 apps) - Core utilities like PowerToys, 7-Zip, VLC, TreeSize, Obsidian
- **Developer** (12 apps) - Programming tools including VS Code, Git, Docker, Node.js, Python
- **Creative** (4 apps) - Media & design tools like Figma, OBS Studio, GIMP, Discord
- **Security** (16 apps) - Privacy & security tools including Malwarebytes, Wireshark, Burp Suite, Bitwarden

### 🛡️ System Cleanup & Security
- **Bloatware Removal** - Removes 50+ Windows bloatware apps while protecting 14 essential applications
- **Registry Optimization** - Disables Windows ads, suggestions, and promotional content
- **Privacy Settings** - Enhanced privacy configuration for Windows 10/11

### 🎯 Smart Taskbar Management
- **Automatic App Pinning** - Pins installed applications to taskbar based on selected categories
- **Organized Workflow** - Essential tools readily accessible for improved productivity
- **Category-Based Pinning** - Different apps pinned based on user type (Student/Developer/Creative/Security)

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
- **Taskbar Customization** - Pin installed apps to taskbar for easy access

## � User Categories

### 🎓 Students & General Users
Perfect for students, researchers, and general users who need:
- **Modern Terminal** - Windows Terminal for better command-line experience
- **Code Editor** - Visual Studio Code for assignments and projects
- **Version Control** - Git for project management and collaboration
- **Note-Taking** - Obsidian for organized study notes and documentation
- **Linux Environment** - WSL with Ubuntu for cross-platform development
- **Basic Development** - Node.js for web development coursework
- **Containerization** - Docker for learning modern deployment practices

### 💼 Professional Developers
Comprehensive toolkit for professional development including:
- **Advanced Virtualization** - Hyper-V for enterprise environments
- **Security Testing** - Kali Linux for cybersecurity professionals
- **GitHub Integration** - GitHub Desktop for team collaboration
- **Multiple Distributions** - Various Linux environments for testing
- **Power User Settings** - Optimized system configuration for productivity

### 🏢 Enterprise/Team Setup
Suitable for organizational deployment with:
- **Standardized Tools** - Consistent development environment across teams
- **Security Features** - WSL and Hyper-V for secure development
- **Collaboration Tools** - Git, GitHub Desktop, and modern terminal
- **Scalable Configuration** - Easy to customize for organizational needs

## �📋 Prerequisites

- **Windows 10/11** (Build 1903 or higher for WSL 2)
- **Administrator privileges** (script requires elevation)
- **Internet connection** for downloading packages
- **Sufficient disk space** (recommended: 10GB+ free space)

## 🛠️ Usage

### Choosing the Right Script

#### 🎓 For Students & General Users
**Recommended:** `Setup-Automation.ps1` (Interactive with choices)
- Step-by-step confirmation of each installation
- Choose which app categories to install
- Pin frequently used apps to taskbar
- Perfect for first-time setup

#### 💼 For Developers & Power Users
**Recommended:** `Setup-Automation.ps1` (Interactive)
- Full control over installation process
- Selective installation by category
- Comprehensive development environment
- Taskbar organization for productivity tools


### Quick Start (Recommended)
1. **Clone or download** this repository
2. **Open PowerShell as Administrator**
3. **Navigate** to the project directory:
   ```powershell
   cd "C:\Users\your-username\Tools\my-powershell"
   ```
4. **Run the setup script**:
   ```powershell
   .\Setup-Automation.ps1
   ```

### Interactive Setup
For step-by-step confirmation of each installation:
```powershell
.\Setup-Automation.ps1
```

### Script Validation
Test script syntax before running:
```powershell
.\Test-Syntax.ps1
```

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
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/sketch0395/my-powershell/main/Setup-Automation.ps1'))
```

## 📊 Expected Outputs

### Script Execution Flow
```
[2025-08-22 14:30:15] [INFO] Starting Windows automated setup...
[2025-08-22 14:30:16] [INFO] ✓ Administrator privileges confirmed
[2025-08-22 14:30:17] [INFO] ✓ Execution policy set to RemoteSigned
[2025-08-22 14:30:18] [INFO] Beginning installation process...
[2025-08-22 14:35:20] [INFO] Configuring taskbar pins for installed applications...
[2025-08-22 14:35:23] [INFO] Successfully pinned Visual Studio Code to taskbar
[2025-08-22 14:35:24] [INFO] Successfully pinned Windows Terminal to taskbar
[2025-08-22 14:35:25] [INFO] Taskbar configuration completed
```

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

### 2. **Check Taskbar Pins**
If you enabled taskbar pinning, your frequently used applications should now be pinned:
- **Visual Studio Code** - Code editor
- **Windows Terminal** - Modern command line
- **GitHub Desktop** - Git GUI (if Developer category selected)
- **Docker Desktop** - Container management (if Developer category selected)
- **Obsidian** - Note-taking (if Essential category selected)
- **Discord** - Communication (if Creative category selected)

### 3. **Configure WSL Distributions**
After restart, initialize your Linux distributions:
```bash
# Launch Kali Linux
wsl -d Kali-Linux

# Launch Ubuntu
wsl -d Ubuntu
```

### 4. **Configure Git**
Set up your Git credentials:
```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 5. **Start Docker Desktop**
- Launch Docker Desktop from the Start menu or taskbar
- Complete the initial setup wizard
- Sign in with your Docker Hub account (optional)

### 6. **Verify Installations**
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
The scripts generate detailed log files:
- `setup-summary.log` - Installation results and timestamps
- Console output with color-coded status messages
- Error details with exit codes for troubleshooting

Check these files for detailed installation results and debugging information.

## 🔒 Security Considerations

- **Administrator Privileges** - Required for system-level changes and Windows Feature installation
- **Execution Policy** - Script temporarily modifies PowerShell execution policy for installation
- **Package Sources** - Uses official repositories (winget, Microsoft Store, GitHub releases)
- **Network Access** - Downloads packages from verified internet sources
- **Script Validation** - Use `Test-Syntax.ps1` to validate scripts before execution
- **Logging** - All actions are logged with timestamps for audit trails

## 📝 Additional Resources

### Related Files
- **[COMMAND-REFERENCE.md](COMMAND-REFERENCE.md)** - Detailed command examples and expected outputs
- **[ENHANCEMENT-IDEAS.md](ENHANCEMENT-IDEAS.md)** - Future improvement suggestions and common customizations
- **[Test-Syntax.ps1](Test-Syntax.ps1)** - Script validation utility

### Useful Links
- [Windows Package Manager (winget)](https://docs.microsoft.com/en-us/windows/package-manager/)
- [Windows Subsystem for Linux Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)

## 📝 Customization

### Adding Additional Packages
To add more winget packages, append to the installation section:
```powershell
winget install --id Publisher.PackageName --source winget -e --accept-package-agreements --accept-source-agreements
```

### Modifying Power Settings
Adjust the power configuration values:
```powershell
powercfg -change monitor-timeout-ac 30  # 30 minutes instead of never
powercfg -change standby-timeout-ac 60  # 1 hour standby timeout
```

### Adding WSL Distributions
Install additional Linux distributions:
```powershell
wsl --install -d Debian
wsl --install -d openSUSE-42
wsl --install -d Alpine
```

### Script Customization
- Edit the package lists in either `Setup-Automation.ps1` or `Setup-Automation-Clean.ps1`
- Modify the logging function in `Write-Log` for different output formats
- Adjust Windows Feature selections based on your hardware capabilities
- Customize power settings for laptop vs. desktop configurations

## 📋 Installation Summary

After successful completion, you'll have:

### 🎓 Student/General User Benefits
- ✅ **Modern Development Environment** - VS Code, Git, and Node.js ready
- ✅ **Cross-Platform Experience** - Linux (Ubuntu) alongside Windows
- ✅ **Organized Workflow** - Obsidian for note-taking and project documentation
- ✅ **Industry-Standard Tools** - Docker for learning containerization
- ✅ **Enhanced Terminal** - Windows Terminal for better command-line experience

### 💼 Professional Developer Benefits
- ✅ **Complete Virtualization Stack** - Hyper-V, WSL, and Docker ready
- ✅ **Security Testing Environment** - Kali Linux with penetration testing tools
- ✅ **Team Collaboration Tools** - GitHub Desktop and Git configured
- ✅ **Multiple Linux Distributions** - Ubuntu and Kali for diverse development needs
- ✅ **Optimized System Settings** - Power and environment configurations

### 🏢 Universal Benefits
- ✅ **10+ Development Tools** installed and configured
- ✅ **4 Windows Features** enabled for virtualization
- ✅ **2 Linux Distributions** ready for use
- ✅ **Power Settings** optimized for development
- ✅ **Package Managers** (winget, npm, apt) configured
- ✅ **Development Environment** ready for coding

## 🤝 Contributing

### Contributing to This Project
Feel free to customize and enhance these scripts for your specific needs. Common contributions include:

#### Development Environment Enhancements
- Adding programming language runtimes (Python, Java, Go, Rust)
- Including additional development tools (JetBrains IDEs, database tools)
- Framework-specific setup (React, Angular, .NET, etc.)

#### Organizational Customizations
- Company-specific tool installations
- Custom environment variable configurations
- Network and security policy implementations
- Automated license management

#### Script Improvements
- Enhanced error handling and recovery
- Progress indicators and better user feedback
- Conditional installations based on system specifications
- Backup and rollback capabilities

### Reporting Issues
If you encounter problems:
1. Check the generated log files (`setup-summary.log`)
2. Review the troubleshooting section in this README
3. Validate script syntax with `Test-Syntax.ps1`
4. Create an issue with system details and error logs

## 📄 License

This project is provided as-is under the MIT License for educational and automation purposes. Please review and test thoroughly before using in production environments.

### Disclaimer
- These scripts modify system settings and install software
- Always run in a test environment first
- Backup important data before running automated setup scripts
- Some installations may require manual configuration post-setup

---

**Generated on:** August 22, 2025  
**Compatible with:** Windows 10/11  
**PowerShell Version:** 5.1+ (Script installs PowerShell 7)  
**Repository:** [sketch0395/my-powershell](https://github.com/sketch0395/my-powershell)
