#!/bin/bash
set -e

DATASET_NAME=$1
if [ -z "$DATASET_NAME" ]; then
  echo "Usage: colmap.sh <dataset_name>"
  exit 1
fi

command -v colmap >/dev/null 2>&1 || {
  echo "COLMAP is not installed or not in PATH"
  exit 1
}

PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
CONFIG_FILE="$PROJECT_ROOT/configs/datasets/${DATASET_NAME}.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "Using config: $CONFIG_FILE"

# Read values from YAML using Python
NAME=$(python - <<PY
import yaml
with open("$CONFIG_FILE") as f:
    cfg = yaml.safe_load(f)
name = cfg.get("name")
if name is None:
    raise ValueError("Config must contain 'name'")
print(name)
PY
)

IMAGES_DIR="$PROJECT_ROOT/data/datasets/${NAME}"
COLMAP_DIR="$PROJECT_ROOT/data/colmap/${NAME}"

if [ ! -d "$IMAGES_DIR/images" ]; then
  echo "Images directory not found: $IMAGES_DIR/images"
  exit 1
fi

mkdir -p "$COLMAP_DIR"

echo "=== Running COLMAP SfM on dataset: $NAME ==="

# Feature extraction (COLMAP reads intrinsics + GPS from EXIF automatically)
colmap feature_extractor \
    --database_path $COLMAP_DIR/database.db \
    --image_path $IMAGES_DIR/images \
    --ImageReader.single_camera 1

# Feature matching
colmap exhaustive_matcher \
    --database_path $COLMAP_DIR/database.db

# Sparse reconstruction (mapping)
mkdir -p $COLMAP_DIR/sparse
colmap mapper \
    --database_path $COLMAP_DIR/database.db \
    --image_path $IMAGES_DIR/images \
    --output_path $COLMAP_DIR/sparse

echo "=== COLMAP reconstruction done ==="
