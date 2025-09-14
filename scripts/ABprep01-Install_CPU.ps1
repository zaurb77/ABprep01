# RUN: .\scripts\ABprep01-install_cpu.ps1
# Requires: PowerShell at repo root, venv active (.\.venv\Scripts\Activate.ps1)

python -m pip install --upgrade pip

# Clean any leftovers (ignore if not present)
pip uninstall -y torchvision torchaudio torch TTS numpy librosa huggingface-hub transformers || $true

# Torch CPU (no torchvision needed)
pip install --index-url https://download.pytorch.org/whl/cpu torch==2.3.1+cpu torchaudio==2.3.1+cpu

# numpy first (TTS 0.22.0 on Python 3.10 expects this)
pip install numpy==1.22.0

# Coqui TTS + compatible transformers
pip install TTS==0.22.0 "transformers<4.50"

# Utilities (no scipy/numba to avoid numpy bumps)
pip install soundfile soxr pydub unidecode anyascii "huggingface-hub>=0.23.0"

# Sanity
python -c "import sys, torch, torchaudio, TTS, transformers; print('OK', sys.version.split()[0], 'torch', torch.__version__, 'ta', torchaudio.__version__, 'TTS', getattr(TTS,'__version__','?'), 'tfm', transformers.__version__)"
pip check
