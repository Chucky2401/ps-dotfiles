$scriptRoot = Split-Path $Script:MyInvocation.MyCommand.Path

If (-not (Test-Path "$env:APPDATA\alacritty")) {
  New-Item -Path "$($env:APPDATA)\alacritty" -ItemType Junction -Value "$scriptRoot\alacritty"
}

If (-not (Test-Path "$env:LOCALAPPDATA\nvim")) {
  New-Item -Path "$($env:LOCALAPPDATA)\nvim" -ItemType Junction -Value "$scriptRoot\nvim"
}

If (-not (Test-Path "$env:APPDATA\yazi")) {
  New-Item -Path "$($env:APPDATA)\yazi" -ItemType Junction -Value "$scriptRoot\yazi"
}
