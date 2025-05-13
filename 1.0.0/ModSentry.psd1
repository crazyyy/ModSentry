@{
    RootModule        = 'ModSentry.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'f233c91d-9c5b-45d2-95bc-a4b8f8f3f0aa'
    Author            = 'Vitaliy Antonyuk'
    Description       = '🔧 ModSentry: Auto-update and manage your PowerShell modules locally with style 🚀'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Update-PowerShellModules')
    PrivateData       = @{
        PSData = @{
            Tags = @('modules', 'update', 'powershell', 'automation')
            ProjectUri = 'https://github.com/crazyyy/ModSentry'
        }
    }
}
