# ViPE Demo Project

## Overview

This project demonstrates **ViPE** (Video Pose Engine) with your own datasets. It includes:

- Dataset preparation and conversion
- ViPE reconstruction
- COLMAP reconstruction
- Optional Docker support with NVIDIA GPU

# Installation

---

We **recommend using a Docker container** to avoid conflicts with your local environment.

Instructions for setting up and running the Docker container are provided in the section: **Running ViPE in Docker (with NVIDIA GPU support)**.

## 1. System Setup (Ubuntu)

Run the included script to install system dependencies and Miniconda:

```bash
bash scripts/setup/setup_system.sh
```

Activate conda:
```bash
source ~/miniconda3/bin/activate
```

Set up environment:

```bash
bash setup.sh
```

Activate vipe environment:

```bash
conda activate vipe
```

---

## 2. ViPE Setup

Clone the ViPE repository:

```bash
git clone https://github.com/nv-tlabs/vipe.git
cd vipe
```

### Optional: Prevent build freezes

```bash
export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2
export CUDA_NVCC_FLAGS="--threads 2"
```

### Specify GPU architecture (to avoid compiling for all GPUs)

```bash
# RTX 20xx → 7.5, RTX 30xx → 8.6, RTX 40xx → 8.9
export TORCH_CUDA_ARCH_LIST="8.6"
```

### Install ViPE

```bash
pip install -v --no-build-isolation -e .
```

## 3. COLMAP Installation (optional, if needed)

```bash
conda install -c conda-forge colmap cuda-version=12
```

Reboot computer

Check installation (CUDA is supported):

```bash
colmap --help | grep -i cuda
```

If using Docker with GUI, follow:

**On HOST machine (Ubuntu):**

```bash
# 1. Allow local Docker connections
xhost +local:docker

# 2. Check Xauthority file
ls -la ~/.Xauthority

# 3. If you don't have .Xauthority, generate it
touch ~/.Xauthority
xauth generate :0 . trusted

# 4. List xauth entries
xauth list
```

# Usage

---

## 1. Create and set up `.env`

In the root of the project, create a `.env` file. Set the path to your ViPE installation:

```bash
VIPE_ROOT=/root/vipe

```

---

## 2. Download dataset

```bash
bash scripts/pipelines/download_dataset.sh <dataset_name> <path_to_zip_file>

```

- **dataset_name** – name of the dataset config file (without `.yaml`)
- **path_to_zip_file** – path to the ZIP archive containing the dataset

Example dataset config file (`configs/datasets/zavod70.yaml`):

```yaml
name:zavod70

dataset:
vipe_scale:0.25

vipe:
pipeline:no_vda

```

- **name** – used to name dataset directories; must be unique
- **vipe_scale** – scale factor to reduce image resolution before generating video; useful to prevent GPU RAM overusage
- **pipeline** – ViPE pipeline to use (see ViPE documentation)

---

## 3. Dataset preparation

```bash
bash scripts/pipelines/prepare_dataset.sh <dataset_name>

```

This script prepares the dataset in **COLMAP format** and generates the video source for the ViPE pipeline.

---

## 4. ViPE reconstruction

```bash
bash scripts/pipelines/vipe.sh <dataset_name>

```

Runs the ViPE reconstruction pipeline and converts the results to COLMAP format automatically.

---

## 5. COLMAP reconstruction (optional)

```bash
bash scripts/pipelines/colmap.sh <dataset_name>

```

Runs COLMAP reconstruction on the dataset. Use this if you want an alternative or additional sparse reconstruction.

---

## 6. Run the full pipeline

You can automatically run dataset preparation + ViPE reconstruction (steps 3–4) with:

```bash
bash scripts/pipelines/run_pipeline.sh <dataset_name>

```

To skip specific steps:

```bash
bash scripts/pipelines/run_pipeline.sh <dataset_name> --skip-colmap --skip-vipe

```

- `-skip-colmap` – skip COLMAP reconstruction
- `-skip-vipe` – skip ViPE reconstruction

---

## 7. Export reconstruction results (optional)

Use this script to export reconstruction results to the host machine for future use:

```bash
bash export.sh <dataset_name> <project_dir> <docker_name>

```

- **dataset_name** – dataset name from config file
- **project_dir** – absolute path to the ViPE demo project inside Docker container
- **docker_name** – name of the Docker container

# Running ViPE in Docker (with NVIDIA GPU support)

---

## 1. Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctlenable docker

```

---

## 2. Install NVIDIA Docker Runtime

```bash
# Add NVIDIA Docker GPG key
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey |sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/nvidia-docker.gpg

# Add repository for Ubuntu 22.04
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu22.04/nvidia-docker.list |sudotee /etc/apt/sources.list.d/nvidia-docker.list

# Update package lists
sudo apt update

# Install NVIDIA Docker runtime
sudo apt install -y nvidia-docker2

# Restart Docker to apply changes
sudo systemctl restart docker

```

---

## 3. Configure X11 Forwarding (for GUI visualization)

```bash
# Check current xauth entries
xauth list
# Should show entries like: your_hostname/unix:0  MIT-MAGIC-COOKIE-1  abc123...

# If empty, generate a new entry
xauth generate :0 .
# Or manually add:
xauth add :0 . $(xauth -f /tmp/.Xauthority generate :0 . trusted | awk'{print $3}')

# Verify entries
xauth list

```

---

## 4. Add your user to the Docker group

```bash
sudo usermod -aG docker$USER

```

> ⚠️ You must reboot or log out/in for group changes to take effect.
> 

---

## 5. Run Docker Container with GPU

```bash
sudo docker run -it --gpus all \
    --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v$HOME/.Xauthority:/root/.Xauthority:rw \
    --name ubuntu22-vipe \
    nvidia/cuda:12.8.0-devel-ubuntu22.04 bash

```

- `-gpus all` — enables all NVIDIA GPUs inside the container.
- `-network host` — allows access to host network.
- `v /tmp/.X11-unix` and `v $HOME/.Xauthority` — allows GUI apps to display on your host.

---

## 6. Connect to an Existing Container

```bash
# List containers
docker ps -a

# Start stopped container
docker start ubuntu22-vipe

# Connect to running container
docker exec -it ubuntu22-vipe bash

```

---

## 7. Stop and Remove Containers

```bash
# Stop container
docker stop ubuntu22-vipe

# Remove container
docker rm ubuntu22-vipe

```