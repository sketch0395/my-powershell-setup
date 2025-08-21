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
    Author: Generated for automated computer s# =============================================================================
# SECTION 5: Configure Power Settings
# =============================================================================ugust 21, 2025
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

# Function to prompt user for category selection
function Get-CategoryChoices {
    Write-Host ""
    Write-Host "========== INSTALLATION CATEGORIES ==========" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select the categories you want to install:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[E] Essential      - Core utilities (PowerToys, 7-Zip, VLC, TreeSize, Obsidian)" -ForegroundColor White
    Write-Host "[D] Developer      - Programming tools (VS Code, Firefox Dev, Windows Terminal, Git, Docker)" -ForegroundColor White
    Write-Host "[C] Creative       - Media & design tools (Figma, OBS Studio, GIMP, Discord)" -ForegroundColor White
    Write-Host "[S] Security       - Privacy & security tools (Malwarebytes, Wireshark, VPN)" -ForegroundColor White
    Write-Host "[A] All Categories - Install everything" -ForegroundColor Green
    Write-Host "[N] None           - Skip category installation" -ForegroundColor Red
    Write-Host ""
    
    $validChoices = @('E', 'D', 'C', 'S', 'A', 'N')
    $selectedCategories = @()
    
    do {
        $choice = Read-Host "Enter categories (e.g., 'EDC' for Essential+Developer+Creative) or single choice"
        $choice = $choice.ToUpper()
        
        if ($choice -eq 'A') {
            $selectedCategories = @('E', 'D', 'C', 'S')
            break
        } elseif ($choice -eq 'N') {
            $selectedCategories = @()
            break
        } else {
            $selectedCategories = $choice.ToCharArray() | Where-Object { $_ -in $validChoices }
            if ($selectedCategories.Count -gt 0) {
                break
            }
        }
        
        Write-Host "Invalid choice. Please enter valid category letters (E, D, C, G, S, O, A, or N)" -ForegroundColor Red
    } while ($true)
    
    return $selectedCategories
}

# Function to enable OpenSSH
function Enable-OpenSSH {
    Write-Log "Enabling OpenSSH Client and Server..." "INFO"
    
    # Enable OpenSSH Client
    $sshClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
    if ($sshClient.State -ne "Installed") {
        Add-WindowsCapability -Online -Name $sshClient.Name
        Test-CommandSuccess $LASTEXITCODE "OpenSSH Client Installation"
    } else {
        Write-Log "OpenSSH Client already installed" "INFO"
    }
    
    # Enable OpenSSH Server
    $sshServer = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
    if ($sshServer.State -ne "Installed") {
        Add-WindowsCapability -Online -Name $sshServer.Name
        Test-CommandSuccess $LASTEXITCODE "OpenSSH Server Installation"
        
        # Start and enable SSH service
        Start-Service sshd
        Set-Service -Name sshd -StartupType 'Automatic'
        Test-CommandSuccess $LASTEXITCODE "OpenSSH Service Configuration"
    } else {
        Write-Log "OpenSSH Server already installed" "INFO"
    }
}

# Function to remove Windows bloatware
function Remove-WindowsBloatware {
    Write-Log "Removing Windows bloatware..." "INFO"
    
    $bloatwareApps = @(
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.Xbox.TCUI",
        "Microsoft.BingWeather",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Messaging",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.NetworkSpeedTest",
        "Microsoft.News",
        "Microsoft.Office.Lens",
        "Microsoft.Office.OneNote",
        "Microsoft.Office.Sway",
        "Microsoft.OneConnect",
        "Microsoft.People",
        "Microsoft.Print3D",
        "Microsoft.RemoteDesktop",
        "Microsoft.SkypeApp",
        "Microsoft.StorePurchaseApp",
        "Microsoft.Office.Todo.List",
        "Microsoft.Whiteboard",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCamera",
        "microsoft.windowscommunicationsapps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo"
    )
    
    foreach ($app in $bloatwareApps) {
        try {
            Get-AppxPackage $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            Write-Log "Removed $app" "INFO"
        } catch {
            Write-Log "Could not remove $app" "WARN"
        }
    }
}

