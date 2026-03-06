<#
.SYNOPSIS
  Scaffold a new IN5450/IN9450 Beamer presentation from a template.

.EXAMPLE
  .\scripts\new_in5450_presentation.ps1 -ProjectDir .\Project_2 -Output presentation_p2.tex -Title "IN5450 Project II" -ShortTitle "IN5450 P2" -Author "Theodor Wålberg" -Compile

.NOTES
  - By default writes to a `-presentation/` folder inside the project directory.
  - Expects a `figs/` folder inside the presentation folder.
  - Uses pdflatex if -Compile is provided.
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDir,

  [Parameter(Mandatory = $true)]
  [string]$Output,

  [Parameter(Mandatory = $true)]
  [string]$Title,

  [Parameter(Mandatory = $true)]
  [string]$ShortTitle,

  [Parameter(Mandatory = $true)]
  [string]$Author,

  [string]$PresentationDir = "presentation",

  [string]$Date = (Get-Date -Format "MMMM yyyy"),

  [switch]$Compile,

  [switch]$Force
)

$ErrorActionPreference = 'Stop'

$templatePath = Join-Path $PSScriptRoot "in5450_beamer_template.tex"

if (-not (Test-Path $templatePath)) {
  throw "Template not found: $templatePath"
}

$projectPath = Resolve-Path $ProjectDir
$presentationPath = Join-Path $projectPath $PresentationDir

New-Item -ItemType Directory -Path $presentationPath -Force | Out-Null
$outPath = Join-Path $presentationPath $Output

if ((Test-Path $outPath) -and (-not $Force)) {
  throw "Output already exists: $outPath (use -Force to overwrite)"
}

$template = Get-Content -LiteralPath $templatePath -Raw

$rendered = $template
$rendered = $rendered.Replace("{{TITLE}}", $Title)
$rendered = $rendered.Replace("{{SHORT_TITLE}}", $ShortTitle)
$rendered = $rendered.Replace("{{AUTHOR}}", $Author)
$rendered = $rendered.Replace("{{DATE}}", $Date)

Set-Content -LiteralPath $outPath -Value $rendered -Encoding UTF8
Write-Host "Wrote: $outPath"

if ($Compile) {
  Push-Location $presentationPath
  try {
    Write-Host "Compiling with pdflatex..."
    pdflatex -interaction=nonstopmode -halt-on-error $Output | Out-Host
    pdflatex -interaction=nonstopmode -halt-on-error $Output | Out-Host
  }
  finally {
    Pop-Location
  }
}
