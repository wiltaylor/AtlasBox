﻿$script:baseurl = "https://atlas.hashicorp.com"
$script:header = @{}
$script:username = ""

<#
    .SYNOPSIS
    Sets authentication details for use with the rest of this module.

    .DESCRIPTION
    This cmdlet sets the Auth token and username to use with the rest of this module.
    Please be aware the auth token is not your password.

    For more information on where to obtain a token from please visit: https://atlas.hashicorp.com/help/user-accounts/authentication

    .PARAMETER Token
    Atlas authentication token.

    .PARAMETER Username
    The user name which the boxes being worked with is assigned to.
#>
function Set-AtlasToken {
    param(
        [Parameter(Mandatory = $true)][string]$Token, 
        [Parameter(Mandatory = $true)][string]$Username)

    $script:token = $token
    $script:username = $username

    $script:header = @{
        "X-Atlas-Token" = $script:token
    }
}

<#
    .SYNOPSIS
    Clears set authentication token.

    .DESCRIPTION
    This removes the Atlas Auth token from the current session. You need to call Set-AtlasToken again to make use of other cmdlets in this module.
#>
function Clear-AtlasToken {
    $script:token = $null
    $script:username = $null
    $script:header = $null
}

<#
    .SYNOPSIS
    Test if a box exists.

    .DESCRIPTION
    This cmdlet will test if a box exists or not.

    .PARAMETER Name
    Name of box to test (do not include the username).
#>
function Test-AtlasBox {
    param([Parameter(Mandatory = $true)][string]$Name)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    try{
        $result = Get-AtlasBox -Name $name

        return $result -ne $null
    }catch{
        return $false
    }
}

<#
    .SYNOPSIS
    Get details of a box on atlas.

    .DESCRIPTION
    Returns an object containing all the details of the target box.

    .PARAMETER Name
    Name of box to return. (do not include the username).
    

