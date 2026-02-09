# ViPE Demo Project

# ViPE → COLMAP → Gaussian Splatting Pipeline

This project provides an **end-to-end pipeline** for generating **3D Gaussian Splatting (GS) scenes** from raw image datasets using:

- **ViPE** for camera pose estimation and preprocessing
- **COLMAP format** as an intermediate representation
- **gsplat** for training and rendering Gaussian Splatting models

The pipeline is fully automated and designed to run **inside a Docker container with GPU support**.

---

## Features

- End-to-end automation: dataset → ViPE → COLMAP → Gaussian Splatting
- GPU-accelerated (CUDA + PyTorch)
- Docker-based reproducible environment
- Config-driven dataset handling
- Interactive or scripted execution
- Suitable for large-scale real-world captures

---

## Docker container

Create and run the Docker container:

```bash
sudo docker run -it --gpus all \
    --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $HOME/.Xauthority:/root/.Xauthority:rw \
    --name ubuntu22-vipe \
    nvidia/cuda:12.8.0-devel-ubuntu22.04 bash
```

---

## System setup

Inside the container, install system dependencies:

```bash
apt update
apt install -y \
	git \
  cmake \
  ninja-build \
  build-essential \
  cuda-nvcc-12-8 \
  libgl1 \
  libglib2.0-0 \
  wget \
  ffmpeg
```

---

## Install conda

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source ./miniconda3/bin/activate
```

---

## Environments creating

**Run full setup (recommended)**

```bash
bash setup.sh
```

**Or create environments separately**

ViPE environment

```bash
bash scripts/setup/create_vipe_env.sh
```

gsplat environment

```bash
bash scripts/setup/create_gsplat_env.sh
```

---

## Usage

### **1. Create and set up `.env`**

In the **root of the project**, create a `.env` file:

```bash
VIPE_ROOT=/root/vipe
CONDA_BASE=/root/miniconda3/etc/profile.d/conda.sh
```

**Variables:**

- `VIPE_ROOT` — path to the ViPE project
- `CONDA_BASE` — path to the Conda initialization script

---

### 2. Create dataset config

Inside `configs/datasets/`, create a YAML config file for your dataset:

```bash
name: zavod70

dataset:
  vipe_scale: 0.25

vipe:
  pipeline: no_vda
```

**Parameters:**

- `vipe_scale` — image downscale factor to reduce memory usage during ViPE processing
- `pipeline` — ViPE pipeline type

---

### 3. Download dataset

- Download the dataset ZIP (e.g. from Google Drive)
- Copy or move it **inside the Docker container**

---

### 4. Run the full pipeline

Run the complete pipeline with:

```bash
bash scripts/pipelines/run_pipeline.sh \
  <dataset_name> \
  <path_to_raw_datasets> \
  <max_training_steps>
```

**Arguments:**

- `<dataset_name>`
    
    Must match the dataset config filename
    
- `<path_to_raw_datasets>`
    
    Path to the dataset ZIP file inside the Docker container
    
- `<max_training_steps>`
    
    Number of training iterations for Gaussian Splatting
    
    *(integer in range 1–30000)*
    

---

## Output

After successful execution, the pipeline produces:

- COLMAP-formatted sparse reconstruction
- Trained Gaussian Splatting model
- Renderable 3D scene via `gsplat`
- Logs and artifacts stored per dataset

---

## Notes

- Ensure sufficient shared memory (`/dev/shm`) when running in Docker
- Large datasets may require lowering `vipe_scale`
- CUDA 12.8 and NVIDIA drivers must be compatible with the host system