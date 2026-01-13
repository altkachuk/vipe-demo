import argparse
from pathlib import Path
import shutil

# Allowed image extensions
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def prepare_dataset(raw_dir: Path, dataset_dir: Path):
    """
    Copy images from raw_dir to dataset_dir with sequential frame names.
    """
    if not raw_dir.exists() or not any(raw_dir.iterdir()):
        raise FileNotFoundError(f"No images found in {raw_dir}")

    dataset_dir.mkdir(parents=True, exist_ok=True)

    # Get images, sorted alphabetically
    images = sorted([f for f in raw_dir.iterdir() if f.suffix.lower() in IMAGE_EXTENSIONS])
    print(f"Preparing {len(images)} images for COLMAP/VIPE...")

    for idx, img_path in enumerate(images, start=1):
        ext = img_path.suffix.lower()
        frame_name = f"frame_{idx:04d}{ext}"
        target_path = dataset_dir / frame_name
        shutil.copy(img_path, target_path)

    print(f"Dataset ready at: {dataset_dir}")


def main():
    parser = argparse.ArgumentParser(description="Prepare existing raw dataset for COLMAP/VIPE")
    parser.add_argument("--raw_input", required=True, help="Path to raw dataset folder")
    parser.add_argument("--dataset_output", required=True, help="Output dataset directory for COLMAP/VIPE")

    args = parser.parse_args()
    prepare_dataset(Path(args.raw_input), Path(args.dataset_output))


if __name__ == "__main__":
    main()
