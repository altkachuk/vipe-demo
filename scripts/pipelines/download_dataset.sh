#!/usr/bin/env bash
set -e

DATASET_NAME=$1
ZIP_PATH=$2

if [ -z "$DATASET_NAME" ] || [ -z "$ZIP_PATH" ]; then
  echo "Usage: download_dataset.sh <dataset_name> <path_to_zip>"
  exit 1
fi

if [ ! -f "$ZIP_PATH" ]; then
  echo "ZIP file not found: $ZIP_PATH"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "Project dir: $PROJECT_ROOT"

CONFIG_FILE="$PROJECT_ROOT/configs/datasets/${DATASET_NAME}.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "Using config: $CONFIG_FILE"

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

OUTPUT_DIR="$PROJECT_ROOT/data/raw/$NAME"

mkdir -p "$OUTPUT_DIR"

echo "Downloading dataset '$NAME'"
echo "From ZIP: $ZIP_PATH"
echo "Into: $OUTPUT_DIR"

python -m src.data.downloaders.local_zip_downloader \
  --zip "$ZIP_PATH" \
  --output "$OUTPUT_DIR"
