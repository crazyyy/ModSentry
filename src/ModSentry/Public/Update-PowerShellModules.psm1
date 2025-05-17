#Requires -Version 5.1

function Update-PowerShellModule {
    <#
    .SYNOPSIS
        Updates PowerShell modules in the specified folder or all $env:PSModulePath folders.

    .DESCRIPTION
        Scans a local folder (or all module paths if none is specified) and updates modules found there using PSGallery.
        You can exclude specific modules from updating.

    .PARAMETER ModulesPath
        Optional. Path to the folder containing modules to check. If not specified, all paths from $env:PSModulePath are used.

    .PARAMETER ExcludedModules
        List of module names to exclude from updating.

    .EXAMPLE
        Update-PowerShellModule
        Updates all modules in $env:PSModulePath, excluding specified modules.

    .EXAMPLE
        Update-PowerShellModule -ModulesPath "D:\MyModules"
        Updates modules in the specified path.

    .NOTES
        Author: [Your Name]
        Date: May 18, 2025
        Requires: PowerShell 5.1 or later
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$ModulesPath,

        [string[]]$ExcludedModules = @(
            "PowerShellAI", "Template", "Pansies", "ModSentry", "PSDiagnostics", "gsudoModule", "AppBackgroundTask", "Appx",
            "PowerShellAI.Functions", "Microsoft.WinGet.Client", "BitLocker", "AssignedAccess", "BitsTransfer", "BranchCache", "ConfigDefenderPerformance",
            "Microsoft.WinGet.DSC", "Microsoft.PowerToys.Configure", "DefenderPerformance", "DeliveryOptimization", "DirectAccessClientComponents", "Dism",
            "DnsClient", "EventTracingManagement", "HgsClient", "Hyper-V", "LAPS", "LanguagePackManagement",
            "Microsoft.PowerShell.Operation.Validation", "CimCmdlets", "Microsoft.PowerShell.Diagnostics", "Microsoft.PowerShell.Host",
            "Microsoft.PowerShell.Management", "Microsoft.PowerShell.Security", "Microsoft.PowerShell.Utility", "Microsoft.WSMan.Management"
        )
    )

    # Update self (this module) from git
    try {
        $moduleRoot = $PSScriptRoot
        if (Test-Path "$moduleRoot\.git") {
            Write-Verbose "[Info] Pulling latest version of ModSentry from Git..."
            Push-Location $moduleRoot
            git pull
            Pop-Location
        }
    }
    catch {
        Write-Error "[Error] Failed to update ModSentry module via git: $_"
    }

    # Get module paths
    $pathsToScan = @()
    if ([string]::IsNullOrWhiteSpace($ModulesPath)) {
        $pathsToScan = $env:PSModulePath -split ';' | Where-Object { Test-Path $_ } | Select-Object -Unique
    }
    else {
        if (Test-Path $ModulesPath) {
            $pathsToScan = @($ModulesPath)
        }
        else {
            Write-Warning "[Warning] Directory not found: $ModulesPath"
            return
        }
    }

    $totalUpdated = 0

    foreach ($path in $pathsToScan) {
        Write-Verbose "[Info] Scanning module directory: $path"

        $modules = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue
        if ($modules.Count -eq 0) {
            Write-Warning "[Warning] No modules found in: $path"
            continue
        }

        foreach ($module in $modules) {
            $moduleName = $module.Name

            if ($ExcludedModules -contains $moduleName) {
                Write-Verbose "[Info] Skipping excluded module: $moduleName"
                continue
            }

            try {
                $installedVersion = (Get-Module -ListAvailable -Name $moduleName | Sort-Object Version -Descending | Select-Object -First 1).Version

                if (-not $installedVersion) {
                    Write-Warning "[Warning] Module $moduleName not recognized by Get-Module."
                    continue
                }

                $galleryModule = Find-Module -Name $moduleName -ErrorAction Stop -AllowPrerelease -Repository 'PSGallery'
                $latestVersion = $galleryModule.Version

                if ($latestVersion -gt $installedVersion) {
                    if ($PSCmdlet.ShouldProcess("$moduleName", "Update from version $installedVersion to $latestVersion")) {
                        Write-Verbose "[Info] Updating $moduleName : $installedVersion -> $latestVersion"
                        Save-Module -Name $moduleName -Force -Path $path -RequiredVersion $latestVersion -AllowPrerelease
                        Write-Information "[Success] $moduleName updated to version $latestVersion." -InformationAction Continue
                        $totalUpdated++
                    }
                }
                else {
                    Write-Verbose "[Info] $moduleName is already up to date ($installedVersion)."
                }
            }
            catch {
                Write-Error "[Error] Failed to update $moduleName : $_"
            }
        }
    }

    Write-Information "[Summary] All scans complete. Modules updated: $totalUpdated" -InformationAction Continue
}