# Function to apply system customizations
function Apply-SystemCustomizations {
    Write-Log "Applying system customizations..." "INFO"
    
    # Enable dark mode
    try {
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Null
        Write-Log "Dark mode enabled" "INFO"
    } catch {
        Write-Log "Could not enable dark mode" "WARN"
    }
    
    # File Explorer enhancements
    try {
        # Show file extensions
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f | Out-Null
        # Show hidden files
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f | Out-Null
        # Show system files
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f | Out-Null
        Write-Log "File Explorer enhancements applied" "INFO"
    } catch {
        Write-Log "Could not apply File Explorer enhancements" "WARN"
    }
    
    # Taskbar modifications
    try {
        # Hide search box
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f | Out-Null
        # Hide task view button
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f | Out-Null
        Write-Log "Taskbar modifications applied" "INFO"
    } catch {
        Write-Log "Could not apply taskbar modifications" "WARN"
    }
}

Write-Log "Starting Automated Windows Computer Setup" "INFO"

Write-Host ""
Write-Host "======== AUTOMATED WINDOWS SETUP SCRIPT ========" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  • Install PowerShell 7 (Always)" -ForegroundColor White
Write-Host "  • Enable Windows Features for virtualization (Always)" -ForegroundColor White
Write-Host "  • Setup WSL (Always)" -ForegroundColor White
Write-Host "  • Configure power settings (Always)" -ForegroundColor White
Write-Host "  • Check for existing installations and skip if found" -ForegroundColor Green
Write-Host "  • Install applications based on selected categories:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue or Ctrl+C to cancel..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

# Get user category selections
$selectedCategories = Get-CategoryChoices
Write-Log "Selected categories: $($selectedCategories -join ', ')" "INFO"

