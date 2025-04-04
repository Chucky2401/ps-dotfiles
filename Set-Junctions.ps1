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

$junctions = @(
  [PSCustomObject]@{
    Path  = "$($env:APPDATA)\alacritty"
    Value = "$scriptRoot\alacritty"
  },
  [PSCustomObject]@{
    Path  = "$($env:LOCALAPPDATA)\nvim"
    Value = "$scriptRoot\nvim"
  },
  [PSCustomObject]@{
    Path  = "$($env:APPDATA)\yazi"
    Value = "$scriptRoot\yazi"
  },
  [PSCustomObject]@{
    Path  = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
    Value = "$scriptRoot\oh-my-posh\themes"
  },
  [PSCustomObject]@{
    Path  = "$myDocuments\PowerShell"
    Value = "$scriptRoot\PowerShell"
  },
  [PSCustomObject]@{
    Path  = "$myDocuments\PowerShell\Modules\Tjvs.Utils"
    Value = "$scriptRoot\ps-common\modules\Tjvs.Utils"
  },
  [PSCustomObject]@{
    Path  = "$env:LOCALAPPDATA\lazygit"
    Value = "$scriptRoot\lazygit"
  },
  [PSCustomObject]@{
    Path  = "$env:USERPROFILE\.gnupg"
    Value = "$scriptRoot\.gnupg"
  }
)

foreach ($junction in $junctions) {
  Add-Junction -Destination $junction.Path -Source $junction.Value -Root $scriptRoot
}
