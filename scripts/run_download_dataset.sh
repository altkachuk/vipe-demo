#!/usr/bin/env bash
set -e

DATASET_NAME=$1
ZIP_PATH=$2

if [ -z "$DATASET_NAME" ] || [ -z "$ZIP_PATH" ]; then
  echo "Usage: run_download_dataset.sh <dataset_name> <path_to_zip>"
  exit 1
fi

PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUTPUT_DIR="$PROJECT_ROOT/data/raw/$DATASET_NAME"

echo "Preparing dataset '$DATASET_NAME'"
echo "From ZIP: $ZIP_PATH"
echo "Into: $OUTPUT_DIR"

python -m src.data.downloaders.local_zip_downloader \
  --zip "$ZIP_PATH" \
  --output "$OUTPUT_DIR"
