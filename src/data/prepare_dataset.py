import argparse
from pathlib import Path
import shutil
import subprocess

# Allowed image extensions
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def create_video_from_images(
    images_dir: Path,
    video_dir: Path,
    video_name:str,
    framerate: int = 30,
    scale: float = 1.0,
    codec: str = "libx264",
    quality: str = "medium"
):  
    video_dir.mkdir(parents=True, exist_ok=True)

    video_path = video_dir / f"{video_name}.mp4"

    # Check if there are images
    images = sorted([f for f in images_dir.iterdir() if f.suffix.lower() in IMAGE_EXTENSIONS])
    if not images:
        print(f"No images found in {images_dir}")
        return False
    
    # Build ffmpeg command
    cmd = [
        "ffmpeg",
        "-y",  # Overwrite output file without asking
        "-framerate", str(framerate),
        "-pattern_type", "glob",
        "-i", str(images_dir / "frame_*.jpg"),  # Assumes .jpg extension
    ]
    
    # Add video filter for scaling if specified
    if scale is not None and scale != 1.0:
        cmd.extend(["-vf", f"scale=iw*{scale}:ih*{scale}"])
    
    # Add output options
    cmd.extend([
        "-c:v", codec,
        "-preset", quality,
        "-crf", "23",  # Constant Rate Factor (0-51, lower is better quality)
        "-pix_fmt", "yuv420p",  # Widely compatible pixel format
        str(video_path)
    ])
    
    print(f"Creating video: {video_path}")
    print(f"  Resolution scaling: {scale if scale else 'original'}")
    print(f"  Framerate: {framerate} fps")
    print(f"  Codec: {codec} ({quality} preset)")
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"✅ Video created successfully: {video_path}")
        # Get video info
        video_info = subprocess.run(
            ["ffprobe", "-v", "error", "-show_format", "-show_streams", str(video_path)],
            capture_output=True,
            text=True
        )
        if video_info.returncode == 0:
            # Extract resolution from output
            import re
            width_match = re.search(r'width=(\d+)', video_info.stdout)
            height_match = re.search(r'height=(\d+)', video_info.stdout)
            if width_match and height_match:
                print(f"  Resolution: {width_match.group(1)}x{height_match.group(1)}")

        print(f"ViPE dataset ready at: {video_path}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to create video:")
        print(f"Error: {e.stderr}")

def prepare_dataset(raw_dir: Path, images_dir: Path):
    """
    Copy images from raw_dir to dataset_dir with sequential frame names.
    """
    if not raw_dir.exists() or not any(raw_dir.iterdir()):
        raise FileNotFoundError(f"No images found in {raw_dir}")

    images_dir.mkdir(parents=True, exist_ok=True)

    # Get images, sorted alphabetically
    images = sorted([f for f in raw_dir.iterdir() if f.suffix.lower() in IMAGE_EXTENSIONS])
    print(f"Preparing {len(images)} images for COLMAP/VIPE...")

    for idx, img_path in enumerate(images, start=1):
        ext = img_path.suffix.lower()
        frame_name = f"frame_{idx:04d}{ext}"
        target_path = images_dir / frame_name
        shutil.copy(img_path, target_path)

    print(f"Colmap dataset ready at: {images_dir}")


def main():
    parser = argparse.ArgumentParser(description="Prepare existing raw dataset for COLMAP/VIPE")
    parser.add_argument("--raw_input", required=True, help="Path to raw dataset folder")
    parser.add_argument("--dataset_output", required=True, help="Output dataset directory for COLMAP/VIPE")
    parser.add_argument("--video_name", required=True, help="Output dataset directory for COLMAP/VIPE")
    parser.add_argument("--vipe_scale", required=True, help="ViPE video scale")

    args = parser.parse_args()

    raw_input = Path(args.raw_input)
    dataset_dir = Path(args.dataset_output)
    images_dir = dataset_dir / "images"
    video_path = dataset_dir / "video"
    vipe_scale = args.vipe_scale

    prepare_dataset(raw_input, images_dir)
    create_video_from_images(images_dir, video_path, video_name=args.video_name, scale=vipe_scale)


if __name__ == "__main__":
    main()
