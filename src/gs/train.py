import os
import argparse
import json
import torch
from vipe import VIPE, GaussianSplattingDataset, Trainer  # adjust imports to actual VIPE API
from torchvision.utils import save_image

def load_scene(data_path):
    # Load cameras
    with open(os.path.join(data_path, "cameras.json")) as f:
        cameras = json.load(f)
    # Load poses
    with open(os.path.join(data_path, "poses.json")) as f:
        poses = json.load(f)
    # Images path
    images_dir = os.path.join(data_path, "images")
    images = sorted([os.path.join(images_dir, x) for x in os.listdir(images_dir) if x.lower().endswith((".jpg", ".png"))])
    return cameras, poses, images

def main():
    parser = argparse.ArgumentParser(description="VIPE + Gaussian Splatting training")
    parser.add_argument("--data_path", type=str, required=True, help="Path to scene dataset")
    parser.add_argument("--output", type=str, required=True, help="Output directory for checkpoints")
    parser.add_argument("--config", type=str, default=None, help="Optional config file (YAML)")

    args = parser.parse_args()
    os.makedirs(args.output, exist_ok=True)

    # Load dataset
    cameras, poses, images = load_scene(args.data_path)

    # Initialize dataset
    dataset = GaussianSplattingDataset(images, cameras, poses)

    # Initialize VIPE model
    model = VIPE()

    # Trainer
    trainer = Trainer(
        model=model,
        dataset=dataset,
        output_dir=args.output,
        num_iterations=5000,  # adjust for quick demo
        save_interval=500,    # save every 500 iterations
        preview_interval=100
    )

    # Run training
    trainer.train()

    print(f"Training complete. Checkpoints and previews are saved in {args.output}")

if __name__ == "__main__":
    main()
