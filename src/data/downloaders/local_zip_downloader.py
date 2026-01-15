import argparse
import zipfile
from pathlib import Path

# Allowed image extensions
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def extract_images_from_zip(zip_path: Path, output_dir: Path):
    if not zip_path.exists():
        raise FileNotFoundError(f"ZIP file not found: {zip_path}")

    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Extracting images from {zip_path} to {output_dir}")

    with zipfile.ZipFile(zip_path, "r") as zf:
        for file_info in zf.infolist():
            # Skip directories
            if file_info.is_dir():
                continue

            file_ext = Path(file_info.filename).suffix.lower()
            if file_ext not in IMAGE_EXTENSIONS:
                continue  # skip non-image files

            # Extract to output_dir (flatten folders)
            target_path = output_dir / Path(file_info.filename).name
            with zf.open(file_info) as source, open(target_path, "wb") as target:
                target.write(source.read())

    #print("Removing ZIP file...")
    #zip_path.unlink()

    print(f"Dataset ready at: {output_dir}")


def main():
    parser = argparse.ArgumentParser(description="Extract only images from a local ZIP")
    parser.add_argument("--zip", required=True, help="Path to local ZIP file")
    parser.add_argument("--output", required=True, help="Output directory")

    args = parser.parse_args()
    extract_images_from_zip(Path(args.zip), Path(args.output))


if __name__ == "__main__":
    main()
