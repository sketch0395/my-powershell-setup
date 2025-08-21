#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Automated Windows Computer Setup Script
    
.DESCRIPTION
    This PowerShell script automates the setup of a Windows development environment including:
    - PowerShell 7 and Windows Terminal installation
    - Windows Features (Hyper-V, WSL, Virtual Machine Platform)
    - WSL setup with Kali Linux and Ubuntu distributions
    - Power configuration settings
    - Development tools (VS Code, Git, GitHub Desktop, Docker, Node.js, Obsidian)
    - Kali Linux tools installation
    
.NOTES
    Author: Generated for automated computer setup
    Date: August 21, 2025
    Requires: Administrator privileges
    
.EXAMPLE
    .\Setup-Automation.ps1
    Runs the complete automated setup process
#>

# Function to log output with timestamps
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $(
        switch ($Level) {
            "INFO" { "Green" }
            "WARN" { "Yellow" }
            "ERROR" { "Red" }
            default { "White" }
        }
    )
}

# Function to check if command succeeded
function Test-CommandSuccess {
    param([int]$ExitCode, [string]$CommandName)
    if ($ExitCode -eq 0) {
        Write-Log "✓ $CommandName completed successfully" "INFO"
        return $true
    } else {
        Write-Log "✗ $CommandName failed with exit code: $ExitCode" "ERROR"
        return $false
    }
}

