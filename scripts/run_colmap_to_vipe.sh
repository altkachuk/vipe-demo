#!/bin/bash
set -e

DATASET_NAME=$1
if [ -z "$DATASET_NAME" ]; then
  echo "Usage: $0 <dataset_name>"
  exit 1
fi

RAW_DIR="data/datasets/${DATASET_NAME}"
COLMAP_DIR="data/colmap/${DATASET_NAME}"
SCENE_DIR="data/scene/${DATASET_NAME}"

# Convert to VIPE format
python src.colmap.colmap_to_vipe.py \
    --input $COLMAP_DIR/sparse/0 \
    --output $SCENE_DIR \
    --images $RAW_DIR/images

echo "=== Dataset ready for VIPE at: $SCENE_DIR ==="