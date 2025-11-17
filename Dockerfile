FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1 \
    CMAKE_BUILD_PARALLEL_LEVEL=8

# ---- OS + Python 3.12 + basic tools ----
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.12 python3.12-venv python3.12-dev \
        python3-pip \
        curl ffmpeg ninja-build git aria2 git-lfs wget vim \
        libgl1 libglib2.0-0 build-essential gcc && \
    ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    python3.12 -m venv /opt/venv && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:$PATH"

# ---- Core Python tooling + torch (cu128 nightly) ----
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --pre torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/nightly/cu128

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install packaging setuptools wheel "huggingface_hub==0.36.0"

# ---- Runtime libs + comfy-cli + jupyter ----
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
        pyyaml gdown triton \
        comfy-cli \
        jupyterlab jupyterlab-lsp \
        jupyter-server jupyter-server-terminals \
        ipykernel jupyterlab_code_formatter

# ---- ComfyUI install (no models yet) ----
RUN --mount=type=cache,target=/root/.cache/pip \
    /usr/bin/yes | comfy --workspace /ComfyUI install


# ============================
# Final runtime image
# ============================
FROM base AS final

ENV PATH="/opt/venv/bin:$PATH"

# Just in case something needs cv2
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install opencv-python

# Make sure /workspace exists (Vast will usually mount over it)
RUN mkdir -p /workspace

# Thin startup wrapper – this is where you’ll hook your big shell later
COPY src/start_script.sh /start_script.sh
RUN chmod +x /start_script.sh

CMD ["/start_script.sh"]
