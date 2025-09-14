# Ensure venv is active
cd D:\Projects\AudioBooks\ABprep01
.\.venv\Scripts\Activate.ps1

# Pin a compatible transformers version (4.49.0 works well with TTS 0.22.0)
pip uninstall -y transformers
pip install transformers==4.49.0

# sanity
python -c "import transformers; print('transformers', transformers.__version__)"
