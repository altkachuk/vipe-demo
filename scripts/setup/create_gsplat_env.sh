#!/usr/bin/env bash
set -e

ENV_NAME=gsplat

export CUDA_HOME=/usr/local/cuda

bash scripts/setup/create_conda_env.sh $ENV_NAME

# =========================
# Load .env
# =========================
ENV_FILE="$PROJECT_ROOT/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo ".env file not found at $ENV_FILE"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "$CONDA_BASE" ]; then
  echo "CONDA_BASE is not set in .env"
  exit 1
fi

source $CONDA_BASE
conda activate $ENV_NAME

pip install --no-build-isolation git+https://github.com/nerfstudio-project/gsplat.git

pip install --no-build-isolation -r src/gsplat/requirements.txt

echo "$ENV_NAME environnment created."