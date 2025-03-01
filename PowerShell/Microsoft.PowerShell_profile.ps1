Import-Module Tjvs.Utils
# Import-Module Tjvs.Utils, Tjvs.Packages
$modulesRequire = @('posh-git', 'Terminal-Icons', 'PSReadLine', 'PSFzF', 'Microsoft.WinGet.CommandNotFound')
#
# Install-Modules -Names $modulesRequire
#
foreach ($module in $modulesRequire) {
  If (-not (Get-Module -ListAvailable -Name $module)) {
    Import-Module -Name $module
  }
}
#
# $packagesRequire = @('junegunn.fzf', 'Git.Git')
# 
# Import-Module -Name posh-git, Terminal-Icons, PSReadLine, Tjvs.Utils, PSFzF, Microsoft.WinGet.CommandNotFound

$env:POSH_GIT_ENABLED = $true
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\mytheme.omp.json" | Invoke-Expression

Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

function Update-PowerShellCore {
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
}

Set-CustomAliases
