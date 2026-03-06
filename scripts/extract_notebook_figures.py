#!/usr/bin/env python
"""
Extract PNG figures from Jupyter notebook outputs.

Usage: python extract_notebook_figures.py <project_number>

Example: python extract_notebook_figures.py 2
"""

import sys
import warnings
import base64
from pathlib import Path
import nbformat
from nbclient import NotebookClient

# Suppress harmless ZMQ/tornado warnings on Windows
warnings.filterwarnings('ignore', category=RuntimeWarning, module='zmq')

def extract_figures(project: int):
    """Execute notebook and extract PNG figures."""
    
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
        
        print(f"Executing notebook...")
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
    if len(sys.argv) < 2:
        print("Usage: python extract_notebook_figures.py <project_number>")
        print("Example: python extract_notebook_figures.py 2")
        sys.exit(1)
    
    try:
        project = int(sys.argv[1])
    except ValueError:
        print(f"ERROR: Invalid project number: {sys.argv[1]}")
        sys.exit(1)
    
    success = extract_figures(project)
    sys.exit(0 if success else 1)
