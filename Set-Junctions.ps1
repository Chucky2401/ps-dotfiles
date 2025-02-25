$scriptRoot = Split-Path $Script:MyInvocation.MyCommand.Path
$myDocuments = $([System.Environment]::GetFolderPath("MyDocuments"))

If (-not (Test-Path "$env:APPDATA\alacritty")) {
  New-Item -Path "$($env:APPDATA)\alacritty" -ItemType Junction -Value "$scriptRoot\alacritty"
}

If (-not (Test-Path "$env:LOCALAPPDATA\nvim")) {
  New-Item -Path "$($env:LOCALAPPDATA)\nvim" -ItemType Junction -Value "$scriptRoot\nvim"
}

If (-not (Test-Path "$env:APPDATA\yazi")) {
  New-Item -Path "$($env:APPDATA)\yazi" -ItemType Junction -Value "$scriptRoot\yazi"
}

If (-not (Test-Path "$env:LOCALAPPDATA\Programs\oh-my-posh\themes")) {
  New-Item -Path "$env:LOCALAPPDATA\Programs\oh-my-posh\themes" -ItemType Junction -Value "$scriptRoot\oh-my-posh\themes"
}

If (-not (Test-Path "$myDocuments\PowerShell\Microsoft.PowerShell_profile.ps1")) {
  New-Item -Path "$myDocuments\PowerShell\Microsoft.PowerShell_profile.ps1" -ItemType HardLink -Value "$scriptRoot\Microsoft.PowerShell_profile.ps1"
}
