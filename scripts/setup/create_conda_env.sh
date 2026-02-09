#!/usr/bin/env bash
set -e

ENV_NAME=$1

echo "Creating conda environment: $ENV_NAME"

if conda env list | grep -q "^$ENV_NAME "; then
    echo "Environment '$ENV_NAME' already exists."
    echo "Remove it with: conda remove -n $ENV_NAME --all"
    exit 1
fi

conda env create -f ${ENV_NAME}.environment.yml

echo
echo "Environment created successfully!"
echo "Activate with:"
echo "  conda activate $ENV_NAME"
