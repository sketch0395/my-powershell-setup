# Windows Bloatware Removal Catalog

This document provides a comprehensive list of bloatware applications that are automatically removed by the Setup-Automation.ps1 script when the bloatware removal option is enabled.

## 🛡️ Protected Applications (Never Removed)

These essential Windows applications are **protected** and will never be removed:

| Application | Package Pattern | Purpose |
|-------------|-----------------|---------|
| Remote Desktop Connection | `*Microsoft.RemoteDesktop*` | Remote access functionality |
| Microsoft Store | `*Microsoft.WindowsStore*`, `*Microsoft.StorePurchaseApp*` | App installation platform |
| Calculator | `*Microsoft.WindowsCalculator*` | Basic calculator |
| Notepad | `*Microsoft.WindowsNotepad*` | Text editor |
| Paint | `*Microsoft.Paint*` | Basic image editor |
| Snipping Tool | `*Microsoft.ScreenSketch*` | Screenshot utility |
| Photos | `*Microsoft.Windows.Photos*` | Image viewer |
| Voice Recorder | `*Microsoft.WindowsSoundRecorder*` | Audio recording |
| Windows Terminal | `*Microsoft.WindowsTerminal*` | Command line interface |
| PowerShell | `*Microsoft.PowerShell*` | Scripting environment |
| App Installer (winget) | `*Microsoft.DesktopAppInstaller*` | Package manager |
| Visual C++ Runtime | `*Microsoft.VCLibs*` | System libraries |
| .NET Runtime | `*Microsoft.NET*` | Application framework |
| Windows App Runtime | `*Microsoft.WindowsAppRuntime*` | Modern app support |

## 🗑️ Removed Bloatware Applications

### Xbox and Gaming (8 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Xbox Console Companion | `*Xbox*` | Xbox gaming platform |
| Gaming App | `*Microsoft.GamingApp*` | Windows gaming services |
| Xbox Speech Overlay | `*Microsoft.XboxSpeechToTextOverlay*` | Voice control for Xbox |
| Xbox App | `*Microsoft.XboxApp*` | Xbox social features |
| Xbox Game Overlay | `*Microsoft.XboxGameOverlay*` | In-game overlay |
| Xbox Gaming Overlay | `*Microsoft.XboxGamingOverlay*` | Gaming overlay |
| Xbox Identity Provider | `*Microsoft.XboxIdentityProvider*` | Xbox authentication |
| Xbox TCUI | `*Microsoft.Xbox.TCUI*` | Xbox user interface |

### Microsoft Office and Store Apps (6 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Skype | `*Microsoft.SkypeApp*` | Video calling (replaced by Teams) |
| Office Hub | `*Microsoft.MicrosoftOfficeHub*` | Office app launcher |
| OneNote | `*Microsoft.Office.OneNote*` | Note-taking app |
| Sway | `*Microsoft.Office.Sway*` | Presentation tool |
| Office Lens | `*Microsoft.Office.Lens*` | Document scanner |
| To Do | `*Microsoft.Office.Todo.List*` | Task management |

### Media and Entertainment (7 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Groove Music | `*Microsoft.ZuneMusic*` | Music player |
| Movies & TV | `*Microsoft.ZuneVideo*`, `*Microsoft.Movies*` | Video player |
| Music | `*Microsoft.Music*` | Music streaming |
| Spotify | `*SpotifyAB.SpotifyMusic*` | Music streaming (pre-installed) |
| Disney+ | `*Disney*` | Streaming service |
| Netflix | `*Netflix*` | Streaming service |

### News and Weather (5 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Weather | `*Microsoft.BingWeather*` | Weather forecasts |
| News | `*Microsoft.BingNews*`, `*Microsoft.News*` | News aggregator |
| Money | `*Microsoft.BingFinance*` | Financial news |
| Sports | `*Microsoft.BingSports*` | Sports news |

### Social and Communication (4 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| People | `*Microsoft.People*` | Contact management |
| Messaging | `*Microsoft.Messaging*` | SMS/messaging |
| Your Phone | `*Microsoft.YourPhone*` | Phone integration |
| Mail and Calendar | `*Microsoft.WindowsCommunicationsApps*` | Email client |

### Productivity and Tools (5 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Whiteboard | `*Microsoft.Whiteboard*` | Digital whiteboard |
| Mobile Plans | `*Microsoft.OneConnect*` | Cellular plan management |
| Print 3D | `*Microsoft.Print3D*` | 3D printing utility |
| 3D Viewer | `*Microsoft.Microsoft3DViewer*` | 3D model viewer |
| Mixed Reality Portal | `*Microsoft.MixedReality.Portal*` | VR/AR platform |