# =============================================================================
# SECTION 0: Category-Based Installations
# =============================================================================
if ($selectedCategories.Count -gt 0) {
    Write-Log "Installing selected categories..." "INFO"
    
    # Essential Category
    if ('E' -in $selectedCategories) {
        Write-Log "Installing Essential category..." "INFO"
        
        # PowerToys
        if (-not (Test-WingetPackageInstalled "Microsoft.PowerToys")) {
            winget install --id Microsoft.PowerToys --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "PowerToys Installation"
        }
        
        # 7-Zip
        if (-not (Test-WingetPackageInstalled "7zip.7zip")) {
            winget install --id 7zip.7zip --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "7-Zip Installation"
        }
        
        # VLC Media Player
        if (-not (Test-WingetPackageInstalled "VideoLAN.VLC")) {
            winget install --id VideoLAN.VLC --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "VLC Installation"
        }
        
        # TreeSize
        if (-not (Test-WingetPackageInstalled "JAMSoftware.TreeSize.Free")) {
            winget install --id JAMSoftware.TreeSize.Free --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "TreeSize Installation"
        }
        
        # Obsidian (for general note-taking and knowledge management)
        if (-not (Test-WingetPackageInstalled "Obsidian.Obsidian")) {
            winget install --id Obsidian.Obsidian --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Obsidian Installation"
        }
        
        # System customizations
        Apply-SystemCustomizations
        Remove-WindowsBloatware
        Enable-OpenSSH
    }
    
    # Developer Category
    if ('D' -in $selectedCategories) {
        Write-Log "Installing Developer category..." "INFO"
        
        # Visual Studio Code
        if (-not (Test-WingetPackageInstalled "Microsoft.VisualStudioCode")) {
            winget install --id Microsoft.VisualStudioCode --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "VS Code Installation"
        }
        
        # Git (version control)
        if (-not (Test-WingetPackageInstalled "Git.Git")) {
            winget install --id Git.Git --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Git Installation"
        }
        
        # Windows Terminal
        if (-not (Test-WingetPackageInstalled "Microsoft.WindowsTerminal")) {
            winget install --id Microsoft.WindowsTerminal --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Windows Terminal Installation"
        }
        
        # Firefox Developer Edition
        if (-not (Test-WingetPackageInstalled "Mozilla.Firefox.DeveloperEdition")) {
            winget install --id Mozilla.Firefox.DeveloperEdition --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Firefox Developer Edition Installation"
        }
        
        # GitHub Desktop
        if (-not (Test-WingetPackageInstalled "GitHub.GitHubDesktop")) {
            winget install --id GitHub.GitHubDesktop --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "GitHub Desktop Installation"
        }
        
        # Docker Desktop
        if (-not (Test-WingetPackageInstalled "Docker.DockerDesktop")) {
            winget install --id Docker.DockerDesktop --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Docker Desktop Installation"
        }
        
        # Node.js
        if (-not (Test-WingetPackageInstalled "OpenJS.NodeJS")) {
            winget install --id OpenJS.NodeJS --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Node.js Installation"
        }
        
        # Python
        if (-not (Test-WingetPackageInstalled "Python.Python.3.11")) {
            winget install --id Python.Python.3.11 --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Python Installation"
        }
        
        # Postman
        if (-not (Test-WingetPackageInstalled "Postman.Postman")) {
            winget install --id Postman.Postman --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Postman Installation"
        }
        
        # Notepad++
        if (-not (Test-WingetPackageInstalled "Notepad++.Notepad++")) {
            winget install --id Notepad++.Notepad++ --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Notepad++ Installation"
        }
        
        # Chocolatey package manager
        if (-not (Test-WingetPackageInstalled "Chocolatey.Chocolatey")) {
            winget install --id Chocolatey.Chocolatey --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Chocolatey Installation"
        }
        
        # Ubuntu WSL distribution
        if (-not (Test-WSLDistributionInstalled "Ubuntu")) {
            Write-Log "Installing Ubuntu WSL distribution..." "INFO"
            wsl --install -d Ubuntu --no-launch
            Test-CommandSuccess $LASTEXITCODE "Ubuntu Installation"
        }
    }
    
    # Creative Category
    if ('C' -in $selectedCategories) {
        Write-Log "Installing Creative category..." "INFO"
        
        # Figma Desktop
        if (-not (Test-WingetPackageInstalled "Figma.Figma")) {
            winget install --id Figma.Figma --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Figma Installation"
        }
        
        # OBS Studio
        if (-not (Test-WingetPackageInstalled "OBSProject.OBSStudio")) {
            winget install --id OBSProject.OBSStudio --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "OBS Studio Installation"
        }
        
        # GIMP
        if (-not (Test-WingetPackageInstalled "GIMP.GIMP")) {
            winget install --id GIMP.GIMP --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "GIMP Installation"
        }
        
        # Discord (for creative collaboration)
        if (-not (Test-WingetPackageInstalled "Discord.Discord")) {
            winget install --id Discord.Discord --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Discord Installation"
        }
    }
    
    # Security Category
    if ('S' -in $selectedCategories) {
        Write-Log "Installing Security category..." "INFO"
        
        # Malwarebytes
        if (-not (Test-WingetPackageInstalled "Malwarebytes.Malwarebytes")) {
            winget install --id Malwarebytes.Malwarebytes --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Malwarebytes Installation"
        }
        
        # Wireshark
        if (-not (Test-WingetPackageInstalled "WiresharkFoundation.Wireshark")) {
            winget install --id WiresharkFoundation.Wireshark --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Wireshark Installation"
        }
        
        # Nmap
        if (-not (Test-WingetPackageInstalled "Insecure.Nmap")) {
            winget install --id Insecure.Nmap --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Nmap Installation"
        }
        
        # OpenVPN Connect
        if (-not (Test-WingetPackageInstalled "OpenVPNTechnologies.OpenVPNConnect")) {
            winget install --id OpenVPNTechnologies.OpenVPNConnect --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "OpenVPN Installation"
        }
        
        # Kali Linux WSL distribution
        if (-not (Test-WSLDistributionInstalled "kali-linux")) {
            Write-Log "Installing Kali Linux WSL distribution..." "INFO"
            wsl --install -d Kali-Linux --no-launch
            Test-CommandSuccess $LASTEXITCODE "Kali Linux Installation"
        }
    }
} else {
    Write-Log "No categories selected, skipping category installations" "INFO"
}

# =============================================================================
# SECTION 1: Install PowerShell 7 (Always Installed)
# =============================================================================
Write-Log "Installing PowerShell 7..." "INFO"

# Expected Output: Found PowerShell [Microsoft.PowerShell] ... Successfully installed
# Options: -e (exact match), --silent (no prompts), --accept-package-agreements
Write-Log "Installing PowerShell 7..." "INFO"
winget install --id Microsoft.PowerShell --source winget -e --accept-package-agreements --accept-source-agreements
Test-CommandSuccess $LASTEXITCODE "PowerShell 7 Installation"

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
# SECTION 3: Setup WSL (Always installed for compatibility)
# =============================================================================
Write-Log "Setting up WSL..." "INFO"