#>
function Get-AtlasBox {
    param([Parameter(Mandatory = $true)][string]$Name)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name" -Headers $script:header
    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Creates a new box.

    .DESCRIPTION
    Creates a new box object for creating versions inside of.

    .PARAMETER Name
    Name of box to create. Do not include username in boxname.
    Name must only contain letters or numbers and must not have any spaces.

    .PARAMETER Private
    Set if box is private or not. By default it is set to false.
#>
function New-AtlasBox {
    param([
        Parameter(Mandatory = $true)][ValidatePattern("^[A-Za-z0-9.]+$")][string]$Name, 
        [bool]$Private = $false)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $body = @{
        "box[name]" = $name
        "box[is_private]" = $private
    }
    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/boxes" -Method Post -Headers $script:header -Body $body -ContentType "application/x-www-form-urlencoded"

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Removes a box object from atlas.

    .DESCRIPTION
    Removes a box object from atlas.

    .PARAMETER Name
    Name of box to return. (do not include the username).
#>
function Remove-AtlasBox{
    param([Parameter(Mandatory = $true)][string]$Name)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name" -Method Delete -Headers $script:header

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Sets properties on Atlas Box object.

    .DESCRIPTION
    Sets properties on the Atlas Box object. Leave parameters blank will leave their values as is.

    .PARAMETER Name
    Name of box to change properties on. To change box Name set Rename-AtlasBox cmdlet.

    .PARAMETER ShortDescription
    Sets the short description of the box.

    .PARAMETER Description
    sets the description of the box.

    .PARAMETER Private
    Sets the box to private

    .PARAMETER Public
    Sets the box to public.
#>
function Set-AtlasBox {
    param([Parameter(Mandatory = $true)][string]$Name, 
    [string]$ShortDescription, 
    [string]$Description, 
    [Parameter(ParameterSetName="Private")][switch]$Private, 
    [Parameter(ParameterSetName="Public")][switch]$Public)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $body = @{}

    if($shortdescription -ne $null) {
        $body.Add("box[short_description]", $shortdescription)
    }

    if($description -ne $null) {
        $body.Add("box[description]", $description)
    }   

    if($Private) {
        $body.Add("box[is_private]", $true)
    }

    if($Public) {
        $body.Add("box[is_private]", $false)
    }

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name" -Method Put -Headers $script:header -Body $body -ContentType "application/x-www-form-urlencoded"
}

<#
    .SYNOPSIS
    Renames a box.

    .DESCRIPTION
    Renames a box object on Atlas.

    .PARAMETER Name
    Name of box to rename. (Do not include user name).

    .PARAMETER NewName
    New name for target box (do not include user name).
#>
function Rename-AtlasBox {
    param([Parameter(Mandatory = $true)][string]$Name, 
    [Parameter(Mandatory = $true)][ValidatePattern("^[A-Za-z0-9]+$")][string]$NewName)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $body = @{ 'box[name]' = $newname }
    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name" -Method Put -Headers $script:header -Body $body -ContentType "application/x-www-form-urlencoded"
}

<#
    .SYNOPSIS
    Tests if box version object exists or not.

    .DESCRIPTION
    Tests if box version object exists or not.

    .PARAMETER Name
    Name of box to get version from.    

    .PARAMETER Version
    Version number to retrive. Versions are in symantic version format.

#>
function Test-AtlasBoxVersion {
    param([Parameter(Mandatory = $true)][string]$Name, [Parameter(Mandatory = $true)][string]$Version)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    try{
        $result = Get-AtlasBoxVersion -Name $Name -Version $Version

        return $result -ne $null
    }catch{
        return $false
    }
}

<#
    .SYNOPSIS
    Get a box version object.

    .DESCRIPTION
    Gets a box version object from atlas.

    .PARAMETER Name
    Name of box to get version from.    

    .PARAMETER Version
    Version number to retrive. Versions are in symantic version format.

#>
function Get-AtlasBoxVersion {
    param([Parameter(Mandatory = $true)][string]$Name, [Parameter(Mandatory = $true)][string]$Version)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version" -Headers $script:header

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Creates a new box version object.

    .DESCRIPTION
    Creates a new box version object.

    .PARAMETER Name
    Name of box to create the version inside of.

    .PARAMETER Version
    Name of version. This is in symantec versioning format.

    .PARAMETER Description
    Description to assign to version.
#>
function New-AtlasBoxVersion {
   param(
       [Parameter(Mandatory = $true)][string]$Name, 
       [Parameter(Mandatory = $true)][ValidatePattern("^[0-9]{1,8}\.[0-9]{1,5}\.[0-9]{1,5}")][string]$version, 
       [string]$description)   
   
   if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

   $body = @{
        "version[version]" = $version
    }

    if($description -ne $null) {
        $body.Add("version[description]", $description)
    }  

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/versions" -Method Post -Headers $script:header -Body $body -ContentType "application/x-www-form-urlencoded"

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Sets a value on the version object

    .DESCRIPTION
    Update values on a box version. Leave properties you want to leave as is off.

    .PARAMETER Name
    Name of box to change version on.

    .PARAMETER Version
    Version to change property on.

    .PARAMETER NewVersion
    New version name to change version to.

    .PARAMETER Description
    Description of version object.    
#>
function Set-AtlasBoxVersion {
    param(
        [Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$Version, 
        [ValidatePattern("^[0-9]{1,8}\.[0-9]{1,5}\.[0-9]{1,5}")][string]$NewVersion, 
        [string]$Description)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $body = @{}

    if($newversion -ne $null) {
        $body.Add("version[version]", $newversion)
    }

    if($description -ne $null) {
        $body.Add("version[description]", $description)
    }

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version" -Method Put -Headers $script:header -Body $body -ContentType "application/x-www-form-urlencoded"
}

<#
    .SYNOPSIS
    Removes a box version object from atlas.

    .DESCRIPTION
    Removes a box version object from atlas.

    .PARAMETER Name
    Name of box to remove verison from.

    .PARAMETER Version
    Name of version to remove from box.
#>
function Remove-AtlasBoxVersion {
    param([Parameter(Mandatory = $true)][string]$Name, [Parameter(Mandatory = $true)][string]$Version)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version" -Method Delete -Headers $script:header

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS 
    Publishes a box ready for use with vagrant.

    .DESCRIPTION
    Publishes (releases) a box ready for use with vagrant.

    .PARAMETER Name
    Name of box to publish.

    .PARAMETER Version
    Version of box to publish.
    
#>
function Publish-AtlasBoxVersion {
    param([Parameter(Mandatory = $true)][string]$Name, [Parameter(Mandatory = $true)][string]$Version)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version/release" -Method Put -Headers $script:header

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Unpublishes a box so it no longer is available to vagrant.

    .DESCRIPTION 
    Unpublishes (Revokes) a box so it is no longer available to vagrant.
    This is useful if there is an issue with the box and you want to stop people from downloading it.

    .PARAMETER Name
    Name of box to unpublish.

    .PARAMETER Version
    Version of box to unpublish.
    

#>
function Unpublish-AtlasBoxVersion {
    param([Parameter(Mandatory = $true)][string]$Name, [Parameter(Mandatory = $true)][string]$Version)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version/revoke" -Method Put -Headers $script:header

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Tests if a Atlas Box Provider object exists on atlas.

    .DESCRIPTION
    Tests if a Atlas Box Provider object exists on atlas.

    .PARAMETER Name
    Name of box object provider is a child of.

    .PARAMETER Version
    Version the provider object is a child of.

    .PARAMETER ProviderName
    Name of the provider.

#>
function Test-AtlasBoxProvider {
    param(
        [Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$Version, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$ProviderName)

        if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

        try{
            $result = Get-AtlasBoxProvider -Name $Name -Version $Version -ProviderName $ProviderName
            return $result -ne $null
        }catch{
            return $true
        }
}

<#
    .SYNOPSIS
    Gets a Atlas Box Provider object from atlas.

    .DESCRIPTION
    Gets a Atlas Box Provider object from atlas.

    .PARAMETER Name
    Name of box object provider is a child of.

    .PARAMETER Version
    Version the provider object is a child of.

    .PARAMETER ProviderName
    Name of the provider.

#>
function Get-AtlasBoxProvider {
    param(
        [Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$Version, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$ProviderName)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version/provider/$ProviderName" -Headers $script:header

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Creates a new atlas box provider object.

    .DESCRIPTION
    Creates a new atlas box provider object.

    .PARAMETER Name
    Name of box to create provider object in.

    .PARAMETER Version
    Version of box to create provider object in.

    .PARAMETER ProviderName
    Name of provider to create.

    .PARAMETER Url
    URL box is located at. If left off you can use Send-AtlasBoxProvider to upload image instead.

#>
function New-AtlasBoxProvider {
    param([Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$version, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$ProviderName, 
        [string]$Url)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $body = @{
        "provider[name]" = $ProviderName
    }

    if($url -ne $null) {
        $body.Add("provider[url]", $url)
    }  

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version/providers" -Method Post -Headers $script:header -Body $body -ContentType "application/x-www-form-urlencoded"

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Sets values on Atlas provider object.

    .DESCRIPTION
    Updates values on the box provider object.

    .PARAMETER Name
    Name of box to update provider object in.

    .PARAMETER Version
    Version to update provider in.

    .PARAMETER ProviderName
    Name of provider to update properties on.

    .PARAMETER Url
    Url to assign to provider. This is useful for provider types like azure or aws which don't store images on atlas.

    If you want to update the file hosted on atlas use the Send-AtlasBoxProvider instead.

    .PARAMETER NewProviderName
    New name of provider. Use this if the wrong box type was uploaded to a provider and you want to change the provider without reuploading it again.

#>
function Set-AtlasBoxProvider {
    param(
        [Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$Version, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$ProviderName, 
        [string]$Url, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$NewProviderName)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $body = @{}

    if($url -ne $null) {
        $body.Add("provider[url]", $url)
    }

    if($newProviderName -ne $null) {
        $body.Add("provider[name]", $newProviderName)
    }

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version/provider/$ProviderName" -Method Put -Headers $script:header -Body $body -ContentType "application/x-www-form-urlencoded"
}

<#
    .SYNOPSIS
    Removes a box provider from an atlas box.

    .DESCRIPTION
    Removes a box provider from an atlas box.

    .PARAMETER Name
    Name of box object to remove provider from.

    .PARAMETER Version
    Version to remove provider from.

    .PARAMETER ProviderName
    Name of provider to remove.

#>
function Remove-AtlasBoxProvider{
    param(
        [Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$Version, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$ProviderName)
    
    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version/provider/$ProviderName" -Method Delete -Headers $script:header

    return $result.content | ConvertFrom-Json
}

<#
    .SYNOPSIS
    Uploads a box file to a provider on atlas.

    .DESCRIPTION
    Use this cmdlet to upload box files to atlas.

    You must create a provider to upload into first with New-AtlasBoxProvider.

    Note: Please note that this current version does not support any form of progress indicator.

    .PARAMETER Name
    Name of box to upload box image into.

    .PARAMETER Version
    Version of box to upload the box image into.

    .PARAMETER ProviderName
    Provider object to upload image into.

    .PARAMETER Filename
    Path to local image to upload to atlas.
#>
function Send-AtlasBoxProvider{
    param(
        [Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$Version, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$ProviderName, 
        [Parameter(Mandatory = $true)][string]$Filename)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $result = Invoke-WebRequest -Uri "$script:baseurl/api/v1/box/$script:username/$name/version/$version/provider/$ProviderName/upload" -Method Get -Headers $script:header

    $uploadPath = ($result.content | ConvertFrom-Json).upload_path

    Write-Host $uploadPath 

    $webclient = New-Object System.Net.WebClient
    $uri = New-Object System.Uri($uploadPath)

    $webclient.UploadFile($uri, "PUT", $Filename)
}

<#
    .SYNOPSIS
    Downloads a box image from atlas.

    .DESCRIPTION
    Use this cmdlet to download box images from atlas.

    Note: Please note that this current version does not support any form of progress indicator.

        .PARAMETER Name
    Name of box to upload box image into.

    .PARAMETER Version
    Version of box to upload the box image into.

    .PARAMETER ProviderName
    Provider object to upload image into.

    .PARAMETER Filename
    Local path to download box image to.

#>
function Receive-AtlasBoxProvider{
    param(
        [Parameter(Mandatory = $true)][string]$Name, 
        [Parameter(Mandatory = $true)][string]$Version, 
        [Parameter(Mandatory = $true)][ValidateSet("virtualbox", "vmware_desktop", "hyperv", "aws", "digitalocean", "docker", "google", "rackspace", "parallels","veertu")][string]$ProviderName, 
        [Parameter(Mandatory = $true)][string]$Filename)

    if($script:token -eq $null) { Write-Error "You need to login first with Set-AtlasToken"; return}

    $webclient = New-Object System.Net.WebClient
    $webclient.Headers.Add("Content-Type","application/x-www-form-urlencoded")
    $webclient.Headers.Add("X-Atlas-Token", $script:token )
    
    $uri = New-Object System.Uri("$script:baseurl/$script:username/$name/version/$version/provider/$ProviderName.box")

    $webclient.DownloadFile($uri, $Filename)
}