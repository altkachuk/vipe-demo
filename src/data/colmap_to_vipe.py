import argparse
import os
import json
from pathlib import Path
import numpy as np

# You need a utility to read COLMAP binaries:
from colmap.colmap_read_model import read_cameras_binary, read_images_binary

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="COLMAP sparse/0 directory")
    parser.add_argument("--output", required=True, help="Output scene directory for VIPE")
    parser.add_argument("--images", required=True, help="Path to original images")
    args = parser.parse_args()

    os.makedirs(args.output, exist_ok=True)
    images_out = os.path.join(args.output, "images")
    os.makedirs(images_out, exist_ok=True)

    # Copy images (or just reference them)
    for img_file in os.listdir(args.images):
        if img_file.lower().endswith((".jpg", ".png")):
            src = os.path.join(args.images, img_file)
            dst = os.path.join(images_out, img_file)
            if not os.path.exists(dst):
                Path(dst).write_bytes(Path(src).read_bytes())

    # Load COLMAP cameras and images
    cameras = read_cameras_binary(os.path.join(args.input, "cameras.bin"))
    images = read_images_binary(os.path.join(args.input, "images.bin"))

    poses_list = []
    cameras_dict = {}

    for cam_id, cam in cameras.items():
        cameras_dict[cam_id] = {
            "model": cam.model,
            "width": cam.width,
            "height": cam.height,
            "params": cam.params.tolist()
        }

    for img_id, img in images.items():
        R = img.qvec2rotmat()
        t = img.tvec
        poses_list.append({
            "image": img.name,
            "rotation": R.tolist(),
            "translation": t.tolist(),
            "camera_id": img.camera_id
        })

    # Save cameras.json and poses.json
    with open(os.path.join(args.output, "cameras.json"), "w") as f:
        json.dump(cameras_dict, f, indent=2)
    with open(os.path.join(args.output, "poses.json"), "w") as f:
        json.dump(poses_list, f, indent=2)

    print(f"VIPE dataset prepared at {args.output}")

if __name__ == "__main__":
    main()
