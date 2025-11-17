#!/usr/bin/env bash
set -euo pipefail

# Temporary: just move ComfyUI into /workspace if needed and start it.
NETWORK_VOLUME="/workspace"

if [ ! -d "$NETWORK_VOLUME" ]; then
  mkdir -p "$NETWORK_VOLUME"
fi

if [ ! -d "$NETWORK_VOLUME/ComfyUI" ] && [ -d /ComfyUI ]; then
  mv /ComfyUI "$NETWORK_VOLUME/ComfyUI"
fi

cd "$NETWORK_VOLUME/ComfyUI"

# Basic ComfyUI run – you’ll replace this later with your big orchestrator script
python main.py --listen --port 8188

