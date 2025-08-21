# Test script syntax validation
param([switch]$TestOnly)

try {
    $scriptPath = ".\Setup-Automation.ps1"
    $scriptContent = Get-Content $scriptPath -Raw
    
    # Parse the script to check for syntax errors
    $tokens = $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$tokens, [ref]$parseErrors)
    
    if ($parseErrors.Count -eq 0) {
        Write-Host "✓ Script syntax is valid!" -ForegroundColor Green
        Write-Host "✓ Found $($ast.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true).Count) functions" -ForegroundColor Green
        
        # List the functions found
        $functions = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)
        foreach ($func in $functions) {
            Write-Host "  - Function: $($func.Name)" -ForegroundColor Cyan
        }
        
        exit 0
    } else {
        Write-Host "✗ Script has syntax errors:" -ForegroundColor Red
        foreach ($parseError in $parseErrors) {
            Write-Host "  Line $($parseError.Extent.StartLineNumber): $($parseError.Message)" -ForegroundColor Red
        }
        exit 1
    }
} catch {
    Write-Host "✗ Error checking script: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
