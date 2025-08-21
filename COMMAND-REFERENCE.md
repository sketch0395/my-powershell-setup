# Quick Command Reference

## winget Commands

### Search and Install
```powershell
# Search for packages
winget search Microsoft.PowerShell

# Install with exact match
winget install --id Microsoft.PowerShell --source winget -e

# Install with agreements accepted
winget install --id Microsoft.PowerShell --source winget -e --accept-package-agreements --accept-source-agreements

# Install silently
winget install --id Microsoft.PowerShell --source winget -e --silent
```

**Expected Output:**
```
Found PowerShell [Microsoft.PowerShell]
This application is licensed to you by its owner.
Microsoft Corporation grants you a license to this application under the Microsoft Software License Terms.
Successfully installed
```

### Common winget Options
- `-e, --exact` - Match exact package ID
- `--silent` - No user interaction required
- `--accept-package-agreements` - Accept package license agreements
- `--accept-source-agreements` - Accept source agreements
- `--source winget` - Use winget repository

---

## DISM Commands (Windows Features)

### Enable Features
```powershell
# Enable with all dependencies
Dism /online /Enable-Feature /FeatureName:Microsoft-hyper-v /All

# Enable without restart
Dism /online /Enable-Feature /FeatureName:Microsoft-hyper-v /All /NoRestart

# Check all features
Dism /online /Get-Features
```

**Expected Output:**
```
Deployment Image Servicing and Management tool
Version: 10.0.22621.2428

Image Version: 10.0.22621.2428

Enabling feature(s)
[==========================100.0%==========================]
The operation completed successfully.
```

### DISM Options
- `/online` - Target the running operating system
- `/All` - Enable all parent features of the specified feature
- `/NoRestart` - Suppress reboot after operation
- `/Get-Features` - Display all features and their states

---

## WSL Commands

### Installation and Setup
```powershell
# Install WSL with default distribution
wsl --install

# Install without launching
wsl --install --no-launch

# Install specific distribution
wsl --install -d Ubuntu
wsl --install -d Kali-Linux

# Update WSL kernel
wsl --update

# Set default version
wsl --set-default-version 2
```

**Expected Output:**
```
Installing: Virtual Machine Platform
Installing: Windows Subsystem for Linux
Downloading: WSL Kernel
Installing: WSL Kernel
Downloading: Ubuntu
The requested operation is successful. Changes will not be effective until the system is rebooted.
```

### WSL Management
```powershell
# List installed distributions
wsl --list --verbose

# List available distributions
wsl --list --online

# Launch specific distribution
wsl -d Ubuntu
wsl -d Kali-Linux

# Run command in distribution
wsl -d Ubuntu -- bash -c "sudo apt update"
```

### WSL Options
- `--install` - Install WSL and default Ubuntu distribution
- `--install -d <Distro>` - Install specific distribution
- `--no-launch` - Install without launching the distribution
- `--update` - Update WSL kernel to latest version
- `--set-default-version <1|2>` - Set default WSL version
- `--list --online` - Show available distributions
- `--list --verbose` - Show detailed information about installed distributions

---

## Power Configuration Commands

### PowerCfg Settings
```powershell
# Monitor timeouts (0 = never, time in minutes)
powercfg -change monitor-timeout-ac 0    # AC power
powercfg -change monitor-timeout-dc 10   # Battery power

# Standby timeouts
powercfg -change standby-timeout-ac 0    # AC power
powercfg -change standby-timeout-dc 0    # Battery power

# Check current settings
powercfg -query
```

**Expected Output:**
```
No output if successful
Use 'powercfg -query' to verify changes
```

### PowerCfg Options
- `-change monitor-timeout-ac <minutes>` - Monitor timeout on AC power
- `-change monitor-timeout-dc <minutes>` - Monitor timeout on DC (battery) power
- `-change standby-timeout-ac <minutes>` - Standby timeout on AC power
- `-change standby-timeout-dc <minutes>` - Standby timeout on DC power
- `-query` - Display current power scheme settings
- `0` = Never timeout

---

## PowerShell Execution Policy

### Set Execution Policy
```powershell
# Set for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Set for all users (requires admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Check current policy
Get-ExecutionPolicy -List
```

**Expected Output:**
```
No output if successful
```

### Execution Policy Options
- `-ExecutionPolicy` values:
  - `Restricted` - No scripts allowed
  - `RemoteSigned` - Local scripts allowed, remote scripts must be signed
  - `Unrestricted` - All scripts allowed
- `-Scope` values:
  - `CurrentUser` - Affects only current user
  - `LocalMachine` - Affects all users
- `-Force` - Suppress confirmation prompts

---

## npm Commands

### Global Package Management
```powershell
# Update npm itself
npm install -g npm

# Install global packages
npm install -g next
npm install -g typescript
npm install -g @angular/cli

# List global packages
npm list -g --depth=0

# Check versions
npm --version
node --version
```

**Expected Output:**
```
+ npm@10.2.4
added 1 package in 2s

+ next@14.0.3
added 245 packages in 15s
```

### npm Options
- `-g, --global` - Install packages globally
- `--save` - Save to package.json dependencies
- `--save-dev` - Save to package.json devDependencies
- `--depth=0` - Limit list depth (for global list)

---

## Chocolatey Commands

### Package Installation
```powershell
# Install packages
choco install nodejs.install -y
choco install git -y

# Search packages
choco search nodejs

# List installed packages
choco list --local-only
```

**Expected Output:**
```
Chocolatey v2.2.2
Installing the following packages:
nodejs.install
...
The install of nodejs.install was successful.
```

### Chocolatey Options
- `-y` - Assume yes to all prompts
- `--force` - Force installation even if already installed
- `--local-only` - List only locally installed packages

---

## Git Configuration

### Initial Setup
```powershell
# Set global configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Check configuration
git config --list

# Check version
git --version
```

**Expected Output:**
```
git version 2.42.0.windows.2
```

---

## Docker Commands

### Basic Docker Operations
```powershell
# Check Docker version
docker --version

# Check Docker info
docker info

# Test Docker installation
docker run hello-world
```

**Expected Output:**
```
Docker version 24.0.7, build afdd53b
```

---

## Verification Commands

### Check All Installations
```powershell
# PowerShell version
$PSVersionTable.PSVersion

# Installed applications
winget list

# WSL distributions
wsl --list --verbose

# Node.js ecosystem
node --version
npm --version

# Development tools
git --version
docker --version
code --version
```

### System Information
```powershell
# Windows version
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion

# Enabled Windows features
Get-WindowsOptionalFeature -Online | Where-Object {$_.State -eq "Enabled"}

# PowerShell execution policy
Get-ExecutionPolicy -List
```

---

## Troubleshooting Commands

### Common Fixes
```powershell
# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Reset PowerShell execution policy
Set-ExecutionPolicy -ExecutionPolicy Default -Scope CurrentUser

# Check Windows Update
Get-WindowsUpdate

# Restart Windows services
Restart-Service winmgmt
```

### Error Checking
```powershell
# Check last exit code
echo $LASTEXITCODE

# Check Windows event logs
Get-WinEvent -LogName Application -MaxEvents 10

# Test network connectivity
Test-NetConnection -ComputerName "github.com" -Port 443
```
