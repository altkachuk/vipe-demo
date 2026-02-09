#!/usr/bin/env bash
set -e

DATASET_NAME=$1

if [ -z "$DATASET_NAME" ]; then
  echo "Usage: run_prepare_dataset.sh <dataset_name>"
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
conda activate vipe

CONFIG_FILE="$PROJECT_ROOT/configs/datasets/${DATASET_NAME}.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "Using config: $CONFIG_FILE"

# Read values from YAML using Python
read -r NAME VIPE_SCALE <<EOF
$(python - <<PY
import yaml

with open("$CONFIG_FILE") as f:
    cfg = yaml.safe_load(f)

name = cfg.get("name")
scale = cfg.get("dataset", {}).get("vipe_scale", 1.0)

print(name, scale)
PY
)
EOF

RAW_DIR="$PROJECT_ROOT/data/raw/$NAME"
DATASET_DIR="$PROJECT_ROOT/data/datasets/$NAME"

if [ ! -d "$RAW_DIR" ]; then
  echo "Raw dataset not found: $RAW_DIR"
  exit 1
fi

mkdir -p "$DATASET_DIR"

echo "Preparing dataset: $NAME"
echo "Raw images dir: $RAW_DIR"
echo "Output dir: $DATASET_DIR"
echo "VIPE scale: $VIPE_SCALE"

python -m src.data.prepare_dataset \
  --raw_input "$RAW_DIR" \
  --dataset_output "$DATASET_DIR" \
  --video_name "$NAME" \
  --vipe_scale "$VIPE_SCALE"
