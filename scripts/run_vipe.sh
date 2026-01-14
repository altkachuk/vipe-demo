#!/bin/bash
set -e

DATASET_NAME=$1
if [ -z "$DATASET_NAME" ]; then
  echo "Usage: run_colmap.sh <dataset_name>"
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

VIDEO_PATH="data/datasets/${NAME}/video/${NAME}.mp4"
VIPE_DIR="data/vipe"

mkdir -p $VIPE_DIR

echo "=== Running ViPE SfM on dataset: $NAME ==="

# Feature extraction (COLMAP reads intrinsics + GPS from EXIF automatically)
vipe infer $VIDEO_PATH --pipeline=no_vda --output=$VIPE_DIR

python /root/vipe/scripts/vipe_to_colmap.py "$VIPE_DIR" --sequence "$NAME" 

echo "=== ViPE reconstruction done ==="
