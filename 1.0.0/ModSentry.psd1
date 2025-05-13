#Requires -Version 5.1

function Update-PowerShellModules {
    <#
    .SYNOPSIS
    Updates PowerShell modules in the specified folder if a newer version is available from PSGallery.

    .DESCRIPTION
    This function scans a local folder with installed modules and compares each with its version in PSGallery.
    If a newer version is found, it downloads the update. You can exclude specific modules by name.

    .PARAMETER ModulesPath
    Path to the folder containing modules to check and update.

    .PARAMETER ExcludedModules
    List of module names to exclude from updating.

    .EXAMPLE
    Update-PowerShellModules -ModulesPath "D:\apps\PowerShell\Modules"

    .OUTPUTS
    Console output showing update results and skipped modules.
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ModulesPath = "D:\apps\PowerShell\Modules",

        [Parameter()]
        [string[]]$ExcludedModules = @(
            "PowerShellAI",
            "Pansies",
            "Template",
            "PowerShellAI.Functions",
            "Microsoft.PowerToys.Configure",
            "Microsoft.PowerShell.Operation.Validation"
        )
    )

    # Validate path
    if (-not (Test-Path -Path $ModulesPath)) {
        Write-Host "Directory not found: ${ModulesPath}" -ForegroundColor Red
        return
    }

    # Announce scanning location
    Write-Host "Scanning for modules in directory: ${ModulesPath}" -ForegroundColor Cyan

    $installedModules = Get-ChildItem -Path $ModulesPath -Directory
    if ($installedModules.Count -eq 0) {
        Write-Host "No modules found in directory: ${ModulesPath}" -ForegroundColor Yellow
        return
    }

    $updatedModules = 0

    foreach ($module in $installedModules) {
        $moduleName = $module.Name

        # Skip excluded modules
        if ($ExcludedModules -contains $moduleName) {
            Write-Host "Skipping excluded module: ${moduleName}" -ForegroundColor DarkGray
            continue
        }

        try {
            # Get installed version
            $installedVersion = (Get-Module -ListAvailable -Name $moduleName |
                Sort-Object Version -Descending | Select-Object -First 1).Version

            if (-not $installedVersion) {
                Write-Host "Module ${moduleName} is not recognized by Get-Module." -ForegroundColor Yellow
                continue
            }

            # Get latest version from PSGallery
            $galleryModule = Find-Module -Name $moduleName -ErrorAction Stop -AllowPrerelease -Repository 'PSGallery'
            $latestVersion = $galleryModule.Version

            if ($latestVersion -gt $installedVersion) {
                Write-Host "Updating ${moduleName}: ${installedVersion} -> ${latestVersion}" -ForegroundColor Yellow

                Save-Module -Name $moduleName -Force -Path $ModulesPath -RequiredVersion $latestVersion -AllowPrerelease

                Write-Host "${moduleName} updated to version ${latestVersion}." -ForegroundColor Green
                $updatedModules++
            }
            else {
                Write-Host "${moduleName} is already up to date (version ${installedVersion})." -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Host "Error updating ${moduleName}: $_" -ForegroundColor Red
        }
    }

    Write-Host "Update complete. Modules checked: $($installedModules.Count), updated: ${updatedModules}." -ForegroundColor Cyan
}