# Function to check if a package is already installed via winget
function Test-WingetPackageInstalled {
    param([string]$PackageId)
    try {
        $result = winget list --id $PackageId --exact 2>$null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# Function to check if WSL is installed and configured
function Test-WSLInstalled {
    try {
        $wslVersion = wsl --status 2>$null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# Function to check if a WSL distribution is installed
function Test-WSLDistributionInstalled {
    param([string]$DistroName)
    try {
        $distros = wsl --list --quiet 2>$null
        return $distros -contains $DistroName
    } catch {
        return $false
    }
}

# Function to check if Node.js is installed
function Test-NodeInstalled {
    try {
        $null = node --version 2>$null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# Function to prompt user for installation choice
function Get-UserChoice {
    param([string]$ComponentName, [string]$Description)
    
    Write-Host ""
    Write-Host "=== $ComponentName Installation ===" -ForegroundColor Cyan
    Write-Host $Description -ForegroundColor White
    Write-Host ""
    
    do {
        $choice = Read-Host "Do you want to install $ComponentName? (Y/N)"
        $choice = $choice.ToUpper()
    } while ($choice -ne "Y" -and $choice -ne "N")
    
    return $choice -eq "Y"
}

Write-Log "Starting Automated Windows Computer Setup" "INFO"

Write-Host ""
Write-Host "======== AUTOMATED WINDOWS SETUP SCRIPT ========" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  • Install PowerShell 7 and Windows Terminal (Always)" -ForegroundColor White
Write-Host "  • Enable Windows Features for virtualization (Always)" -ForegroundColor White
Write-Host "  • Configure power settings (Always)" -ForegroundColor White
Write-Host "  • Check for existing installations and skip if found" -ForegroundColor Green
Write-Host "  • Prompt you for optional components:" -ForegroundColor Yellow
Write-Host "    - WSL (Windows Subsystem for Linux)" -ForegroundColor White
Write-Host "    - Kali Linux distribution" -ForegroundColor White
Write-Host "    - Ubuntu distribution" -ForegroundColor White
Write-Host "    - Visual Studio Code" -ForegroundColor White
Write-Host "    - GitHub Desktop" -ForegroundColor White
Write-Host "    - Docker Desktop" -ForegroundColor White
Write-Host "    - Node.js and npm" -ForegroundColor White
Write-Host "    - Chocolatey package manager" -ForegroundColor White
Write-Host "    - Next.js framework" -ForegroundColor White
Write-Host "    - Obsidian note-taking app" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to continue or Ctrl+C to cancel..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

# =============================================================================
# SECTION 1: Install PowerShell 7 and Windows Terminal
# =============================================================================
Write-Log "Installing PowerShell 7 and Windows Terminal..." "INFO"

# Expected Output: Found PowerShell [Microsoft.PowerShell] ... Successfully installed
# Options: -e (exact match), --silent (no prompts), --accept-package-agreements
Write-Log "Installing PowerShell 7..." "INFO"
winget install --id Microsoft.PowerShell --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "PowerShell 7 Installation"

# Expected Output: Found Windows Terminal [Microsoft.WindowsTerminal] ... Successfully installed
Write-Log "Installing Windows Terminal..." "INFO"
winget install --id Microsoft.WindowsTerminal --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "Windows Terminal Installation"

# =============================================================================
# SECTION 2: Enable Windows Features for Virtualization and WSL
# =============================================================================
Write-Log "Enabling Windows Features for virtualization and WSL..." "INFO"

# Expected Output: Deployment Image Servicing and Management tool ... The operation completed successfully.
# Options: /All (enables all parent features), /NoRestart (prevents automatic restart)
Write-Log "Enabling Hyper-V..." "INFO"
Dism /online /Enable-Feature /FeatureName:Microsoft-hyper-v /All /NoRestart
Test-CommandSuccess $LASTEXITCODE "Hyper-V Feature Enable"

Write-Log "Enabling Hypervisor Platform..." "INFO"
Dism /online /Enable-Feature /FeatureName:HypervisorPlatform /All /NoRestart
Test-CommandSuccess $LASTEXITCODE "Hypervisor Platform Feature Enable"

Write-Log "Enabling Virtual Machine Platform..." "INFO"
Dism /online /Enable-Feature /FeatureName:VirtualMachinePlatform /All /NoRestart
Test-CommandSuccess $LASTEXITCODE "Virtual Machine Platform Feature Enable"

Write-Log "Enabling Windows Subsystem for Linux..." "INFO"
Dism /online /Enable-Feature /FeatureName:Microsoft-Windows-Subsystem-Linux /All /NoRestart
Test-CommandSuccess $LASTEXITCODE "WSL Feature Enable"

# =============================================================================
# SECTION 3: Setup WSL and Install Linux Distributions (Optional)
# =============================================================================
Write-Log "Checking WSL installation status..." "INFO"

$installWSL = $false
$installKali = $false
$installUbuntu = $false

# Check if WSL is already installed
if (Test-WSLInstalled) {
    Write-Log "WSL is already installed and configured" "INFO"
    
    # Check individual distributions
    if (Test-WSLDistributionInstalled "kali-linux") {
        Write-Log "Kali Linux is already installed" "INFO"
    } else {
        $installKali = Get-UserChoice "Kali Linux" "Kali Linux is a Debian-based Linux distribution designed for digital forensics and penetration testing."
    }
    
    if (Test-WSLDistributionInstalled "Ubuntu") {
        Write-Log "Ubuntu is already installed" "INFO"
    } else {
        $installUbuntu = Get-UserChoice "Ubuntu" "Ubuntu is a popular Linux distribution based on Debian, great for development and general use."
    }
} else {
    $installWSL = Get-UserChoice "WSL (Windows Subsystem for Linux)" "WSL lets developers run a GNU/Linux environment directly on Windows, unmodified, without the overhead of a traditional virtual machine."
    
    if ($installWSL) {
        $installKali = Get-UserChoice "Kali Linux" "Kali Linux is a Debian-based Linux distribution designed for digital forensics and penetration testing."
        $installUbuntu = Get-UserChoice "Ubuntu" "Ubuntu is a popular Linux distribution based on Debian, great for development and general use."
    }
}

if ($installWSL -or $installKali -or $installUbuntu) {
    Write-Log "Setting up WSL and installing Linux distributions..." "INFO"

    if ($installWSL) {
        # Expected Output: Installing: Virtual Machine Platform ... Changes will not be effective until the system is rebooted.
        # Options: --install -d <Distro> (install specific distribution)
        Write-Log "Installing WSL..." "INFO"
        wsl --install --no-launch
        Test-CommandSuccess $LASTEXITCODE "WSL Install"

        # Expected Output: Checking for updates... The WSL 2 kernel is up to date.
        Write-Log "Updating WSL..." "INFO"
        wsl --update
        Test-CommandSuccess $LASTEXITCODE "WSL Update"

        # Expected Output: Default version set to 2.
        Write-Log "Setting WSL default version to 2..." "INFO"
        wsl --set-default-version 2
        Test-CommandSuccess $LASTEXITCODE "WSL Default Version Set"
    }

    # List available distributions: wsl --list --online
    # Expected Output: Downloading: Kali-Linux ... The operation completed successfully.
    if ($installKali) {
        Write-Log "Installing Kali Linux distribution..." "INFO"
        wsl --install -d Kali-Linux --no-launch
        Test-CommandSuccess $LASTEXITCODE "Kali Linux Installation"
    }

    if ($installUbuntu) {
        Write-Log "Installing Ubuntu distribution..." "INFO"
        wsl --install -d Ubuntu --no-launch
        Test-CommandSuccess $LASTEXITCODE "Ubuntu Installation"
    }
} else {
    Write-Log "Skipping WSL installation per user choice" "INFO"
}

# =============================================================================
# SECTION 4: Configure Power Settings
# =============================================================================
Write-Log "Configuring power settings..." "INFO"

# Expected Output: No output if successful
# Options: -change monitor-timeout-ac/dc <minutes>, -change standby-timeout-ac/dc <minutes>
Write-Log "Setting monitor timeout (AC) to never..." "INFO"
powercfg -change monitor-timeout-ac 0
Test-CommandSuccess $LASTEXITCODE "Monitor Timeout AC"

Write-Log "Setting monitor timeout (DC) to 10 minutes..." "INFO"
powercfg -change monitor-timeout-dc 10
Test-CommandSuccess $LASTEXITCODE "Monitor Timeout DC"

Write-Log "Setting standby timeout (AC) to never..." "INFO"
powercfg -change standby-timeout-ac 0
Test-CommandSuccess $LASTEXITCODE "Standby Timeout AC"

Write-Log "Setting standby timeout (DC) to never..." "INFO"
powercfg -change standby-timeout-dc 0
Test-CommandSuccess $LASTEXITCODE "Standby Timeout DC"

# =============================================================================
# SECTION 5: Install Development Tools (Optional)
# =============================================================================
Write-Log "Checking development tools installation status..." "INFO"

# Check and prompt for VS Code
$installVSCode = $false
if (Test-WingetPackageInstalled "Microsoft.VisualStudioCode") {
    Write-Log "Visual Studio Code is already installed" "INFO"
} else {
    $installVSCode = Get-UserChoice "Visual Studio Code" "Visual Studio Code is a lightweight but powerful source code editor with support for debugging, Git control, and extensions."
}

# Always install Git and GitHub Desktop for development workflow
Write-Log "Installing essential development tools..." "INFO"

if ($installVSCode) {
    # Expected Output: Found <AppName> [<AppId>] ... Successfully installed
    # Options: --silent (no prompts), --accept-package-agreements, --accept-source-agreements
    Write-Log "Installing Visual Studio Code..." "INFO"
    winget install --id Microsoft.VisualStudioCode --source winget -e --accept-package-agreements --accept-source-agreements
    Test-CommandSuccess $LASTEXITCODE "VS Code Installation"
}

# Check and install Git
if (Test-WingetPackageInstalled "Git.Git") {
    Write-Log "Git is already installed" "INFO"
} else {
    Write-Log "Installing Git..." "INFO"
    winget install --id Git.Git --source winget -e --accept-package-agreements --accept-source-agreements
    Test-CommandSuccess $LASTEXITCODE "Git Installation"
}

# Check and prompt for GitHub Desktop
if (Test-WingetPackageInstalled "GitHub.GitHubDesktop") {
    Write-Log "GitHub Desktop is already installed" "INFO"
} else {
    $installGitHubDesktop = Get-UserChoice "GitHub Desktop" "GitHub Desktop is a GUI application for managing Git repositories and GitHub workflows."
    if ($installGitHubDesktop) {
        Write-Log "Installing GitHub Desktop..." "INFO"
        winget install --id GitHub.GitHubDesktop --source winget -e --accept-package-agreements --accept-source-agreements
        Test-CommandSuccess $LASTEXITCODE "GitHub Desktop Installation"
    }
}

# Check and prompt for Docker Desktop
if (Test-WingetPackageInstalled "Docker.DockerDesktop") {
    Write-Log "Docker Desktop is already installed" "INFO"
} else {
    $installDocker = Get-UserChoice "Docker Desktop" "Docker Desktop enables you to build, test, and deploy containerized applications on Windows."
    if ($installDocker) {
        Write-Log "Installing Docker Desktop..." "INFO"
        winget install --id Docker.DockerDesktop --source winget -e --accept-package-agreements --accept-source-agreements
        Test-CommandSuccess $LASTEXITCODE "Docker Desktop Installation"
    }
}

# Check and prompt for Obsidian
if (Test-WingetPackageInstalled "Obsidian.Obsidian") {
    Write-Log "Obsidian is already installed" "INFO"
} else {
    $installObsidian = Get-UserChoice "Obsidian" "Obsidian is a powerful knowledge base and note-taking application that works on top of your local folder of plain text Markdown files."
    if ($installObsidian) {
        Write-Log "Installing Obsidian..." "INFO"
        winget install --id Obsidian.Obsidian --source winget -e --accept-package-agreements --accept-source-agreements
        Test-CommandSuccess $LASTEXITCODE "Obsidian Installation"
    }
}

# =============================================================================
# SECTION 6: Install Node.js and Package Managers (Optional)
# =============================================================================
Write-Log "Checking Node.js installation status..." "INFO"

$installNodeJS = $false
$installChocolatey = $false

# Check if Node.js is already installed
if (Test-NodeInstalled) {
    Write-Log "Node.js is already installed" "INFO"
    try {
        $nodeVersion = node --version
        Write-Log "Current Node.js version: $nodeVersion" "INFO"
    } catch {
        Write-Log "Could not determine Node.js version" "WARN"
    }
} else {
    $installNodeJS = Get-UserChoice "Node.js" "Node.js is a JavaScript runtime built on Chrome V8 JavaScript engine, essential for modern web development."
}

# Check if Chocolatey is already installed
if (Test-WingetPackageInstalled "Chocolatey.Chocolatey") {
    Write-Log "Chocolatey is already installed" "INFO"
} else {
    $installChocolatey = Get-UserChoice "Chocolatey" "Chocolatey is a package manager for Windows that simplifies software installation and management."
}

if ($installNodeJS -or $installChocolatey) {
    Write-Log "Installing Node.js and package managers..." "INFO"

    if ($installNodeJS) {
        # Expected Output: Found NodeJS [OpenJS.NodeJS] ... Successfully installed
        Write-Log "Installing Node.js..." "INFO"
        winget install --id OpenJS.NodeJS --source winget -e --accept-package-agreements --accept-source-agreements
        Test-CommandSuccess $LASTEXITCODE "Node.js Installation"
    }

    if ($installChocolatey) {
        Write-Log "Installing Chocolatey..." "INFO"
        winget install --id Chocolatey.Chocolatey --source winget -e --accept-package-agreements --accept-source-agreements
        Test-CommandSuccess $LASTEXITCODE "Chocolatey Installation"
    }

    # Refresh environment variables to use newly installed tools
    Write-Log "Refreshing environment variables..." "INFO"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    if ($installNodeJS -and $installChocolatey) {
        # Expected Output for choco: Chocolatey vX.X.X ... The install of nodejs.install was successful.
        # Options: -y (accept all prompts)
        Write-Log "Installing Node.js via Chocolatey (backup method)..." "INFO"
        try {
            choco install nodejs.install -y
            Test-CommandSuccess $LASTEXITCODE "Node.js Chocolatey Installation"
        } catch {
            Write-Log "Chocolatey installation skipped or failed: $($_.Exception.Message)" "WARN"
        }
    }
} else {
    Write-Log "Skipping Node.js and package managers installation per user choice" "INFO"
}

# =============================================================================
# SECTION 7: Configure PowerShell and Install Global npm Packages (Optional)
# =============================================================================
Write-Log "Configuring PowerShell execution policy..." "INFO"

# Expected Output: No output if successful
# Options: -Scope (CurrentUser, LocalMachine), -Force (suppress confirmation)
Write-Log "Setting PowerShell execution policy..." "INFO"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
Test-CommandSuccess $LASTEXITCODE "PowerShell Execution Policy"

# Only configure npm if Node.js was installed or is already present
if (Test-NodeInstalled) {
    Write-Log "Configuring npm and installing global packages..." "INFO"
    
    # Expected Output: + npm@X.X.X added X packages
    # Options: -g (global install)
    Write-Log "Updating npm globally..." "INFO"
    try {
        npm install -g npm
        Test-CommandSuccess $LASTEXITCODE "npm Global Update"
    } catch {
        Write-Log "npm update failed: $($_.Exception.Message)" "WARN"
    }

    $installNext = Get-UserChoice "Next.js" "Next.js is a React framework for building full-stack web applications with modern features."
    if ($installNext) {
        Write-Log "Installing Next.js globally..." "INFO"
        try {
            npm install -g next
            Test-CommandSuccess $LASTEXITCODE "Next.js Global Installation"
        } catch {
            Write-Log "Next.js installation failed: $($_.Exception.Message)" "WARN"
        }
    }
} else {
    Write-Log "Skipping npm configuration - Node.js not installed" "INFO"
}

# =============================================================================
# SECTION 8: Configure WSL Distributions (Optional)
# =============================================================================
if (Test-WSLInstalled) {
    Write-Log "Configuring WSL distributions..." "INFO"

    # Check if Kali Linux is installed and configure it
    if (Test-WSLDistributionInstalled "kali-linux") {
        $configureKali = Get-UserChoice "Kali Linux Configuration" "Update and install web tools in Kali Linux? This will run apt update, upgrade, and install kali-tools-web."
        
        if ($configureKali) {
            # Expected Output for update/upgrade: Get:1 http://kali.download/kali ... Building dependency tree... Done
            # Options: -y (assume yes for all prompts)
            Write-Log "Updating and upgrading Kali Linux..." "INFO"
            try {
                wsl -d kali-linux -- bash -c "sudo apt update && sudo apt full-upgrade -y"
                Test-CommandSuccess $LASTEXITCODE "Kali Linux Update/Upgrade"
            } catch {
                Write-Log "Kali Linux update failed - distribution may not be ready yet" "WARN"
            }

            # Expected Output: Reading package lists... Done ... The following NEW packages will be installed: kali-tools-web
            Write-Log "Installing Kali web tools..." "INFO"
            try {
                wsl -d kali-linux -- bash -c "sudo apt install -y kali-tools-web"
                Test-CommandSuccess $LASTEXITCODE "Kali Web Tools Installation"
            } catch {
                Write-Log "Kali web tools installation failed - distribution may not be ready yet" "WARN"
            }
        }
    }

    # Check if Ubuntu is installed and offer basic configuration
    if (Test-WSLDistributionInstalled "Ubuntu") {
        $configureUbuntu = Get-UserChoice "Ubuntu Configuration" "Update Ubuntu packages? This will run apt update and upgrade."
        
        if ($configureUbuntu) {
            Write-Log "Updating Ubuntu..." "INFO"
            try {
                wsl -d Ubuntu -- bash -c "sudo apt update && sudo apt upgrade -y"
                Test-CommandSuccess $LASTEXITCODE "Ubuntu Update/Upgrade"
            } catch {
                Write-Log "Ubuntu update failed - distribution may not be ready yet" "WARN"
            }
        }
    }
} else {
    Write-Log "Skipping WSL configuration - WSL not installed" "INFO"
}

# =============================================================================
# COMPLETION AND NEXT STEPS
# =============================================================================
Write-Log "Automated setup completed!" "INFO"

Write-Host ""
Write-Host "==================== SETUP COMPLETE ====================" -ForegroundColor Green
Write-Host ""
Write-Host "The following components were processed:" -ForegroundColor Cyan
Write-Host "  ✓ PowerShell 7 (Always installed)" -ForegroundColor Green
Write-Host "  ✓ Windows Terminal (Always installed)" -ForegroundColor Green
Write-Host "  ✓ Windows Features (Hyper-V, WSL, Virtual Machine Platform)" -ForegroundColor Green
Write-Host "  ✓ Power settings configured" -ForegroundColor Green
Write-Host "  ✓ Git (Always installed)" -ForegroundColor Green

# Show conditional installations
if ($installWSL -or (Test-WSLInstalled)) {
    Write-Host "  ✓ WSL (Windows Subsystem for Linux)" -ForegroundColor Green
}
if ($installKali -or (Test-WSLDistributionInstalled "kali-linux")) {
    Write-Host "  ✓ Kali Linux distribution" -ForegroundColor Green
}
if ($installUbuntu -or (Test-WSLDistributionInstalled "Ubuntu")) {
    Write-Host "  ✓ Ubuntu distribution" -ForegroundColor Green
}
if ($installVSCode -or (Test-WingetPackageInstalled "Microsoft.VisualStudioCode")) {
    Write-Host "  ✓ Visual Studio Code" -ForegroundColor Green
}
if (Test-WingetPackageInstalled "GitHub.GitHubDesktop") {
    Write-Host "  ✓ GitHub Desktop" -ForegroundColor Green
}
if (Test-WingetPackageInstalled "Docker.DockerDesktop") {
    Write-Host "  ✓ Docker Desktop" -ForegroundColor Green
}
if ($installNodeJS -or (Test-NodeInstalled)) {
    Write-Host "  ✓ Node.js and npm" -ForegroundColor Green
}
if ($installChocolatey -or (Test-WingetPackageInstalled "Chocolatey.Chocolatey")) {
    Write-Host "  ✓ Chocolatey package manager" -ForegroundColor Green
}
if (Test-WingetPackageInstalled "Obsidian.Obsidian") {
    Write-Host "  ✓ Obsidian note-taking app" -ForegroundColor Green
}

Write-Host ""
Write-Host "IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. RESTART YOUR COMPUTER to complete Windows Features installation" -ForegroundColor Yellow

if ($installWSL -or $installKali -or $installUbuntu) {
    Write-Host "  2. After restart, launch WSL distributions to complete their setup:" -ForegroundColor Yellow
    if ($installKali -or (Test-WSLDistributionInstalled "kali-linux")) {
        Write-Host "     - wsl -d kali-linux" -ForegroundColor White
    }
    if ($installUbuntu -or (Test-WSLDistributionInstalled "Ubuntu")) {
        Write-Host "     - wsl -d Ubuntu" -ForegroundColor White
    }
}

Write-Host "  3. Configure Git with your credentials:" -ForegroundColor Yellow
Write-Host "     - git config --global user.name 'Your Name'" -ForegroundColor White
Write-Host "     - git config --global user.email 'your.email@example.com'" -ForegroundColor White

if (Test-WingetPackageInstalled "Docker.DockerDesktop") {
    Write-Host "  4. Start Docker Desktop from the Start menu" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green

# Create a summary log file
$installedApps = @()
$installedApps += "PowerShell 7 (Microsoft.PowerShell)"
$installedApps += "Windows Terminal (Microsoft.WindowsTerminal)"
$installedApps += "Git (Git.Git)"

if ($installVSCode -or (Test-WingetPackageInstalled "Microsoft.VisualStudioCode")) {
    $installedApps += "Visual Studio Code (Microsoft.VisualStudioCode)"
}
if (Test-WingetPackageInstalled "GitHub.GitHubDesktop") {
    $installedApps += "GitHub Desktop (GitHub.GitHubDesktop)"
}
if (Test-WingetPackageInstalled "Docker.DockerDesktop") {
    $installedApps += "Docker Desktop (Docker.DockerDesktop)"
}
if ($installNodeJS -or (Test-NodeInstalled)) {
    $installedApps += "Node.js (OpenJS.NodeJS)"
}
if ($installChocolatey -or (Test-WingetPackageInstalled "Chocolatey.Chocolatey")) {
    $installedApps += "Chocolatey (Chocolatey.Chocolatey)"
}
if (Test-WingetPackageInstalled "Obsidian.Obsidian") {
    $installedApps += "Obsidian (Obsidian.Obsidian)"
}

$installedDistros = @()
if ($installKali -or (Test-WSLDistributionInstalled "kali-linux")) {
    $installedDistros += "Kali-Linux"
}
if ($installUbuntu -or (Test-WSLDistributionInstalled "Ubuntu")) {
    $installedDistros += "Ubuntu"
}

$logContent = "Windows Automated Setup Summary`nGenerated: $(Get-Date)`n`n"
$logContent += "Installed Applications:`n"
$logContent += ($installedApps | ForEach-Object { "- $_" }) -join "`n"

$logContent += "`n`nEnabled Windows Features:`n"
$logContent += "- Microsoft-hyper-v`n"
$logContent += "- HypervisorPlatform`n"
$logContent += "- VirtualMachinePlatform`n"
$logContent += "- Microsoft-Windows-Subsystem-Linux`n"

$logContent += "`nWSL Distributions Installed:`n"
if ($installedDistros.Count -gt 0) {
    $logContent += ($installedDistros | ForEach-Object { "- $_" }) -join "`n"
} else {
    $logContent += "- None"
}

$logContent += "`n`nPower Settings Configured:`n"
$logContent += "- Monitor timeout (AC): Never`n"
$logContent += "- Monitor timeout (DC): 10 minutes`n"
$logContent += "- Standby timeout (AC): Never`n"
$logContent += "- Standby timeout (DC): Never`n"

# Add conditional sections
if (Test-NodeInstalled) {
    $logContent += "`n`nGlobal npm Packages:`n- npm (latest)"
    if ($installNext) {
        $logContent += "`n- next (latest)"
    }
}

if (Test-WSLDistributionInstalled "kali-linux") {
    $logContent += "`n`nKali Linux Tools:`n- kali-tools-web (if configured)"
}

$logContent += "`n`nNext Steps Required:`n1. Restart computer"
if ($installedDistros.Count -gt 0) {
    $logContent += "`n2. Launch and configure WSL distributions"
}
$logContent += "`n3. Configure Git credentials"
if (Test-WingetPackageInstalled "Docker.DockerDesktop") {
    $logContent += "`n4. Start Docker Desktop"
}

$logContent | Out-File -FilePath ".\setup-summary.log" -Encoding UTF8
Write-Log "Setup summary saved to: setup-summary.log" "INFO"
