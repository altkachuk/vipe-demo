#!/usr/bin/env bash
set -e

DATASET_NAME=$1

if [ -z "$DATASET_NAME" ]; then
  echo "Usage: run_prepare_dataset.sh <dataset_name>"
  exit 1
fi

PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
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
scale = cfg.get("vipe_scale", 1.0)

print(name, scale)
PY
)
EOF

RAW_DIR="$PROJECT_ROOT/data/raw/$NAME"
DATASET_DIR="$PROJECT_ROOT/data/datasets/$NAME"

echo "Preparing dataset: $NAME"
echo "Raw images dir: $RAW_DIR"
echo "Output dir: $DATASET_DIR"
echo "VIPE scale: $VIPE_SCALE"

python -m src.data.prepare_dataset \
  --raw_input "$RAW_DIR" \
  --dataset_output "$DATASET_DIR" \
  --video_name "$NAME" \
  --vipe_scale "$VIPE_SCALE"
