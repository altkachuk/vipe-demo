#!/usr/bin/env bash
set -e

ENV_NAME=vipe

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

cd ~
git clone https://github.com/nv-tlabs/vipe.git
cd vipe

export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2
export CUDA_NVCC_FLAGS="--threads 2"

export TORCH_CUDA_ARCH_LIST="8.6"

pip install -v --no-build-isolation -e .

echo "$ENV_NAME environnment created."