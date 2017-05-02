@{
    RootModule = 'AtlasBox.psm1'
    ModuleVersion = '1.1.0'
    GUID = '3ef447a5-63e8-4bf1-9f7a-3caf86a9b480'
    Author = 'Wil Taylor'
    Copyright = 'Copyright (c) 2017 by Wil Taylor.'
    Description = 'Module for managing box images on Hashicorps Atlas service.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @( 
        'Set-AtlasToken'
        'Clear-AtlasToken'
        'Test-AtlasBox'
        'Get-AtlasBox'
        'New-AtlasBox'
        'Remove-AtlasBox'
        'Set-AtlasBox'
        'Rename-AtlasBox'
        'Test-AtlasBoxVersion'
        'Get-AtlasBoxVersion'
        'New-AtlasBoxVersion'
        'Set-AtlasBoxVersion'
        'Remove-AtlasBoxVersion'
        'Publish-AtlasBoxVersion'
        'Unpublish-AtlasBoxVersion'
        'Test-AtlasBoxProvider'
        'Get-AtlasBoxProvider'
        'New-AtlasBoxProvider'
        'Set-AtlasBoxProvider'
        'Remove-AtlasBoxProvider'
        'Send-AtlasBoxProvider'
        'Receive-AtlasBoxProvider'
    )

    PrivateData = @{
        PSData = @{
            Category = "Tool"
            Tags = @('packer', 'hashicorp', 'vagrant', 'atlas', 'box')
            IsPrerelease = 'False'
        }
    }
}