#!/bin/bash
set -e

DATASET_NAME=$1
PROJECT_DIR=$2
OUTPUT_DIR=$3
DOCKER_NAME=$4
if [ -z "$DATASET_NAME" ]; then
  echo "Usage: run_vipe.sh <dataset_name>"
  exit 1
fi


mkdir -p $VIPE_DIR

echo "=== Running export on dataset: $DATASET_NAME ==="

docker cp $DOCKER_NAME:$PROJECT_DIR/colmap/$DATASET_NAME $OUTPUT_DIR/colmap
docker cp $DOCKER_NAME:$PROJECT_DIR/vipe_colmap/$DATASET_NAME $OUTPUT_DIR/vipe_colmap

echo "=== Export done ==="
