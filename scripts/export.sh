#!/bin/bash
set -e

DATASET_NAME=$1
PROJECT_DIR=$2
DOCKER_NAME=$3

if [ -z "$DATASET_NAME" ] || [ -z "$PROJECT_DIR" ] || [ -z "$DOCKER_NAME" ]; then
  echo "Usage: run_export.sh <dataset_name> <project_dir> <docker_name>"
  exit 1
fi

# Use the directory where this script is located
SCRIPT_DIR=$(dirname "$0")
OUTPUT_DIR=$(realpath "$SCRIPT_DIR")

echo "=== Running export on dataset: $DATASET_NAME ==="
echo "Output directory: $OUTPUT_DIR"

mkdir -p "$OUTPUT_DIR/colmap"
mkdir -p "$OUTPUT_DIR/vipe_colmap"

docker cp "$DOCKER_NAME:$PROJECT_DIR/data/colmap/$DATASET_NAME" \
          "$OUTPUT_DIR/colmap"
docker cp "$DOCKER_NAME:$PROJECT_DIR/data/datasets/$DATASET_NAME/images" \
          "$OUTPUT_DIR/colmap/$DATASET_NAME/images"

docker cp "$DOCKER_NAME:$PROJECT_DIR/data/vipe/"$DATASET_NAME"_colmap"/$DATASET_NAME \
          "$OUTPUT_DIR/vipe_colmap"

echo "=== Export done ==="
