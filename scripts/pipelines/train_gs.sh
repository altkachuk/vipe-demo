#!/bin/bash
set -e


DATASET_NAME=$1
if [ -z "$DATASET_NAME" ]; then
  echo "Usage: vipe.sh <dataset_name>"
  exit 1
fi

MAX_STEPS=$2
if [ -z "$MAX_STEPS" ]; then
  echo "Usage: vipe.sh <max_steps>"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

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
conda activate gsplat2

# =========================
# Load dataset config
# =========================
CONFIG_FILE="$PROJECT_ROOT/configs/datasets/${DATASET_NAME}.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "Using config: $CONFIG_FILE"

read -r NAME PIPELINE <<EOF
$(python - <<PY
import yaml

with open("$CONFIG_FILE") as f:
    cfg = yaml.safe_load(f)

name = cfg.get("name")
pipeline = cfg.get("vipe", {}).get("pipeline", "default")

print(name, pipeline)
PY
)
EOF

COLMAP_DIR="$PROJECT_ROOT/data/vipe/${NAME}_colmap/$NAME"
if [ ! -d "$COLMAP_DIR" ]; then
  echo "COLMAP_DIR directory does not exist: $COLMAP_DIR"
  exit 1
fi


GSPLAT_DIR="$PROJECT_ROOT/data/gsplat/${NAME}"
mkdir -p "$GSPLAT_DIR"

echo "=== Running GS training on dataset: $NAME ==="
CUDA_VISIBLE_DEVICES=0 python src/gsplat/simple_trainer.py default \
  --data_dir $COLMAP_DIR \
  --data_factor 1 \
  --result_dir $GSPLAT_DIR \
  --input_format vipe \
  --max_steps $MAX_STEPS


echo "=== GS training done ==="