# Check if WSL is already installed
if (-not (Test-WSLInstalled)) {
    # Expected Output: Installing: Virtual Machine Platform ... Changes will not be effective until the system is rebooted.
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
} else {
    Write-Log "WSL is already installed and configured" "INFO"
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
# SECTION 5: Configure PowerShell and Install Global npm Packages (If Node.js installed)
# =============================================================================
Write-Log "Configuring PowerShell execution policy..." "INFO"

# Expected Output: No output if successful
# Options: -Scope (CurrentUser, LocalMachine), -Force (suppress confirmation)
Write-Log "Setting PowerShell execution policy..." "INFO"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
Test-CommandSuccess $LASTEXITCODE "PowerShell Execution Policy"

# Only configure npm if Node.js was installed via Developer category or is already present
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

    # Install Next.js if Developer category was selected
    if ('D' -in $selectedCategories) {
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
# COMPLETION AND NEXT STEPS
# =============================================================================
Write-Log "Automated setup completed!" "INFO"

Write-Host ""
Write-Host "==================== SETUP COMPLETE ====================" -ForegroundColor Green
Write-Host ""
Write-Host "The following components were processed:" -ForegroundColor Cyan
Write-Host "  ✓ PowerShell 7 (Always installed)" -ForegroundColor Green
Write-Host "  ✓ Windows Features (Hyper-V, WSL, Virtual Machine Platform)" -ForegroundColor Green
Write-Host "  ✓ Power settings configured" -ForegroundColor Green

# Show category installations
if ('E' -in $selectedCategories) {
    Write-Host "  ✓ Essential Category:" -ForegroundColor Green
    Write-Host "    - PowerToys, 7-Zip, VLC, TreeSize, Obsidian" -ForegroundColor White
    Write-Host "    - System customizations (Dark mode, File Explorer)" -ForegroundColor White
    Write-Host "    - Bloatware removal, OpenSSH enabled" -ForegroundColor White
}
if ('D' -in $selectedCategories) {
    Write-Host "  ✓ Developer Category:" -ForegroundColor Green
    Write-Host "    - VS Code, Git, Windows Terminal, Firefox Dev Edition" -ForegroundColor White
    Write-Host "    - GitHub Desktop, Docker, Node.js, Python" -ForegroundColor White
    Write-Host "    - Postman, Notepad++, Chocolatey, Ubuntu WSL" -ForegroundColor White
}
if ('C' -in $selectedCategories) {
    Write-Host "  ✓ Creative Category:" -ForegroundColor Green
    Write-Host "    - Figma, OBS Studio, GIMP, Discord" -ForegroundColor White
}
if ('S' -in $selectedCategories) {
    Write-Host "  ✓ Security Category:" -ForegroundColor Green
    Write-Host "    - Malwarebytes, Wireshark, Nmap, OpenVPN, Kali Linux WSL" -ForegroundColor White
}

# Show WSL status
Write-Host "  ✓ WSL (Windows Subsystem for Linux)" -ForegroundColor Green

Write-Host ""
Write-Host "IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. RESTART YOUR COMPUTER to complete Windows Features installation" -ForegroundColor Yellow
Write-Host "  2. After restart, launch any installed WSL distributions to complete their setup" -ForegroundColor Yellow

Write-Host ""
if ('D' -in $selectedCategories) {
    Write-Host "  3. Configure Git with your credentials:" -ForegroundColor Yellow
    Write-Host "     - git config --global user.name 'Your Name'" -ForegroundColor White
    Write-Host "     - git config --global user.email 'your.email@example.com'" -ForegroundColor White
    
    Write-Host "  4. Start Docker Desktop from the Start menu (if Developer category was selected)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green

# Create a summary log file
$installedApps = @()
$installedApps += "PowerShell 7 (Microsoft.PowerShell)"

# Add category installations to log
if ('E' -in $selectedCategories) {
    $installedApps += "PowerToys (Microsoft.PowerToys)"
    $installedApps += "7-Zip (7zip.7zip)"
    $installedApps += "VLC Media Player (VideoLAN.VLC)"
    $installedApps += "TreeSize Free (JAMSoftware.TreeSize.Free)"
    $installedApps += "Obsidian (Obsidian.Obsidian)"
}
if ('D' -in $selectedCategories) {
    $installedApps += "Visual Studio Code (Microsoft.VisualStudioCode)"
    $installedApps += "Git (Git.Git)"
    $installedApps += "Windows Terminal (Microsoft.WindowsTerminal)"
    $installedApps += "Firefox Developer Edition (Mozilla.Firefox.DeveloperEdition)"
    $installedApps += "GitHub Desktop (GitHub.GitHubDesktop)"
    $installedApps += "Docker Desktop (Docker.DockerDesktop)"
    $installedApps += "Node.js (OpenJS.NodeJS)"
    $installedApps += "Python 3.11 (Python.Python.3.11)"
    $installedApps += "Postman (Postman.Postman)"
    $installedApps += "Notepad++ (Notepad++.Notepad++)"
    $installedApps += "Chocolatey (Chocolatey.Chocolatey)"
    $installedApps += "Ubuntu WSL Distribution"
}
if ('C' -in $selectedCategories) {
    $installedApps += "Figma (Figma.Figma)"
    $installedApps += "OBS Studio (OBSProject.OBSStudio)"
    $installedApps += "GIMP (GIMP.GIMP)"
    $installedApps += "Discord (Discord.Discord)"
}
if ('S' -in $selectedCategories) {
    $installedApps += "Malwarebytes (Malwarebytes.Malwarebytes)"
    $installedApps += "Wireshark (WiresharkFoundation.Wireshark)"
    $installedApps += "Nmap (Insecure.Nmap)"
    $installedApps += "OpenVPN Connect (OpenVPNTechnologies.OpenVPNConnect)"
    $installedApps += "Kali Linux WSL Distribution"
}

$logContent = "Windows Automated Setup Summary`nGenerated: $(Get-Date)`n`n"
$logContent += "Selected Categories: $($selectedCategories -join ', ')`n`n"
$logContent += "Installed Applications:`n"
$logContent += ($installedApps | ForEach-Object { "- $_" }) -join "`n"

$logContent += "`n`nEnabled Windows Features:`n"
$logContent += "- Microsoft-hyper-v`n"
$logContent += "- HypervisorPlatform`n"
$logContent += "- VirtualMachinePlatform`n"
$logContent += "- Microsoft-Windows-Subsystem-Linux`n"

$logContent += "`nWSL Status:`n- WSL installed and configured"

$logContent += "`n`nPower Settings Configured:`n"
$logContent += "- Monitor timeout (AC): Never`n"
$logContent += "- Monitor timeout (DC): 10 minutes`n"
$logContent += "- Standby timeout (AC): Never`n"
$logContent += "- Standby timeout (DC): Never`n"

# Add system customizations if Essential category was selected
if ('E' -in $selectedCategories) {
    $logContent += "`nSystem Customizations Applied:`n"
    $logContent += "- Dark mode enabled`n"
    $logContent += "- File Explorer enhancements (show extensions, hidden files)`n"
    $logContent += "- Taskbar modifications (hide search, task view)`n"
    $logContent += "- Windows bloatware removed`n"
    $logContent += "- OpenSSH Client and Server enabled`n"
}

# Add conditional sections
if ('D' -in $selectedCategories -and (Test-NodeInstalled)) {
    $logContent += "`n`nGlobal npm Packages:`n- npm (latest)"
    $logContent += "`n- next (latest)"
}

if (Test-WSLDistributionInstalled "kali-linux") {
    $logContent += "`n`nKali Linux Tools:`n- kali-tools-web (if configured)"
}

$logContent += "`n`nNext Steps Required:`n1. Restart computer"
$logContent += "`n2. Launch and configure any installed WSL distributions"
$logContent += "`n3. Configure Git credentials (if Developer category selected)"
if (Test-WingetPackageInstalled "Docker.DockerDesktop") {
    $logContent += "`n4. Start Docker Desktop"
}

$logContent | Out-File -FilePath ".\setup-summary.log" -Encoding UTF8
Write-Log "Setup summary saved to: setup-summary.log" "INFO"
