#!/usr/bin/env bash
set -e

DATASET_NAME=$1

if [ -z "$DATASET_NAME" ]; then
  echo "Usage: run_prepare_dataset.sh <dataset_name>"
  exit 1
fi

PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
RAW_DIR="$PROJECT_ROOT/data/raw/$DATASET_NAME"
DATASET_DIR="$PROJECT_ROOT/data/datasets/$DATASET_NAME/images"

echo "Preparing existing dataset '$DATASET_NAME'"
echo "Raw images dir: $RAW_DIR"
echo "Final dataset dir: $DATASET_DIR"

python -m src.data.prepare_dataset \
  --raw_input "$RAW_DIR" \
  --dataset_output "$DATASET_DIR"
