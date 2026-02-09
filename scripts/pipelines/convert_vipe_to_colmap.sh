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

if [ -z "$CONDA_BASE" ]; then
  echo "CONDA_BASE is not set in .env"
  exit 1
fi

source $CONDA_BASE
conda activate vipe2

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

VIPE_DIR="$PROJECT_ROOT/data/vipe/${NAME}"

mkdir -p "$VIPE_DIR"

echo "=== Running ViPE SfM on dataset: $NAME ==="

echo "=== ViPE pipeline: $PIPELINE ==="

# =========================
# Convert to COLMAP
# =========================
VIPE_TO_COLMAP="$VIPE_ROOT/scripts/vipe_to_colmap.py"

if [ ! -f "$VIPE_TO_COLMAP" ]; then
  echo "vipe_to_colmap.py not found at $VIPE_TO_COLMAP"
  exit 1
fi

python "$VIPE_TO_COLMAP" "$VIPE_DIR" --sequence "$NAME"

COLMAP_DIR="${VIPE_DIR}_colmap/$NAME"
sed -i 's| images/| |g' $COLMAP_DIR/images.txt

SPARSE_DIR="$COLMAP_DIR/sparse/0"
mkdir -p "$SPARSE_DIR"

mv "$COLMAP_DIR/cameras.txt" $SPARSE_DIR
mv "$COLMAP_DIR/images.txt" $SPARSE_DIR
mv "$COLMAP_DIR/points3D.txt" $SPARSE_DIR

colmap model_converter \
    --input_path $SPARSE_DIR \
    --output_path $SPARSE_DIR \
    --output_type BIN

echo "=== ViPE reconstruction done ==="
