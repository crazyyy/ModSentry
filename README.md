# ModSentry 🔧🚀

ModSentry is a PowerShell module designed to streamline the management of PowerShell modules in a specified directory. It checks for newer versions of modules in the PowerShell Gallery (PSGallery), updates outdated modules, and allows you to exclude specific modules from the update process.

## Features ✨

- 🔄 Automatically updates itself via Git (`git pull`)
- 📁 Scans a specified folder for installed modules
- ⬆️ Checks for newer versions in PSGallery
- ❌ Skips excluded modules by name
- ✅ Color-coded output for better readability

- **Scan and Update**: Scans a local directory for PowerShell modules and updates them to the latest version available in PSGallery.
- **Exclude Modules**: Specify modules to skip during the update process.
- **Error Handling**: Provides detailed feedback on successes, skips, and errors during the update process.
- **Customizable Path**: Allows you to define the directory containing the modules to be checked.

## Usage 💻

```powershell
# Import the module
Import-Module ./ModSentry.psm1

# Run the update function
Update-PowerShellModules
```

## Requirements
- PowerShell 5.1 or later
- Access to the PowerShell Gallery (PSGallery)
- Write permissions to the specified modules directory

## Installation
1. Download the `ModSentry.psm1` file from the [releases page](#).
2. Place it in a directory listed in your `$PSModulePath` (e.g., `C:\Program Files\WindowsPowerShell\Modules\ModSentry`).
3. Import the module using:
   ```powershell
   Import-Module ModSentry
   ```

### Example
```powershell
Update-PowerShellModules -ModulesPath "D:\apps\PowerShell\Modules" -ExcludedModules @("PowerShellAI", "Pansies")
```

### Parameters
- **ModulesPath**: The directory containing the PowerShell modules to check and update. Default: `D:\apps\PowerShell\Modules`.
- **ExcludedModules**: An array of module names to exclude from updates. Default: A predefined list of common modules.

### Output
The function outputs:
- The directory being scanned.
- Status for each module (skipped, up-to-date, updated, or error).
- A summary of the total modules checked and updated.

## Example Output
```
Scanning for modules in directory: D:\apps\PowerShell\Modules
Skipping excluded module: PowerShellAI
Module PSReadLine is already up to date (version 2.2.6).
Updating PSScriptAnalyzer: 1.20.0 -> 1.21.0
PSScriptAnalyzer updated to version 1.21.0.
Update complete. Modules checked: 10, updated: 1.
```

## Contributing
Contributions are welcome! Please submit a pull request or open an issue on the [GitHub repository](#).

## License
This project is licensed under the MIT License. See the [LICENSE](#) file for details.
