# ==============================================================================
# Quick Build Script - Convenience Wrapper for IN5340 Presentations
# ==============================================================================
# 
# This is a convenience script that can be run from anywhere to build any project.
# It uses the main build_presentation.ps1 script in the scripts folder.
#
# Usage from workspace root:
#   .\build.ps1                  # Build Project 2 (default)
#   .\build.ps1 1                # Build Project 1
#   .\build.ps1 3 -SkipNotebook  # Build Project 3, skip notebook execution
#   .\build.ps1 -Help            # Show full help
#
# ==============================================================================

param(
    [int]$Project = 1,
    [switch]$SkipNotebook,
    [switch]$SkipLatex,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Build Script for IN5340 Project Presentations
==============================================

This script provides a convenient way to build any project presentation from the workspace root.

USAGE:
  .\build.ps1 [project] [-SkipNotebook] [-SkipLatex] [-Help]

PARAMETERS:
  project          : Project number (1, 2, 3, ...). Default: 2
  -SkipNotebook    : Skip notebook execution, only extract figures
  -SkipLatex       : Skip LaTeX compilation, only execute notebook
  -Help            : Show this help message

EXAMPLES:
  .\build.ps1                    # Build Project 2 (default)
  .\build.ps1 1                  # Build Project 1
  .\build.ps1 3 -SkipNotebook    # Build Project 3, skip notebook
  .\build.ps1 2 -SkipLatex       # Execute notebook, skip LaTeX
  .\build.ps1 2 -SkipNotebook -SkipLatex # Do nothing (debug)

OUTPUT:
  - Extracted figures: Project_X/presentation/figs/plot_NN.png
  - Compiled PDF: Project_X/presentation/presentation_pX.pdf

REQUIREMENTS:
  - Conda environment 'in5340' with nbformat, nbclient
  - MiKTeX or TeX Live with pdflatex
  - Python 3.8+ with standard libraries

TROUBLESHOOTING:
  - If notebook fails: run "conda activate in5340; jupyter notebook Project_X/project_X.ipynb"
  - If pdflatex not found: add MiKTeX to PATH or reinstall TeX Live
  - For detailed output: check Project_X/presentation/*.log files

"@
    exit 0
}

# Enable script execution in this process
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Find workspace root (where this script is located)
$workspace_root = $PSScriptRoot
$build_script = Join-Path -Path (Join-Path -Path $workspace_root -ChildPath "scripts") -ChildPath "build_presentation.ps1"

if (-not (Test-Path $build_script)) {
    Write-Host "ERROR: Build script not found at: $build_script" -ForegroundColor Red
    exit 1
}

# Forward all parameters to main build script
Write-Host "Forwarding to: $build_script" -ForegroundColor Gray
& $build_script -Project $Project $(if ($SkipNotebook) {"-SkipNotebook"}) $(if ($SkipLatex) {"-SkipLatex"})