### Windows Accessories (7 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Alarms & Clock | `*Microsoft.WindowsAlarms*` | Timer and alarm |
| Camera | `*Microsoft.WindowsCamera*` | Camera app |
| Maps | `*Microsoft.WindowsMaps*` | Navigation and maps |
| Sound Recorder | `*Microsoft.WindowsSoundRecorder*` | Audio recording |
| Feedback Hub | `*Microsoft.WindowsFeedbackHub*` | User feedback |
| Get Started | `*Microsoft.Getstarted*` | Windows tutorial |
| Get Help | `*Microsoft.GetHelp*` | Help and support |

### Games (6 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Solitaire Collection | `*Microsoft.MicrosoftSolitaireCollection*` | Card games |
| Mahjong | `*Microsoft.MicrosoftMahjong*` | Tile matching game |
| Fresh Paint | `*Microsoft.FreshPaint*` | Digital painting |
| Network Speed Test | `*Microsoft.NetworkSpeedTest*` | Internet speed testing |
| MS Paint | `*Microsoft.MSPaint*` | Legacy paint program |

### Third-Party Bloatware (12 items)
Common on OEM systems and promotional installations:

| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| Candy Crush | `*CandyCrush*` | Match-3 game |
| Bubble Witch | `*BubbleWitch*` | Puzzle game |
| Wunderlist | `*Wunderlist*` | Task management |
| Flipboard | `*Flipboard*` | News aggregator |
| Twitter | `*Twitter*` | Social media |
| Facebook | `*Facebook*` | Social media |
| Spotify | `*Spotify*` | Music streaming |
| Minecraft | `*Minecraft*` | Sandbox game |
| Royal Revolt | `*Royal Revolt*` | Strategy game |
| Sway | `*Sway*` | Presentation tool |
| Speed Test | `*Speed Test*` | Network testing |
| Dolby | `*Dolby*` | Audio enhancement |

### Windows 11 Specific (5 items)
| Application | Package Pattern | Description |
|-------------|-----------------|-------------|
| To Do | `*Microsoft.Todos*` | Task management |
| Power Automate | `*Microsoft.PowerAutomateDesktop*` | Workflow automation |
| Microsoft Teams | `*MicrosoftTeams*` | Communication platform |
| Cortana | `*Microsoft.549981C3F5F10*` | Virtual assistant |
| Dev Home | `*Microsoft.Windows.DevHome*` | Developer tools |

## 🔧 Removal Process

The script performs a **three-level removal** to ensure complete cleanup:

### Level 1: Current User Packages
- Removes apps installed for the current user only
- Uses `Get-AppxPackage` and `Remove-AppxPackage`

### Level 2: All Users Packages  
- Removes apps installed system-wide for all users
- Uses `Get-AppxPackage -AllUsers` and `Remove-AppxPackage -AllUsers`

### Level 3: Provisioned Packages
- Removes app templates that auto-install for new users
- Uses `Get-AppxProvisionedPackage` and `Remove-AppxProvisionedPackage`
- Prevents bloatware from returning on new user accounts

## 📊 Removal Statistics

- **Total Bloatware Patterns**: 50+ removal patterns
- **Protected Applications**: 14 essential apps preserved
- **Categories Cleaned**: 8 major bloatware categories
- **Wildcard Matching**: Uses `*pattern*` for comprehensive detection
- **Multi-Level Cleanup**: 3 removal levels for complete elimination

## 🛠️ Additional Cleanup Actions

Beyond app removal, the script also:

### Registry Modifications
- Disables Windows content delivery suggestions
- Removes promotional content and ads
- Turns off app recommendations

### Windows 11 Specific Cleanup
- Removes Microsoft Teams Chat integration
- Disables Start menu suggestions
- Cleans promotional content delivery

## ⚠️ Important Notes

1. **Protected Apps**: Essential Windows functionality is preserved
2. **Wildcard Matching**: Patterns catch variations and updates of bloatware
3. **Safe Removal**: Apps are checked against protection list before removal
4. **Logging**: All removal attempts are logged with success/failure status
5. **No System Damage**: Only removes UWP/Store apps, not system components

## 🔄 Recovery Information

If you need to restore any removed applications:

1. **Microsoft Store**: Download from the Store if still available
2. **Windows Features**: Use `OptionalFeatures.exe` for built-in apps
3. **Reset PC**: Keep files option will restore default apps
4. **PowerShell**: Use `Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*AppName*"} | Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"`

---

*This catalog is automatically maintained and reflects the current bloatware removal patterns in the Setup-Automation.ps1 script.*
