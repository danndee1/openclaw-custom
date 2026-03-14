ARG BASE_IMAGE=1186258278/openclaw-zh:nightly
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    XDG_CACHE_HOME=/root/.cache \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_CACHE_DIR=/root/.cache/pip \
    HF_HOME=/root/.cache/huggingface \
    TRANSFORMERS_CACHE=/root/.cache/huggingface \
    TORCH_HOME=/root/.cache/torch \
    NPM_CONFIG_PREFIX=/root/.local \
    PATH=/root/.local/bin:${PATH} \
    MODELS_DIR=/models

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-pip \
    ffmpeg \
    git \
    curl \
    ca-certificates \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /root/.cache/pip \
    /root/.cache/huggingface \
    /root/.cache/torch \
    /root/.config/notion \
    /root/.local/bin \
    /models

COPY requirements.extra.txt /tmp/requirements.extra.txt
RUN python3 -m pip --version \
  && python3 -m pip install --no-cache-dir --break-system-packages --upgrade pip setuptools wheel \
  && if [ -s /tmp/requirements.extra.txt ]; then \
       sed -n '1,120p' /tmp/requirements.extra.txt; \
       python3 -m pip install --no-cache-dir --break-system-packages --prefer-binary -r /tmp/requirements.extra.txt; \
     fi \
  && rm -f /tmp/requirements.extra.txt

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["openclaw", "gateway", "run", "--allow-unconfigured"]
