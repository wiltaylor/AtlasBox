$apikey = $env:poshapikey
$version = $env:APPVEYOR_BUILD_VERSION

New-Item "$HOME\Documents\WindowsPowerShell\Modules" -Force -ErrorAction SilentlyContinue -ItemType Directory
Copy-Item $PSScriptRoot "$HOME\Documents\WindowsPowerShell\Modules" -Force -Recurse -Exclude '.git\*.*', 'build.ps1', "README.md"
Remove-Item "$HOME\Documents\WindowsPowerShell\Modules\AtlasBox\.git" -Force -Recurse

(Get-Content -Path "$PSScriptRoot\AtlasBox.psd1") -replace "%BUILDVERSION%", $version | Out-File "$HOME\Documents\WindowsPowerShell\Modules\AtlasBox\AtlasBox.psd1"

Publish-Module -Name AtlasBox -NuGetApiKey $apikey