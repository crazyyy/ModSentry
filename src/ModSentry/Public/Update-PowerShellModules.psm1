#Requires -Version 5.1

function Update-PowerShellModules {
    <#
    .SYNOPSIS
    Updates PowerShell modules in the specified folder or in all $env:PSModulePath folders if not specified.

    .DESCRIPTION
    Scans a local folder (or all module paths if none is specified) and updates modules found there using PSGallery.
    You can exclude specific modules from update.

    .PARAMETER ModulesPath
    Optional. Path to the folder containing modules to check. If not specified, all paths from $env:PSModulePath are used.

    .PARAMETER ExcludedModules
    List of module names to exclude from updating.

    .EXAMPLE
    Update-PowerShellModules
    .EXAMPLE
    Update-PowerShellModules -ModulesPath "D:\MyModules"
    #>

    [CmdletBinding()]
    param (
        [string]$ModulesPath,

        [string[]]$ExcludedModules = @(
            "PowerShellAI", "Template", "Pansies", "ModSentry","PSDiagnostics","gsudoModule","AppBackgroundTask","Appx",
            "PowerShellAI.Functions", "Microsoft.WinGet.Client","BitLocker","AssignedAccess","BitsTransfer","BranchCache","ConfigDefenderPerformance",
            "Microsoft.WinGet.DSC", "Microsoft.PowerToys.Configure","DefenderPerformance","DeliveryOptimization","DirectAccessClientComponents", "Dism",
            "DnsClient","EventTracingManagement", "HgsClient", "Hyper-V", "LAPS", "LanguagePackManagement",
            "Microsoft.PowerShell.Operation.Validation", "CimCmdlets", "Microsoft.PowerShell.Diagnostics", "Microsoft.PowerShell.Host",
            "Microsoft.PowerShell.Management","Microsoft.PowerShell.Security","Microsoft.PowerShell.Utility","Microsoft.WSMan.Management"
        )
    )

    # Update self (this module) from git
    try {
        $moduleRoot = $PSScriptRoot
        if (Test-Path "$moduleRoot\.git") {
            Write-Host "🔄 Pulling latest version of ModSentry from Git..." -ForegroundColor Cyan
            Push-Location $moduleRoot
            git pull
            Pop-Location
        }
    } catch {
        Write-Host "❌ Failed to update ModSentry module via git: $_" -ForegroundColor Red
    }

    # Get module paths
    $pathsToScan = @()
    if ([string]::IsNullOrWhiteSpace($ModulesPath)) {
        $pathsToScan = $env:PSModulePath -split ';' | Where-Object { Test-Path $_ } | Select-Object -Unique
    } else {
        if (Test-Path $ModulesPath) {
            $pathsToScan = @($ModulesPath)
        } else {
            Write-Host "❌ Directory not found: ${ModulesPath}" -ForegroundColor Red
            return
        }
    }

    $totalUpdated = 0

    foreach ($path in $pathsToScan) {
        Write-Host "📁 Scanning module directory: $path" -ForegroundColor Cyan

        $modules = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue
        if ($modules.Count -eq 0) {
            Write-Host "⚠️ No modules found in: $path" -ForegroundColor Yellow
            continue
        }

        foreach ($module in $modules) {
            $moduleName = $module.Name

            if ($ExcludedModules -contains $moduleName) {
                Write-Host "⏭️ Skipping excluded module: ${moduleName}" -ForegroundColor DarkGray
                continue
            }

            try {
                $installedVersion = (Get-Module -ListAvailable -Name $moduleName |
                    Sort-Object Version -Descending | Select-Object -First 1).Version

                if (-not $installedVersion) {
                    Write-Host "❔ Module ${moduleName} not recognized by Get-Module." -ForegroundColor Yellow
                    continue
                }

                $galleryModule = Find-Module -Name $moduleName -ErrorAction Stop -AllowPrerelease -Repository 'PSGallery'
                $latestVersion = $galleryModule.Version

                if ($latestVersion -gt $installedVersion) {
                    Write-Host "⬆️ Updating ${moduleName}: ${installedVersion} -> ${latestVersion}" -ForegroundColor Yellow
                    Save-Module -Name $moduleName -Force -Path $path -RequiredVersion $latestVersion -AllowPrerelease
                    Write-Host "✅ ${moduleName} updated to version ${latestVersion}." -ForegroundColor Green
                    $totalUpdated++
                }
                else {
                    Write-Host "✔️ ${moduleName} is already up to date (${installedVersion})." -ForegroundColor DarkGray
                }
            }
            catch {
                Write-Host "❌ Error updating ${moduleName}: $_" -ForegroundColor Red
            }
        }
    }

    Write-Host "✅ All scans complete. Modules updated: $totalUpdated" -ForegroundColor Cyan
}
