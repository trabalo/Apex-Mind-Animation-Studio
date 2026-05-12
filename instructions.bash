#!/bin/bash
# ============================================================
# Provisioning script for ComfyUI Serverless on Vast.ai
# Installs LTXVideo custom nodes and downloads the LTX-2.3
# FP8 checkpoint, Gemma text encoder, and VAE for image-to-video.
# ============================================================

set -eo pipefail

# -----------------------------------------------------------
# 1.  Create the required model directories inside /workspace
#     ( /workspace persists across worker restarts )
# -----------------------------------------------------------
WORKSPACE="${WORKSPACE:-/workspace}"
mkdir -p "${WORKSPACE}/ComfyUI/models/checkpoints"
mkdir -p "${WORKSPACE}/ComfyUI/models/clip"
mkdir -p "${WORKSPACE}/ComfyUI/models/vae"
mkdir -p "${WORKSPACE}/ComfyUI/models/loras"
mkdir -p "${WORKSPACE}/ComfyUI/custom_nodes"

echo "==> Directories created under ${WORKSPACE}/ComfyUI/models/"

# -----------------------------------------------------------
# 2.  Download the ComfyUI‑LTXVideo custom nodes
# -----------------------------------------------------------
echo "==> Cloning ComfyUI-LTXVideo custom nodes..."
cd "${WORKSPACE}/ComfyUI/custom_nodes"
git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git
cd ComfyUI-LTXVideo

# Activate the ComfyUI Python environment and install deps
source "${WORKSPACE}/venv/main/bin/activate"  2>/dev/null || true
pip install --no-cache-dir -r requirements.txt

echo "==> ComfyUI-LTXVideo custom nodes installed."

# -----------------------------------------------------------
# 3.  Download the LTX‑2.3 FP8 checkpoint (~23 GB)
# -----------------------------------------------------------
echo "==> Downloading LTX-2.3 FP8 checkpoint..."
wget -q --show-progress \
  -O "${WORKSPACE}/ComfyUI/models/checkpoints/ltx-2.3-22b-dev-fp8.safetensors" \
  "https://huggingface.co/Lightricks/LTX-2.3-fp8/resolve/main/ltx-2.3-22b-dev-fp8.safetensors"

# -----------------------------------------------------------
# 4.  Download the Gemma-2B text encoder
# -----------------------------------------------------------
echo "==> Downloading Gemma-2B text encoder..."
wget -q --show-progress \
  -O "${WORKSPACE}/ComfyUI/models/clip/gemma-2-2b-it-bf16.safetensors" \
  "https://huggingface.co/Comfy-Org/LTXVideo_Repackaged/resolve/main/split_files/text_encoders/gemma-2-2b-it-bf16.safetensors"

# -----------------------------------------------------------
# 5.  Download the LTX‑2.3 VAE
# -----------------------------------------------------------
echo "==> Downloading LTX-2.3 VAE..."
wget -q --show-progress \
  -O "${WORKSPACE}/ComfyUI/models/vae/ltx-2.3-vae.safetensors" \
  "https://huggingface.co/Comfy-Org/LTXVideo_Repackaged/resolve/main/split_files/vae/ltx-2.3-vae.safetensors"

# -----------------------------------------------------------
# 6.  (Optional) Download IC‑LoRA for character consistency
# -----------------------------------------------------------
echo "==> Downloading IC-LoRA..."
wget -q --show-progress \
  -O "${WORKSPACE}/ComfyUI/models/loras/ltx-2.3-22b-ic-lora-hdr-0.9.safetensors" \
  "https://huggingface.co/Lightricks/LTX-2.3/resolve/main/ltx-2.3-22b-ic-lora-hdr-0.9.safetensors"

# -----------------------------------------------------------
# 7.  Clean up any temporary files
# -----------------------------------------------------------
echo "==> Cleaning up..."
rm -rf /tmp/*

echo "============================================================"
echo "Provisioning complete! ComfyUI is ready for LTX‑2.3 I2V."
echo "============================================================"
