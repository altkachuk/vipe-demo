#!/usr/bin/env bash
set -e

DATASET_NAME=$1
PATH_TO_RAW_DATASET=$2
MAX_TRAINING_STEPS=$3

shift || true

if [ -z "$DATASET_NAME" ]; then
  echo "Usage: run_pipeline.sh <dataset_name>"
  exit 1
fi

# =========================
# Ask interactively if not provided
# =========================
if [ -z "$PATH_TO_RAW_DATASET" ]; then
  echo "Please input path to raw datasets:"
  read -r PATH_TO_RAW_DATASET
fi

# Normalize path
PATH_TO_RAW_DATASET="$(realpath "$PATH_TO_RAW_DATASET")"


if [ ! -f "$PATH_TO_RAW_DATASET" ]; then
  echo "❌ Path does not exist: $PATH_TO_RAW_DATASET"
  exit 1
fi

export PATH_TO_RAW_DATASET

# =========================
# Ask interactively if not provided
# =========================
if [ -z "$MAX_TRAINING_STEPS" ]; then
  while true; do
    echo "Please input max GS training steps (1–30000):"
    read -r MAX_TRAINING_STEPS

    # Check integer
    if ! [[ "$MAX_TRAINING_STEPS" =~ ^[0-9]+$ ]]; then
      echo "❌ Error: must be an integer."
      continue
    fi

    # Check range
    if [ "$MAX_TRAINING_STEPS" -lt 1 ] || [ "$MAX_TRAINING_STEPS" -gt 30000 ]; then
      echo "❌ Error: value must be between 1 and 30000."
      continue
    fi

    break
  done
fi

export MAX_TRAINING_STEPS

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
# 1. Download dataset
# =========================

run_step "Downaload dataset" "bash \"$SCRIPTS_DIR/download_dataset.sh\" \"$DATASET_NAME\" \"$PATH_TO_RAW_DATASET"\"

# =========================
# 2. Prepare dataset
# =========================
run_step "Prepare dataset" "bash \"$SCRIPTS_DIR/prepare_dataset.sh\" \"$DATASET_NAME\""

# =========================
# 3. ViPE
# =========================
run_step "ViPE processing" "bash \"$SCRIPTS_DIR/vipe.sh\" \"$DATASET_NAME\""

# =========================
# 4. ViPE to Colmap
# =========================
run_step "ViPE to Colmap converting" "bash \"$SCRIPTS_DIR/convert_vipe_to_colmap.sh\" \"$DATASET_NAME\""

# =========================
# 4. ViPE to Colmap
# =========================
run_step "GS training" "bash \"$SCRIPTS_DIR/train_gs.sh\" \"$DATASET_NAME\" \"$MAX_TRAINING_STEPS"\"

echo "===================================="
echo "FULL pipeline finished successfully"
echo "Dataset: $DATASET_NAME"
echo "===================================="
