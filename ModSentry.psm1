@{
    RootModule        = 'Update-Modules.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a1b2c3d4-1234-5678-abcd-1234567890ab'
    Author            = 'Vitalii Antonyuk'
    Description       = 'Module to update local PowerShell modules from PSGallery.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Update-PowerShellModules')
    PrivateData       = @{
        PSData = @{
            Tags = @('modules', 'update', 'powershell')
            ProjectUri = 'https://github.com/crazyyy/ModSentry'
        }
    }
}
