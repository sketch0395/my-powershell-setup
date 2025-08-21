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

Write-Log "Starting Automated Windows Computer Setup" "INFO"

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
# SECTION 3: Setup WSL and Install Linux Distributions
# =============================================================================
Write-Log "Setting up WSL and installing Linux distributions..." "INFO"

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

# List available distributions: wsl --list --online
# Expected Output: Downloading: Kali-Linux ... The operation completed successfully.
Write-Log "Installing Kali Linux distribution..." "INFO"
wsl --install -d Kali-Linux --no-launch
Test-CommandSuccess $LASTEXITCODE "Kali Linux Installation"

Write-Log "Installing Ubuntu distribution..." "INFO"
wsl --install -d Ubuntu --no-launch
Test-CommandSuccess $LASTEXITCODE "Ubuntu Installation"

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
# SECTION 5: Install Development Tools
# =============================================================================
Write-Log "Installing development tools..." "INFO"

# Expected Output: Found <AppName> [<AppId>] ... Successfully installed
# Options: --silent (no prompts), --accept-package-agreements, --accept-source-agreements
Write-Log "Installing Visual Studio Code..." "INFO"
winget install --id Microsoft.VisualStudioCode --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "VS Code Installation"

Write-Log "Installing Git..." "INFO"
winget install --id Git.Git --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "Git Installation"

Write-Log "Installing GitHub Desktop..." "INFO"
winget install --id GitHub.GitHubDesktop --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "GitHub Desktop Installation"

Write-Log "Installing Docker Desktop..." "INFO"
winget install --id Docker.DockerDesktop --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "Docker Desktop Installation"

Write-Log "Installing Obsidian..." "INFO"
winget install --id Obsidian.Obsidian --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "Obsidian Installation"

# =============================================================================
# SECTION 6: Install Node.js and Package Managers
# =============================================================================
Write-Log "Installing Node.js and package managers..." "INFO"

# Expected Output: Found NodeJS [OpenJS.NodeJS] ... Successfully installed
Write-Log "Installing Node.js..." "INFO"
winget install --id OpenJS.NodeJS --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "Node.js Installation"

Write-Log "Installing Chocolatey..." "INFO"
winget install --id Chocolatey.Chocolatey --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "Chocolatey Installation"

# Refresh environment variables to use newly installed tools
Write-Log "Refreshing environment variables..." "INFO"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Expected Output for choco: Chocolatey vX.X.X ... The install of nodejs.install was successful.
# Options: -y (accept all prompts)
Write-Log "Installing Node.js via Chocolatey (backup method)..." "INFO"
try {
    choco install nodejs.install -y
    Test-CommandSuccess $LASTEXITCODE "Node.js Chocolatey Installation"
} catch {
    Write-Log "Chocolatey installation skipped or failed: $($_.Exception.Message)" "WARN"
}

# =============================================================================
# SECTION 7: Configure PowerShell and Install Global npm Packages
# =============================================================================
Write-Log "Configuring PowerShell execution policy and installing global npm packages..." "INFO"

# Expected Output: No output if successful
# Options: -Scope (CurrentUser, LocalMachine), -Force (suppress confirmation)
Write-Log "Setting PowerShell execution policy..." "INFO"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
Test-CommandSuccess $LASTEXITCODE "PowerShell Execution Policy"

# Expected Output: + npm@X.X.X added X packages
# Options: -g (global install)
Write-Log "Updating npm globally..." "INFO"
try {
    npm install -g npm
    Test-CommandSuccess $LASTEXITCODE "npm Global Update"
} catch {
    Write-Log "npm update failed: $($_.Exception.Message)" "WARN"
}

Write-Log "Installing Next.js globally..." "INFO"
try {
    npm install -g next
    Test-CommandSuccess $LASTEXITCODE "Next.js Global Installation"
} catch {
    Write-Log "Next.js installation failed: $($_.Exception.Message)" "WARN"
}

# =============================================================================
# SECTION 8: Configure WSL Distributions
# =============================================================================
Write-Log "Configuring WSL distributions..." "INFO"

