#!/usr/bin/env python
"""
Extract PNG figures from Jupyter notebook outputs.

Usage: python extract_notebook_figures.py <project_number>

Example: python extract_notebook_figures.py 2
"""

import argparse
import sys
import warnings
import base64
from pathlib import Path
import nbformat
from nbclient import NotebookClient

# Suppress harmless ZMQ/tornado warnings on Windows
warnings.filterwarnings('ignore', category=RuntimeWarning, module='zmq')

def extract_figures(project: int, no_execute: bool = False):
    """Optionally execute notebook and extract PNG figures from outputs."""
    
    # Set up paths
    root = Path(__file__).parent.parent
    notebook_path = root / f"Project_{project}" / f"project_{project}.ipynb"
    pres_dir = root / f"Project_{project}" / "presentation"
    fig_dir = pres_dir / "figs"
    
    # Validate inputs
    if not notebook_path.exists():
        print(f"ERROR: Notebook not found: {notebook_path}")
        return False
    
    # Create figures directory
    fig_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        print(f"Loading notebook: {notebook_path.name}")
        with notebook_path.open('r', encoding='utf-8') as f:
            nb = nbformat.read(f, as_version=4)
        
        if no_execute:
            print("Skipping notebook execution (--no-execute). Using stored outputs.")
        else:
            print("Executing notebook...")
            client = NotebookClient(
                nb,
                timeout=300,
                kernel_name='python3',
                resources={'metadata': {'path': str(notebook_path.parent)}}
            )
            client.execute()
        
        # Extract PNG images
        print(f"Extracting figures...")
        img_index = 1
        for cell in nb.cells:
            if cell.get('cell_type') != 'code':
                continue
            for output in cell.get('outputs', []):
                data = output.get('data', {}) if isinstance(output, dict) else {}
                if 'image/png' in data:
                    b64 = data['image/png']
                    if isinstance(b64, list):
                        b64 = ''.join(b64)
                    
                    img_bytes = base64.b64decode(b64)
                    filename = fig_dir / f'plot_{img_index:02d}.png'
                    
                    # Check if file exists before writing (to log replacement)
                    file_exists = filename.exists()
                    filename.write_bytes(img_bytes)  # Overwrites if exists
                    
                    action = "Replaced" if file_exists else "Created"
                    print(f"  [OK] {action} {filename.name}")
                    img_index += 1
        
        total = img_index - 1
        print(f"SUCCESS: Extracted {total} plots to {fig_dir}")
        return True
        
    except Exception as e:
        print(f"ERROR: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Extract PNG figures from Jupyter notebook outputs."
    )
    parser.add_argument("project_number", type=int, help="Project number, e.g. 3")
    parser.add_argument(
        "--no-execute",
        action="store_true",
        help="Do not execute notebook; only extract from saved outputs."
    )
    args = parser.parse_args()

    success = extract_figures(args.project_number, no_execute=args.no_execute)
    sys.exit(0 if success else 1)
