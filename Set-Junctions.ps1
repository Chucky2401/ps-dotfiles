$scriptRoot = Split-Path $Script:MyInvocation.MyCommand.Path

New-Item -Path "$($env:APPDATA)\alacritty" -ItemType Junction -Value "$scriptRoot\alacritty"
