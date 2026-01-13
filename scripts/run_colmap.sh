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

mkdir -p $COLMAP_DIR
mkdir -p $SCENE_DIR

echo "=== Running COLMAP SfM on dataset: $DATASET_NAME ==="

# Feature extraction (COLMAP reads intrinsics + GPS from EXIF automatically)
colmap feature_extractor \
    --database_path $COLMAP_DIR/database.db \
    --image_path $RAW_DIR/images \
    --ImageReader.single_camera 1

# Feature matching
colmap exhaustive_matcher \
    --database_path $COLMAP_DIR/database.db

# Sparse reconstruction (mapping)
mkdir -p $COLMAP_DIR/sparse
colmap mapper \
    --database_path $COLMAP_DIR/database.db \
    --image_path $RAW_DIR/images \
    --output_path $COLMAP_DIR/sparse

echo "=== COLMAP reconstruction done ==="
