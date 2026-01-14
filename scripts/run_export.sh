#!/bin/bash
set -e

DATASET_NAME=$1
PROJECT_DIR=$2
OUTPUT_DIR=$3
DOCKER_NAME=$4

if [ -z "$DATASET_NAME" ] || [ -z "$PROJECT_DIR" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$DOCKER_NAME" ]; then
  echo "Usage: run_vipe.sh <dataset_name> <project_dir> <output_dir> <docker_name>"
  exit 1
fi

echo "=== Running export on dataset: $DATASET_NAME ==="

mkdir -p "$OUTPUT_DIR/colmap"
mkdir -p "$OUTPUT_DIR/vipe_colmap"

docker cp "$DOCKER_NAME:$PROJECT_DIR/data/colmap/$DATASET_NAME" \
          "$OUTPUT_DIR/colmap"

docker cp "$DOCKER_NAME:$PROJECT_DIR/data/vipe_colmap/$DATASET_NAME" \
          "$OUTPUT_DIR/vipe_colmap"

echo "=== Export done ==="
