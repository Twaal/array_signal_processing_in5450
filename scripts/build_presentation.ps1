# =============================================================================
# Build Presentation for IN5450/IN9450 Projects
# =============================================================================
# 
# Usage:
#   .\scripts\build_presentation.ps1 [-Project 2] [-NoExecute] [-SkipNotebook] [-SkipLatex]
#
# Parameters:
#   -Project <int>      : Project number (1, 2, etc.). Default: 1
#   -NoExecute          : Extract figures from notebook without executing it
#                         (use when notebook already has embedded outputs, e.g. from MATLAB)
#   -SkipNotebook       : Skip notebook figure extraction entirely
#   -SkipLatex          : Skip LaTeX compilation, only extract figures
#
# Description:
#   This script automates the complete build pipeline for IN5450 project
#   presentations:
#   1. Extracts PNG plots from Jupyter notebook outputs to presentation/figs/
#      (optionally executing the notebook first, or just reading existing outputs)
#   2. Compiles LaTeX presentation to PDF (presentation_pX.tex)
#
# Prerequisites:
#   - Python with nbformat (conda in5450 environment)
#   - nbclient also needed if executing notebooks (omit -NoExecute)
#   - LaTeX distribution with pdflatex
#   - Notebook: Project_X/project_X.ipynb
#   - LaTeX file: Project_X/presentation/presentation_pX.tex
#
# Output:
#   - Figures: Project_X/presentation/figs/plot_01.png through plot_NN.png
#   - PDF: Project_X/presentation/presentation_pX.pdf (if LaTeX succeeds)
#
# =============================================================================
param(
    [int]$Project = 1,
    [switch]$NoExecute,
    [switch]$SkipNotebook,
    [switch]$SkipLatex
)

$ErrorActionPreference = "Stop"

# Configuration
$ROOT = $PSScriptRoot | Split-Path
$NOTEBOOK_DIR = Join-Path $ROOT "Project_$Project"
$NOTEBOOK = Join-Path $NOTEBOOK_DIR "project_$Project.ipynb"
$PRESENTATION_DIR = Join-Path $NOTEBOOK_DIR "presentation"
$TEX_FILE = Join-Path $PRESENTATION_DIR "presentation_p$Project.tex"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Building Project $Project Presentation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Validate prerequisites
if (-not (Test-Path $NOTEBOOK)) {
    Write-Host "ERROR: Notebook not found: $NOTEBOOK" -ForegroundColor Red
    exit 1
}

if (-not $SkipLatex -and (-not (Test-Path $TEX_FILE))) {
    Write-Host "ERROR: LaTeX file not found: $TEX_FILE" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 1: Execute Notebook and Extract Figures
# =============================================================================
if (-not $SkipNotebook) {
    Write-Host "Step 1: Extracting figures from notebook..." -ForegroundColor Yellow
    
    $extract_script = Join-Path $PSScriptRoot "extract_notebook_figures.py"
    
    if (-not (Test-Path $extract_script)) {
        Write-Host "ERROR: Extraction script not found: $extract_script" -ForegroundColor Red
        exit 1
    }
    
    # Run extraction script in project directory
    Push-Location $NOTEBOOK_DIR
    
    try {
        $pyArgs = @($extract_script, $Project)
        if ($NoExecute) { $pyArgs += "--no-execute" }
        $output = & python @pyArgs 2>&1
        
        # Display output
        $output | ForEach-Object { 
            Write-Host "  $_" -ForegroundColor Gray
        }
        
        # Check for success
        $success = $output | Where-Object { $_ -match 'SUCCESS:' }
        if (-not $success) {
            Write-Host "ERROR: Notebook execution failed" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    finally {
        Pop-Location
    }
}

# =============================================================================
# Step 2: Compile LaTeX Presentation
# =============================================================================
if (-not $SkipLatex) {
    Write-Host "`nStep 2: Compiling LaTeX presentation..." -ForegroundColor Yellow
    
    Push-Location $PRESENTATION_DIR
    
    try {
        # First pass (build references)
        Write-Host "  Running first pass..." -ForegroundColor Gray
        $pdflatex_out = & pdflatex -interaction=nonstopmode -halt-on-error "presentation_p$Project.tex" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: First LaTeX pass failed" -ForegroundColor Red
            Write-Host ($pdflatex_out | Select-Object -Last 10) -ForegroundColor Red
            Pop-Location
            exit 1
        }
        Write-Host "  [OK] First pass complete"
        
        # Second pass (resolve references)
        Write-Host "  Running second pass..." -ForegroundColor Gray
        $pdflatex_out = & pdflatex -interaction=nonstopmode -halt-on-error "presentation_p$Project.tex" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Second LaTeX pass failed" -ForegroundColor Red
            Write-Host ($pdflatex_out | Select-Object -Last 10) -ForegroundColor Red
            Pop-Location
            exit 1
        }
        Write-Host "  [OK] Second pass complete"
        
        $pdf = "presentation_p$Project.pdf"
        if (Test-Path $pdf) {
            $size = (Get-Item $pdf).Length / 1MB
            Write-Host "  [OK] PDF generated: $pdf ($('{0:N1}' -f $size) MB)"
        }
        else {
            Write-Host "ERROR: PDF file not created" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "[OK] Build Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
