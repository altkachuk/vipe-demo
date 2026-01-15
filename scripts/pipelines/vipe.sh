#!/bin/bash
set -e

DATASET_NAME=$1
if [ -z "$DATASET_NAME" ]; then
  echo "Usage: vipe.sh <dataset_name>"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# =========================
# Load .env
# =========================
ENV_FILE="$PROJECT_ROOT/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo ".env file not found at $ENV_FILE"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "$VIPE_ROOT" ]; then
  echo "VIPE_ROOT is not set in .env"
  exit 1
fi

if [ ! -d "$VIPE_ROOT" ]; then
  echo "VIPE_ROOT directory does not exist: $VIPE_ROOT"
  exit 1
fi

# =========================
# Check vipe CLI
# =========================
command -v vipe >/dev/null 2>&1 || {
  echo "vipe CLI not found in PATH"
  exit 1
}

# =========================
# Load dataset config
# =========================
CONFIG_FILE="$PROJECT_ROOT/configs/datasets/${DATASET_NAME}.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "Using config: $CONFIG_FILE"

read -r NAME PIPELINE <<EOF
$(python - <<PY
import yaml

with open("$CONFIG_FILE") as f:
    cfg = yaml.safe_load(f)

name = cfg.get("name")
pipeline = cfg.get("vipe", {}).get("pipeline", "default")

print(name, pipeline)
PY
)
EOF

VIDEO_PATH="$PROJECT_ROOT/data/datasets/${NAME}/video/${NAME}.mp4"
VIPE_DIR="$PROJECT_ROOT/data/vipe/${NAME}"

if [ ! -f "$VIDEO_PATH" ]; then
  echo "Video not found: $VIDEO_PATH"
  exit 1
fi

mkdir -p "$VIPE_DIR"

echo "=== Running ViPE SfM on dataset: $NAME ==="

echo "=== ViPE pipeline: $PIPELINE ==="

# =========================
# Run ViPE
# =========================
vipe infer "$VIDEO_PATH" --pipeline="$PIPELINE" --output="$VIPE_DIR"

# =========================
# Convert to COLMAP
# =========================
VIPE_TO_COLMAP="$VIPE_ROOT/scripts/vipe_to_colmap.py"

if [ ! -f "$VIPE_TO_COLMAP" ]; then
  echo "vipe_to_colmap.py not found at $VIPE_TO_COLMAP"
  exit 1
fi

python "$VIPE_TO_COLMAP" "$VIPE_DIR" --sequence "$NAME" 

echo "=== ViPE reconstruction done ==="