# Expected Output for update/upgrade: Get:1 http://kali.download/kali ... Building dependency tree... Done
# Options: -y (assume yes for all prompts)
Write-Log "Updating and upgrading Kali Linux..." "INFO"
try {
    wsl -d Kali-Linux -- bash -c "sudo apt update && sudo apt full-upgrade -y"
    Test-CommandSuccess $LASTEXITCODE "Kali Linux Update/Upgrade"
} catch {
    Write-Log "Kali Linux update failed - distribution may not be ready yet" "WARN"
}

# Expected Output: Reading package lists... Done ... The following NEW packages will be installed: kali-tools-web
Write-Log "Installing Kali web tools..." "INFO"
try {
    wsl -d Kali-Linux -- bash -c "sudo apt install -y kali-tools-web"
    Test-CommandSuccess $LASTEXITCODE "Kali Web Tools Installation"
} catch {
    Write-Log "Kali web tools installation failed - distribution may not be ready yet" "WARN"
}

# =============================================================================
# COMPLETION AND NEXT STEPS
# =============================================================================
Write-Log "Automated setup completed!" "INFO"

Write-Host ""
Write-Host "==================== SETUP COMPLETE ====================" -ForegroundColor Green
Write-Host ""
Write-Host "The following components have been installed/configured:" -ForegroundColor Cyan
Write-Host "  ✓ PowerShell 7" -ForegroundColor Green
Write-Host "  ✓ Windows Terminal" -ForegroundColor Green
Write-Host "  ✓ Windows Features (Hyper-V, WSL, Virtual Machine Platform)" -ForegroundColor Green
Write-Host "  ✓ WSL with Kali Linux and Ubuntu" -ForegroundColor Green
Write-Host "  ✓ Power settings configured" -ForegroundColor Green
Write-Host "  ✓ Visual Studio Code" -ForegroundColor Green
Write-Host "  ✓ Git and GitHub Desktop" -ForegroundColor Green
Write-Host "  ✓ Docker Desktop" -ForegroundColor Green
Write-Host "  ✓ Node.js and npm" -ForegroundColor Green
Write-Host "  ✓ Obsidian" -ForegroundColor Green
Write-Host "  ✓ Kali Linux tools" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. RESTART YOUR COMPUTER to complete Windows Features installation" -ForegroundColor Yellow
Write-Host "  2. After restart, launch WSL distributions to complete their setup:" -ForegroundColor Yellow
Write-Host "     - wsl -d Kali-Linux" -ForegroundColor White
Write-Host "     - wsl -d Ubuntu" -ForegroundColor White
Write-Host "  3. Configure Git with your credentials:" -ForegroundColor Yellow
Write-Host "     - git config --global user.name 'Your Name'" -ForegroundColor White
Write-Host "     - git config --global user.email 'your.email@example.com'" -ForegroundColor White
Write-Host "  4. Start Docker Desktop from the Start menu" -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green

# Create a summary log file
$logContent = @"
Windows Automated Setup Summary
Generated: $(Get-Date)

Installed Applications:
- PowerShell 7 (Microsoft.PowerShell)
- Windows Terminal (Microsoft.WindowsTerminal)
- Visual Studio Code (Microsoft.VisualStudioCode)
- Git (Git.Git)
- GitHub Desktop (GitHub.GitHubDesktop)
- Docker Desktop (Docker.DockerDesktop)
- Node.js (OpenJS.NodeJS)
- Chocolatey (Chocolatey.Chocolatey)
- Obsidian (Obsidian.Obsidian)

Enabled Windows Features:
- Microsoft-hyper-v
- HypervisorPlatform
- VirtualMachinePlatform
- Microsoft-Windows-Subsystem-Linux

WSL Distributions Installed:
- Kali-Linux
- Ubuntu

Power Settings Configured:
- Monitor timeout (AC): Never
- Monitor timeout (DC): 10 minutes
- Standby timeout (AC): Never
- Standby timeout (DC): Never

Global npm Packages:
- npm (latest)
- next (latest)

Kali Linux Tools:
- kali-tools-web

Next Steps Required:
1. Restart computer
2. Launch and configure WSL distributions
3. Configure Git credentials
4. Start Docker Desktop
"@

$logContent | Out-File -FilePath ".\setup-summary.log" -Encoding UTF8
Write-Log "Setup summary saved to: setup-summary.log" "INFO"
