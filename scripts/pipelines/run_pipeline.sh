#!/usr/bin/env bash
set -e

DATASET_NAME=$1
shift || true

if [ -z "$DATASET_NAME" ]; then
  echo "Usage: run_pipeline.sh <dataset_name> [--skip-colmap] [--skip-vipe]"
  exit 1
fi

# =========================
# Parse flags
# =========================
SKIP_COLMAP=false
SKIP_VIPE=false

for arg in "$@"; do
  case $arg in
    --skip-colmap)
      SKIP_COLMAP=true
      ;;
    --skip-vipe)
      SKIP_VIPE=true
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

# =========================
# Paths
# =========================
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts/pipelines"

# Load .env
ENV_FILE="$PROJECT_ROOT/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo ".env file not found at $ENV_FILE"
  exit 1
fi
set -a
source "$ENV_FILE"
set +a

echo "===================================="
echo "FULL pipeline for dataset: $DATASET_NAME"
echo "Skip COLMAP: $SKIP_COLMAP"
echo "Skip ViPE:   $SKIP_VIPE"
echo "===================================="

# =========================
# Helper function to time steps
# =========================
run_step() {
  local step_name=$1
  local cmd=$2
  echo "------------------------------------"
  echo "⏱ Starting step: $step_name"
  local start_time=$(date +%s)

  eval "$cmd"

  local end_time=$(date +%s)
  local duration=$((end_time - start_time))
  echo "Step finished: $step_name (Time: ${duration}s)"
}

# =========================
# 1. Prepare dataset
# =========================
run_step "Prepare dataset" "bash \"$SCRIPTS_DIR/prepare_dataset.sh\" \"$DATASET_NAME\""

# =========================
# 2. COLMAP
# =========================
if [ "$SKIP_COLMAP" = false ]; then
  run_step "COLMAP reconstruction" "bash \"$SCRIPTS_DIR/colmap.sh\" \"$DATASET_NAME\""
else
  echo "Step COLMAP skipped"
fi

# =========================
# 3. ViPE
# =========================
if [ "$SKIP_VIPE" = false ]; then
  run_step "ViPE processing" "bash \"$SCRIPTS_DIR/vipe.sh\" \"$DATASET_NAME\""
else
  echo "Step ViPE skipped"
fi

echo "===================================="
echo "FULL pipeline finished successfully"
echo "Dataset: $DATASET_NAME"
echo "===================================="
