#!/usr/bin/env bash
set -e

DATASET_NAME=$1
ZIP_PATH=$2

if [ -z "$DATASET_NAME" ] || [ -z "$ZIP_PATH" ]; then
  echo "Usage: run_download_dataset.sh <dataset_name> <path_to_zip>"
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
read -r NAME <<EOF
$(python - <<PY
import yaml

with open("$CONFIG_FILE") as f:
    cfg = yaml.safe_load(f)

name = cfg.get("name")

print(name)
PY
)
EOF

OUTPUT_DIR="$PROJECT_ROOT/data/raw/$NAME"

echo "Preparing dataset '$NAME'"
echo "From ZIP: $ZIP_PATH"
echo "Into: $OUTPUT_DIR"

python -m src.data.downloaders.local_zip_downloader \
  --zip "$ZIP_PATH" \
  --output "$OUTPUT_DIR"
