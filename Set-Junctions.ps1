function Test-ArrayMatchContains {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
  Param (
    [Parameter(Mandatory = $True)]
    [Object[]]$Array,
    [Parameter(Mandatory = $True)]
    [String]$Pattern
  )

  $isMatched = $False

  foreach ($item in $Array) {
    If ($item -match $Pattern) {
      $isMatched = $True
    }
  }

  return $isMatched
}

function Set-Junction {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low", DefaultParameterSetName = "Object")]
  Param(
    [Parameter(Mandatory = $True, ParameterSetName = "Object")]
    [PSCustomObject]$Object,
    [Parameter(Mandatory = $True, ParameterSetName = "String")]
    [String]$Source,
    [Parameter(Mandatory = $True, ParameterSetName = "String")]
    [String]$Destination,
    [Parameter(Mandatory = $True, ParameterSetName = "String")]
    [String]$Root
  )

  $isInclude = $False
  $parameters = @{
    Path        = $Source
  }

  If ($PSCmdlet.ParameterSetName -eq "Object") {
    $Source      = $Object.Source
    $Destination = $Object.Destination
    $Root        = $Object.Root
  }

  $temporaryName     = "$(Split-Path -Path $Destination -Leaf).bak"
  $temporaryFullName = "$($Destination).bak"
  $targetName        = Split-Path -Path $Source -Leaf
  $gitignoreFile     = Join-Path -Path $Root -ChildPath ".gitignore"

  $pattern          = "^"
  $filterType       = "Exclude"
  $gitignoreContent = Get-Content -Path $gitignoreFile | Where-Object { $PSItem -match "^(?:!)?$targetName/" }

  If ($null -ne $gitignoreContent) {
    $isInclude        = Test-ArrayMatchContains -Array $gitignoreContent -Pattern "^!"

    If ($isInclude) {
      $filterType = "Filter"
      $pattern    = "^!"
    }

    $filter     = ($gitIgnoreContent | Where-Object { $PSItem -match $pattern }) -replace "$pattern$targetName/"
    $parameters.Add($filterType, $filter)
  }

  $contentTarget = Get-ChildItem @parameters
  $contentPath   = Get-ChildItem -Path $Destination

  $toGetBack = (Compare-Object -ReferenceObject $contentTarget -DifferenceObject $contentPath -Property Name).Name

  Rename-Item -Path $Destination -NewName $temporaryName
  New-Item -Path $Destination -ItemType Junction -Value $Source | Out-Null

  Get-ChildItem $temporaryFullName | Where-Object { $toGetBack -contains $PSItem.Name } | `
    Move-Item -Destination $Destination

  Remove-Item -Path $temporaryFullName -Recurse -Force
}

function Add-Junction {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low", DefaultParameterSetName = "Object")]
  Param(
    [Parameter(Mandatory = $True, ParameterSetName = "Object")]
    [PSCustomObject]$Object,
    [Parameter(Mandatory = $True, ParameterSetName = "String")]
    [String]$Source,
    [Parameter(Mandatory = $True, ParameterSetName = "String")]
    [String]$Destination,
    [Parameter(Mandatory = $True, ParameterSetName = "String")]
    [String]$Root
  )

  If ($PSCmdlet.ParameterSetName -eq "Object") {
    $Source      = $Object.Source
    $Destination = $Object.Destination
    $Root        = $Object.Root
  }

  If (-not (Test-Path $Destination)) {
    New-Item -Path $Destination -ItemType Junction -Value $Source | Out-Null
    return
  }

  If ([String]::IsNullOrEmpty((Get-ItemProperty $Destination).LinkType)) {
    Set-Junction -Source $Source -Destination $Destination -Root $Root
  }
}

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

Add-Junction -Destination "$env:LOCALAPPDATA\Programs\oh-my-posh\themes" -Source "$scriptRoot\oh-my-posh\themes" -Root $scriptRoot

Add-Junction -Destination "$myDocuments\PowerShell" -Source "$scriptRoot\PowerShell" -Root $scriptRoot

If (-not (Test-Path "$myDocuments\PowerShell\Modules\Tjvs.Utils")) {
  New-Item -Path "$myDocuments\PowerShell\Modules\Tjvs.Utils" -ItemType Junction -Value "$scriptRoot\ps-common\modules\Tjvs.Utils"
}

If (-not (Test-Path "$env:LOCALAPPDATA\lazygit")) {
  New-Item -Path "$env:LOCALAPPDATA\lazygit" -ItemType Junction -Value "$scriptRoot\lazygit"
}
