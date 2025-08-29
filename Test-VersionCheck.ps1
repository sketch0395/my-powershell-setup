# Test script to verify PowerShell version checking logic
Write-Host "Testing PowerShell Version Check Logic" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Function to test version comparison
function Test-VersionCheck {
    param(
        [string]$TestVersion,
        [string]$RequiredVersion = "7.5.2"
    )
    
    $required = [Version]$RequiredVersion
    $test = [Version]$TestVersion
    
    Write-Host "Testing Version: $TestVersion against Required: $RequiredVersion" -ForegroundColor Yellow
    
    if ($test -lt $required) {
        Write-Host "❌ FAIL: Version $TestVersion is below required $RequiredVersion" -ForegroundColor Red
        return $false
    } else {
        Write-Host "✅ PASS: Version $TestVersion meets requirement $RequiredVersion" -ForegroundColor Green
        return $true
    }
}

# Test various versions
Write-Host "Test Cases:" -ForegroundColor White
Write-Host ""

# Test versions that should fail
Test-VersionCheck "5.1.0"     # Windows PowerShell
Test-VersionCheck "7.0.0"     # Early PowerShell 7
Test-VersionCheck "7.4.0"     # Recent but still old
Test-VersionCheck "7.5.1"     # Close but not quite

Write-Host ""

# Test versions that should pass
Test-VersionCheck "7.5.2"     # Exact match
Test-VersionCheck "7.5.3"     # Newer patch
Test-VersionCheck "7.6.0"     # Newer minor
Test-VersionCheck "8.0.0"     # Future major

Write-Host ""
Write-Host "Current PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
$currentPasses = Test-VersionCheck $PSVersionTable.PSVersion.ToString()

if ($currentPasses) {
    Write-Host "✅ Your current PowerShell version will pass the version check!" -ForegroundColor Green
} else {
    Write-Host "❌ Your current PowerShell version will trigger the upgrade prompt!" -ForegroundColor Red
}
