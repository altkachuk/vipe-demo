#!/usr/bin/env bash
set -e

# =========================
# Paths
# =========================
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts/setup"

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
# 1. Create ViPE conda environment
# =========================

run_step "Creating vipe env" "bash \"$SCRIPTS_DIR/create_vipe_env.sh\""


# =========================
# 2. Create gsplat conda environment
# =========================

run_step "Creating gsplat env" "bash \"$SCRIPTS_DIR/create_gsplat_env.sh\""

echo "===================================="
echo "Environments creating finished successfully"
echo "===================================="