# =====================
# UTILITY FUNCTIONS (MUST BE FIRST)
# =====================
function Test-CommandSuccess {
    param(
        [int]$ExitCode,
        [string]$Action = "Command"
    )
    if ($ExitCode -eq 0) {
        Write-Log "$Action succeeded." "INFO"
        return $true
    } else {
        Write-Log "$Action failed with exit code $ExitCode." "ERROR"
        return $false
    }
}

function Test-WSLInstalled {
    try {
        $wslVersion = wsl --status 2>$null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# =====================
# PIN TO TASKBAR FUNCTION
# =====================
function Add-AppToTaskbar {
    param(
        [string]$AppName,
        [string]$ExecutablePath
    )
    try {
        # Check if the executable exists
        if (Test-Path $ExecutablePath) {
            # Create a shortcut object
            $Shell = New-Object -ComObject Shell.Application
            $Folder = $Shell.Namespace((Split-Path $ExecutablePath))
            $Item = $Folder.ParseName((Split-Path $ExecutablePath -Leaf))
            
            # Get the context menu and find "Pin to taskbar" option
            $Verbs = $Item.Verbs()
            $PinVerb = $Verbs | Where-Object { $_.Name -match "Pin to taskbar" -or $_.Name -match "taskbar" }
            
            if ($PinVerb) {
                $PinVerb.DoIt()
                Write-Log "Successfully pinned $AppName to taskbar" "INFO"
                return $true
            } else {
                Write-Log "Could not find 'Pin to taskbar' option for $AppName" "WARN"
                return $false
            }
        } else {
            Write-Log "Executable not found: $ExecutablePath" "WARN"
            return $false
        }
    } catch {
        Write-Log "Failed to pin $AppName to taskbar: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Add-InstalledAppsToTaskbar {
    param([array]$SelectedCategories)
    
    Write-Log "Configuring taskbar pins for installed applications..." "INFO"
    
    # Define common application paths and their display names
    $AppPaths = @{
        "Visual Studio Code" = @(
            "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe",
            "${env:ProgramFiles}\Microsoft VS Code\Code.exe"
        )
        "Windows Terminal" = @(
            "${env:LOCALAPPDATA}\Microsoft\WindowsApps\wt.exe"
        )
        "GitHub Desktop" = @(
            "${env:LOCALAPPDATA}\GitHubDesktop\GitHubDesktop.exe"
        )
        "Docker Desktop" = @(
            "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
        )
        "Firefox Developer Edition" = @(
            "${env:ProgramFiles}\Firefox Developer Edition\firefox.exe"
        )
        "Obsidian" = @(
            "${env:LOCALAPPDATA}\Programs\Obsidian\Obsidian.exe"
        )
        "Discord" = @(
            "${env:LOCALAPPDATA}\Discord\app-*\Discord.exe"
        )
        "PowerToys" = @(
            "${env:LOCALAPPDATA}\Microsoft\PowerToys\PowerToys.exe",
            "${env:ProgramFiles}\PowerToys\PowerToys.exe"
        )
        "Burp Suite Community" = @(
            "${env:LOCALAPPDATA}\Programs\BurpSuiteCommunity\BurpSuiteCommunity.exe"
        )
        "OWASP ZAP" = @(
            "${env:ProgramFiles}\ZAP\Zed Attack Proxy\zap.exe"
        )
        "Bitwarden" = @(
            "${env:LOCALAPPDATA}\Programs\Bitwarden\Bitwarden.exe"
        )
        "VeraCrypt" = @(
            "${env:ProgramFiles}\VeraCrypt\VeraCrypt.exe"
        )
        "Wireshark" = @(
            "${env:ProgramFiles}\Wireshark\Wireshark.exe"
        )
    }
    
    # Essential category apps
    if ('E' -in $SelectedCategories) {
        foreach ($app in @("PowerToys", "Obsidian")) {
            if ($AppPaths.ContainsKey($app)) {
                foreach ($path in $AppPaths[$app]) {
                    $resolvedPath = if ($path -like "*\app-*\*") {
                        # Handle Discord's versioned folder structure
                        $basePath = Split-Path $path
                        $executable = Split-Path $path -Leaf
                        $versionFolders = Get-ChildItem $basePath -Directory | Where-Object { $_.Name -like "app-*" } | Sort-Object Name -Descending
                        if ($versionFolders) {
                            Join-Path $versionFolders[0].FullName $executable
                        } else {
                            $null
                        }
                    } else {
                        $path
                    }
                    
                    if ($resolvedPath -and (Test-Path $resolvedPath)) {
                        Add-AppToTaskbar $app $resolvedPath
                        break
                    }
                }
            }
        }
    }
    
    # Developer category apps
    if ('D' -in $SelectedCategories) {
        foreach ($app in @("Visual Studio Code", "Windows Terminal", "GitHub Desktop", "Docker Desktop", "Firefox Developer Edition")) {
            if ($AppPaths.ContainsKey($app)) {
                foreach ($path in $AppPaths[$app]) {
                    if (Test-Path $path) {
                        Add-AppToTaskbar $app $path
                        break
                    }
                }
            }
        }
    }
    
    # Creative category apps
    if ('C' -in $SelectedCategories) {
        foreach ($app in @("Discord")) {
            if ($AppPaths.ContainsKey($app)) {
                foreach ($path in $AppPaths[$app]) {
                    $resolvedPath = if ($path -like "*\app-*\*") {
                        # Handle Discord's versioned folder structure
                        $basePath = Split-Path $path
                        $executable = Split-Path $path -Leaf
                        $versionFolders = Get-ChildItem $basePath -Directory | Where-Object { $_.Name -like "app-*" } | Sort-Object Name -Descending
                        if ($versionFolders) {
                            Join-Path $versionFolders[0].FullName $executable
                        } else {
                            $null
                        }
                    } else {
                        $path
                    }
                    
                    if ($resolvedPath -and (Test-Path $resolvedPath)) {
                        Add-AppToTaskbar $app $resolvedPath
                        break
                    }
                }
            }
        }
    }
    
    # Security category apps
    if ('S' -in $SelectedCategories) {
        foreach ($app in @("Burp Suite Community", "OWASP ZAP", "Bitwarden", "VeraCrypt", "Wireshark")) {
            if ($AppPaths.ContainsKey($app)) {
                foreach ($path in $AppPaths[$app]) {
                    if (Test-Path $path) {
                        Add-AppToTaskbar $app $path
                        break
                    }
                }
            }
        }
    }
}
# =====================
# CHECK IF WINGET PACKAGE IS INSTALLED
# =====================
function Test-WingetPackageInstalled {
    param(
        [string]$PackageId
    )
    try {
        $result = winget list --id $PackageId 2>$null
        return ($result -match $PackageId)
    } catch {
        return $false
    }
}

# =====================
# YES/NO PROMPT FUNCTION (MUST BE FIRST)
# =====================
function Get-YesNo {
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )
    $defaultText = if ($Default) { '[Y/n]' } else { '[y/N]' }
    while ($true) {
        $input = Read-Host "$Prompt $defaultText"
        if ([string]::IsNullOrWhiteSpace($input)) {
            return $Default
        }
        switch ($input.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default { Write-Host "Please enter 'y' or 'n'." -ForegroundColor Yellow }
        }
    }
}

# =====================
# FUNCTION DEFINITIONS (MUST BE FIRST)
# =====================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $color = switch ($Level) {
        "INFO" { "Green" }
        "WARN" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

function Get-CategoryChoices {
    Write-Host ""
    Write-Host "========== INSTALLATION CATEGORIES ==========" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select the categories you want to install:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[E] Essential      - Core utilities (PowerToys, 7-Zip, VLC, TreeSize, Obsidian)" -ForegroundColor White
    Write-Host "[D] Developer      - Programming tools (VS Code, Firefox Dev, Windows Terminal, Git, Docker)" -ForegroundColor White
    Write-Host "[C] Creative       - Media & design tools (Figma, OBS Studio, GIMP, Discord)" -ForegroundColor White
    Write-Host "[S] Security       - Privacy & security tools (Malwarebytes, Wireshark, Burp Suite, Bitwarden, VeraCrypt)" -ForegroundColor White
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
        Write-Host "Invalid choice. Please enter valid category letters (E, D, C, S, A, or N)" -ForegroundColor Red
    } while ($true)
    return $selectedCategories
}

function Get-PowerTimeout {
    param(
        [string]$Prompt,
        [int]$Default
    )
    $input = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Default
    }
    if ($input -match '^[0-9]+$') {
        return [int]$input
    } else {
        Write-Host "Invalid input. Using default: $Default" -ForegroundColor Yellow
        return $Default
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
    if (-not $EnableOpenSSHClient -and -not $EnableOpenSSHServer) {
        Write-Log "Skipping OpenSSH Client and Server per user choice" "INFO"
        return
    }
    Write-Log "Enabling OpenSSH Client and Server..." "INFO"
    # Enable OpenSSH Client
    if ($EnableOpenSSHClient) {
        $sshClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
        if ($sshClient.State -ne "Installed") {
            Add-WindowsCapability -Online -Name $sshClient.Name
            Test-CommandSuccess $LASTEXITCODE "OpenSSH Client Installation"
        } else {
            Write-Log "OpenSSH Client already installed" "INFO"
        }
    }
    # Enable OpenSSH Server
    if ($EnableOpenSSHServer) {
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
}

# Prompt user for bloatware removal (Yes/No)
$RemoveBloatware = Get-YesNo 'Remove default bloatware apps?' $true

# Function to remove Windows bloatware
function Remove-WindowsBloatware {
    Write-Log "Removing Windows bloatware..." "INFO"
    if (-not $RemoveBloatware) {
        Write-Log "Bloatware removal skipped per user choice." "INFO"
        return
    }
    
    # Comprehensive list of bloatware apps with wildcards for better matching
    $bloatwareApps = @(
        # Xbox and Gaming
        "*Xbox*",
        "*Microsoft.GamingApp*",
        "*Microsoft.XboxSpeechToTextOverlay*",
        "*Microsoft.XboxApp*",
        "*Microsoft.XboxGameOverlay*",
        "*Microsoft.XboxGamingOverlay*",
        "*Microsoft.XboxIdentityProvider*",
        "*Microsoft.Xbox.TCUI*",
        
        # Microsoft Store and Office apps
        "*Microsoft.SkypeApp*",
        "*Microsoft.MicrosoftOfficeHub*",
        "*Microsoft.Office.OneNote*",
        "*Microsoft.Office.Sway*",
        "*Microsoft.Office.Lens*",
        "*Microsoft.Office.Todo.List*",
        
        # Media and Entertainment
        "*Microsoft.ZuneMusic*",
        "*Microsoft.ZuneVideo*",
        "*Microsoft.Movies*",
        "*Microsoft.Music*",
        "*SpotifyAB.SpotifyMusic*",
        "*Disney*",
        "*Netflix*",
        
        # News and Weather
        "*Microsoft.BingWeather*",
        "*Microsoft.BingNews*",
        "*Microsoft.News*",
        "*Microsoft.BingFinance*",
        "*Microsoft.BingSports*",
        
        # Social and Communication
        "*Microsoft.People*",
        "*Microsoft.Messaging*",
        "*Microsoft.YourPhone*",
        "*Microsoft.WindowsCommunicationsApps*",
        "*microsoft.windowscommunicationsapps*",
        
        # Productivity and Tools
        "*Microsoft.Whiteboard*",
        "*Microsoft.OneConnect*",
        "*Microsoft.Print3D*",
        "*Microsoft.Microsoft3DViewer*",
        "*Microsoft.MixedReality.Portal*",
        
        # Windows Accessories
        "*Microsoft.WindowsAlarms*",
        "*Microsoft.WindowsCamera*",
        "*Microsoft.WindowsMaps*",
        "*Microsoft.WindowsSoundRecorder*",
        "*Microsoft.WindowsFeedbackHub*",
        "*Microsoft.Getstarted*",
        "*Microsoft.GetHelp*",
        "*Microsoft.Todos*",
        
        # Games
        "*Microsoft.MicrosoftSolitaireCollection*",
        "*Microsoft.MicrosoftMahjong*",
        "*Microsoft.FreshPaint*",
        "*Microsoft.NetworkSpeedTest*",
        "*Microsoft.MSPaint*",
        
        # Third-party bloatware (common on OEM systems)
        "*CandyCrush*",
        "*BubbleWitch*",
        "*Wunderlist*",
        "*Flipboard*",
        "*Twitter*",
        "*Facebook*",
        "*Spotify*",
        "*Minecraft*",
        "*Royal Revolt*",
        "*Sway*",
        "*Speed Test*",
        "*Dolby*",
        "*Drawboard*",
        "*Microsoft.Advertising*",
        
        # Windows 11 specific
        "*Microsoft.Todos*",
        "*Microsoft.PowerAutomateDesktop*",
        "*MicrosoftTeams*",
        "*Microsoft.549981C3F5F10*",  # Cortana
        "*Microsoft.Windows.DevHome*"
    )
    
    # Apps to explicitly protect from removal (useful applications)
    $protectedApps = @(
        "*Microsoft.RemoteDesktop*",           # Remote Desktop Connection
        "*Microsoft.DesktopAppInstaller*",    # winget/App Installer
        "*Microsoft.StorePurchaseApp*",       # Microsoft Store
        "*Microsoft.WindowsStore*",           # Microsoft Store
        "*Microsoft.WindowsCalculator*",      # Calculator
        "*Microsoft.WindowsNotepad*",         # Notepad
        "*Microsoft.Paint*",                  # Paint
        "*Microsoft.ScreenSketch*",           # Snipping Tool
        "*Microsoft.Windows.Photos*",         # Photos app
        "*Microsoft.WindowsSoundRecorder*",   # Voice Recorder (useful)
        "*Microsoft.WindowsTerminal*",        # Windows Terminal
        "*Microsoft.PowerShell*",             # PowerShell
        "*Microsoft.VCLibs*",                 # Visual C++ Runtime
        "*Microsoft.NET*",                    # .NET Runtime
        "*Microsoft.WindowsAppRuntime*"       # Windows App Runtime
    )
    
    $removedCount = 0
    $totalApps = 0
    
    Write-Log "Scanning for bloatware applications..." "INFO"
    
    foreach ($appPattern in $bloatwareApps) {
        try {
            # Get all matching packages for current user
            $packages = Get-AppxPackage -Name $appPattern -ErrorAction SilentlyContinue
            foreach ($package in $packages) {
                # Check if package is in protection list
                $isProtected = $false
                foreach ($protectedApp in $protectedApps) {
                    if ($package.Name -like $protectedApp) {
                        $isProtected = $true
                        break
                    }
                }
                
                if ($isProtected) {
                    Write-Log "⚠ Skipping protected app: $($package.Name)" "INFO"
                    continue
                }
                
                $totalApps++
                try {
                    Write-Log "Attempting to remove: $($package.Name)" "INFO"
                    Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Stop
                    Write-Log "✓ Removed: $($package.Name)" "INFO"
                    $removedCount++
                } catch {
                    Write-Log "✗ Failed to remove: $($package.Name) - $($_.Exception.Message)" "WARN"
                }
            }
            
            # Get all matching packages for all users
            $allUserPackages = Get-AppxPackage -Name $appPattern -AllUsers -ErrorAction SilentlyContinue
            foreach ($package in $allUserPackages) {
                # Check if package is in protection list
                $isProtected = $false
                foreach ($protectedApp in $protectedApps) {
                    if ($package.Name -like $protectedApp) {
                        $isProtected = $true
                        break
                    }
                }
                
                if ($isProtected) {
                    continue
                }
                
                try {
                    Write-Log "Removing for all users: $($package.Name)" "INFO"
                    Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
                    $removedCount++
                } catch {
                    Write-Log "Failed to remove for all users: $($package.Name)" "WARN"
                }
            }
            
            # Remove provisioned packages (prevents reinstallation for new users)
            $provisionedPackages = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like $appPattern
            foreach ($package in $provisionedPackages) {
                # Check if package is in protection list
                $isProtected = $false
                foreach ($protectedApp in $protectedApps) {
                    if ($package.DisplayName -like $protectedApp) {
                        $isProtected = $true
                        break
                    }
                }
                
                if ($isProtected) {
                    Write-Log "⚠ Skipping protected provisioned app: $($package.DisplayName)" "INFO"
                    continue
                }
                
                try {
                    Write-Log "Removing provisioned package: $($package.DisplayName)" "INFO"
                    Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction Stop
                    Write-Log "✓ Removed provisioned: $($package.DisplayName)" "INFO"
                } catch {
                    Write-Log "✗ Failed to remove provisioned: $($package.DisplayName)" "WARN"
                }
            }
            
        } catch {
            Write-Log "Error processing pattern $appPattern`: $($_.Exception.Message)" "WARN"
        }
    }
    
    # Additional cleanup for Windows 11 specific bloatware
    try {
        Write-Log "Performing additional Windows 11 cleanup..." "INFO"
        
        # Remove Chat (Teams consumer)
        $chatApp = Get-AppxPackage -Name "*Teams*" -ErrorAction SilentlyContinue
        if ($chatApp) {
            Remove-AppxPackage -Package $chatApp.PackageFullName -ErrorAction SilentlyContinue
            Write-Log "Removed Microsoft Teams Chat" "INFO"
        }
        
        # Disable Windows 11 suggestions and ads
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f | Out-Null
        Write-Log "Disabled Windows suggestions and ads" "INFO"
        
    } catch {
        Write-Log "Additional cleanup failed: $($_.Exception.Message)" "WARN"
    }
    
    Write-Log "Bloatware removal completed. Processed $totalApps apps, successfully removed $removedCount items." "INFO"
    
    if ($removedCount -eq 0) {
        Write-Log "No bloatware found to remove (already clean or packages protected)" "INFO"
    }
}

# Function to apply system customizations
function Apply-SystemCustomizations {
    Write-Log "Applying system customizations..." "INFO"
    # Enable dark mode (user choice)
    try {
        if ($EnableDarkMode) {
            reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Null
            Write-Log "Dark mode enabled" "INFO"
        } else {
            reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 1 /f | Out-Null
            reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 1 /f | Out-Null
            Write-Log "Dark mode disabled (light mode enabled)" "INFO"
        }
    } catch {
        Write-Log "Could not set dark mode" "WARN"
    }
    # File Explorer enhancements (user choices)
    try {
        # Show/hide file extensions
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d $([int](-not $ShowFileExtensions)) /f | Out-Null
        # Show/hide hidden files
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d $([int]$ShowHiddenFiles) /f | Out-Null
        # Show/hide system files
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d $([int]$ShowSystemFiles) /f | Out-Null
        Write-Log "File Explorer enhancements applied" "INFO"
    } catch {
        Write-Log "Could not apply File Explorer enhancements" "WARN"
    }
    # Taskbar modifications (user choices)
    try {
        # Hide/show search box
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d $([int]$HideSearchBox) /f | Out-Null
        # Hide/show task view button
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d $([int](-not $HideTaskViewButton)) /f | Out-Null
        Write-Log "Taskbar modifications applied" "INFO"
    } catch {
        Write-Log "Could not apply taskbar modifications" "WARN"
    }
}

Write-Log "Starting Automated Windows Computer Setup" "INFO"


# =====================
# ABOUT THIS SCRIPT
# =====================
Write-Host "======== AUTOMATED WINDOWS SETUP SCRIPT ========" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  • Install PowerShell 7 (Always)" -ForegroundColor White
Write-Host "  • Enable Windows Features for virtualization (Always)" -ForegroundColor White
Write-Host "  • Setup WSL (Always)" -ForegroundColor White
Write-Host "  • Configure power settings (user-defined)" -ForegroundColor White
Write-Host "  • Check for existing installations and skip if found" -ForegroundColor Green
Write-Host "  • Install applications based on selected categories:" -ForegroundColor Yellow
Write-Host ""

# =====================
# CATEGORY SELECTION
# =====================
$selectedCategories = Get-CategoryChoices
Write-Log "Selected categories: $($selectedCategories -join ', ')" "INFO"

# =====================
# USER OPTIONS
# =====================
# Power timeouts
function Get-PowerTimeout {
    param(
        [string]$Prompt,
        [int]$Default
    )
    $input = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Default
    }
    if ($input -match '^[0-9]+$') {
        return [int]$input
    } else {
        Write-Host "Invalid input. Using default: $Default" -ForegroundColor Yellow
        return $Default
    }
}
$MonitorTimeoutAC = Get-PowerTimeout "Enter monitor timeout (AC, minutes, 10=Default)" 10
$MonitorTimeoutDC = Get-PowerTimeout "Enter monitor timeout (DC, minutes, 10=Default)" 10
$StandbyTimeoutAC = Get-PowerTimeout "Enter standby timeout (AC, minutes, 10=Default)" 10
$StandbyTimeoutDC = Get-PowerTimeout "Enter standby timeout (DC, minutes, 10=Default)" 10

# System customizations
$EnableDarkMode = Get-YesNo 'Enable dark mode?' $true
$ShowFileExtensions = Get-YesNo 'Show file extensions in File Explorer?' $true
$ShowHiddenFiles = Get-YesNo 'Show hidden files in File Explorer?' $true
$ShowSystemFiles = Get-YesNo 'Show system files in File Explorer?' $true
$HideSearchBox = Get-YesNo 'Hide search box on taskbar?' $true
$HideTaskViewButton = Get-YesNo 'Hide task view button on taskbar?' $true
$PinAppsToTaskbar = Get-YesNo 'Pin installed apps to taskbar?' $true

# Bloatware removal
$RemoveBloatware = Get-YesNo 'Remove default bloatware apps?' $true

# OpenSSH
$EnableOpenSSHClient = Get-YesNo 'Enable OpenSSH Client?' $true
$EnableOpenSSHServer = Get-YesNo 'Enable OpenSSH Server?' $false

# WSL Distributions
$InstallUbuntuWSL = Get-YesNo 'Install Ubuntu WSL distribution?' $true
$InstallKaliWSL = Get-YesNo 'Install Kali Linux WSL distribution?' $false

# =====================
# FINAL CONFIRMATION
# =====================
Write-Host ""
Write-Host "Press any key to continue or Ctrl+C to cancel..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

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
        if ($InstallUbuntuWSL -and -not (Test-WSLDistributionInstalled "Ubuntu")) {
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
        if (-not (Test-WingetPackageInstalled "GIMP.GIMP.3")) {
            winget install --id GIMP.GIMP.3 --source winget -e --accept-package-agreements --accept-source-agreements
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
        
        # Burp Suite Community Edition (Web Application Security Testing)
        if (-not (Test-WingetPackageInstalled "PortSwigger.BurpSuite.Community")) {
            winget install --id PortSwigger.BurpSuite.Community --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Burp Suite Community Installation"
        }
        
        # OWASP ZAP (Web Application Scanner)
        if (-not (Test-WingetPackageInstalled "ZAP.ZAP")) {
            winget install --id ZAP.ZAP --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "OWASP ZAP Installation"
        }
        
        # Bitwarden (Password Manager)
        if (-not (Test-WingetPackageInstalled "Bitwarden.Bitwarden")) {
            winget install --id Bitwarden.Bitwarden --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Bitwarden Installation"
        }
        
        # KeePass (Local Password Database)
        if (-not (Test-WingetPackageInstalled "DominikReichl.KeePass")) {
            winget install --id DominikReichl.KeePass --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "KeePass Installation"
        }
        
        # VeraCrypt (Disk Encryption)
        if (-not (Test-WingetPackageInstalled "IDRIX.VeraCrypt")) {
            winget install --id IDRIX.VeraCrypt --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "VeraCrypt Installation"
        }
        
        # GnuPG (Email and File Encryption)
        if (-not (Test-WingetPackageInstalled "GnuPG.Gpg4win")) {
            winget install --id GnuPG.Gpg4win --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Gpg4win Installation"
        }
        
        # Process Monitor (System Monitoring)
        if (-not (Test-WingetPackageInstalled "Microsoft.Sysinternals.ProcessMonitor")) {
            winget install --id Microsoft.Sysinternals.ProcessMonitor --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Process Monitor Installation"
        }
        
        # Process Explorer (Advanced Task Manager)
        if (-not (Test-WingetPackageInstalled "Microsoft.Sysinternals.ProcessExplorer")) {
            winget install --id Microsoft.Sysinternals.ProcessExplorer --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Process Explorer Installation"
        }
        
        # Autoruns (Startup Program Manager)
        if (-not (Test-WingetPackageInstalled "Microsoft.Sysinternals.Autoruns")) {
            winget install --id Microsoft.Sysinternals.Autoruns --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Autoruns Installation"
        }
        
        # Angry IP Scanner (Network Scanner)
        if (-not (Test-WingetPackageInstalled "angryziber.AngryIPScanner")) {
            winget install --id angryziber.AngryIPScanner --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Angry IP Scanner Installation"
        }
        
        # Advanced IP Scanner (Network Discovery)
        if (-not (Test-WingetPackageInstalled "Famatech.AdvancedIPScanner")) {
            winget install --id Famatech.AdvancedIPScanner --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Advanced IP Scanner Installation"
        }
        
        # Tor Browser (Anonymous Web Browsing)
        if (-not (Test-WingetPackageInstalled "TorProject.TorBrowser")) {
            winget install --id TorProject.TorBrowser --source winget -e --accept-package-agreements --accept-source-agreements
            Test-CommandSuccess $LASTEXITCODE "Tor Browser Installation"
        }
        
        # Kali Linux WSL distribution
        if ($InstallKaliWSL -and -not (Test-WSLDistributionInstalled "kali-linux")) {
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

# Use user-selected values for power timeouts
Write-Log "Setting monitor timeout (AC) to $MonitorTimeoutAC minutes..." "INFO"
powercfg -change monitor-timeout-ac $MonitorTimeoutAC
Test-CommandSuccess $LASTEXITCODE "Monitor Timeout AC"

Write-Log "Setting monitor timeout (DC) to $MonitorTimeoutDC minutes..." "INFO"
powercfg -change monitor-timeout-dc $MonitorTimeoutDC
Test-CommandSuccess $LASTEXITCODE "Monitor Timeout DC"

Write-Log "Setting standby timeout (AC) to $StandbyTimeoutAC minutes..." "INFO"
powercfg -change standby-timeout-ac $StandbyTimeoutAC
Test-CommandSuccess $LASTEXITCODE "Standby Timeout AC"

Write-Log "Setting standby timeout (DC) to $StandbyTimeoutDC minutes..." "INFO"
powercfg -change standby-timeout-dc $StandbyTimeoutDC
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
# TASKBAR CONFIGURATION
# =============================================================================
if ($PinAppsToTaskbar) {
    Write-Host ""
    Write-Host "==================== TASKBAR CONFIGURATION ====================" -ForegroundColor Cyan
    Write-Host ""
    
    # Add a small delay to ensure applications are fully installed
    Write-Log "Waiting for applications to be fully registered..." "INFO"
    Start-Sleep -Seconds 3
    
    Add-InstalledAppsToTaskbar $selectedCategories
    Write-Log "Taskbar configuration completed" "INFO"
} else {
    Write-Log "Skipping taskbar app pinning (user choice)" "INFO"
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
    Write-Host "    - Malwarebytes, Wireshark, Nmap, OpenVPN, Burp Suite" -ForegroundColor White
    Write-Host "    - OWASP ZAP, Bitwarden, KeePass, VeraCrypt, Gpg4win" -ForegroundColor White
    Write-Host "    - Process Monitor, Process Explorer, Autoruns, Network Scanners" -ForegroundColor White
    Write-Host "    - Tor Browser, Kali Linux WSL" -ForegroundColor White
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
    $installedApps += "Burp Suite Community (PortSwigger.BurpSuite.Community)"
    $installedApps += "OWASP ZAP (ZAP.ZAP)"
    $installedApps += "Bitwarden (Bitwarden.Bitwarden)"
    $installedApps += "KeePass (DominikReichl.KeePass)"
    $installedApps += "VeraCrypt (IDRIX.VeraCrypt)"
    $installedApps += "Gpg4win (GnuPG.Gpg4win)"
    $installedApps += "Process Monitor (Microsoft.Sysinternals.ProcessMonitor)"
    $installedApps += "Process Explorer (Microsoft.Sysinternals.ProcessExplorer)"
    $installedApps += "Autoruns (Microsoft.Sysinternals.Autoruns)"
    $installedApps += "Angry IP Scanner (angryziber.AngryIPScanner)"
    $installedApps += "Advanced IP Scanner (Famatech.AdvancedIPScanner)"
    $installedApps += "Tor Browser (TorProject.TorBrowser)"
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
