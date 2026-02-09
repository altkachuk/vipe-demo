import os
import re
import argparse
from pathlib import Path

def format_images(images_dir:Path, images_txt:Path, points3D_txt:Path):
    # 1️⃣ Rename image files
    for filename in os.listdir(images_dir):
        if filename.startswith("frame_") and filename.endswith(".jpg"):
            match = re.match(r"frame_(\d+)\.jpg", filename)
            if match:
                old_number = int(match.group(1))
                new_number = old_number + 1  # start from 0001 instead of 0000
                new_name = f"frame_{str(new_number).zfill(4)}.jpg"
                old_path = os.path.join(images_dir, filename)
                new_path = os.path.join(images_dir, new_name)
                if old_path != new_path:
                    os.rename(old_path, new_path)
                    print(f"Renamed {filename} → {new_name}")

    # 2️⃣ Update images.txt
    with open(images_txt, "r") as f:
        lines = f.readlines()

    with open(images_txt, "w") as f:
        for line in lines:
            # Skip comments
            if line.startswith("#"):
                f.write(line)
                continue
            # Update image name
            parts = line.strip().split()
            if len(parts) >= 10:
                img_name = parts[9]
                match = re.match(r"frame_(\d+)\.jpg", img_name)
                if match:
                    new_number = int(match.group(1)) + 1  # start from 0001
                    parts[9] = f"frame_{str(new_number).zfill(4)}.jpg"
                    line = " ".join(parts) + "\n"
            f.write(line)

    # --- Step 3: Reformat points3D.txt ---
    with open(points3D_txt, "r") as f:
        lines = f.readlines()

    header_lines = [line for line in lines if line.startswith("#")]
    data_lines = [line for line in lines if not line.startswith("#") and line.strip()]

    formatted_lines = []
    for line in data_lines:
        parts = line.strip().split()
        formatted_line = "{:<7} {:>10.6f} {:>10.6f} {:>10.6f} {:>3} {:>3} {:>3} {:>10.6f} {}".format(
            parts[0], float(parts[1]), float(parts[2]), float(parts[3]),
            int(parts[4]), int(parts[5]), int(parts[6]), float(parts[7]), " ".join(parts[8:])
        )
        formatted_lines.append(formatted_line + "\n")

    with open(points3D_txt, "w") as f:
        f.writelines(header_lines + formatted_lines)
    print("Reformatted points3D.txt")

    print("✅ Renaming complete!")

def main():
    parser = argparse.ArgumentParser(description="Prepare existing raw dataset for COLMAP/VIPE")
    parser.add_argument("--dir", required=True, help="Directory for COLMAP/VIPE")

    args = parser.parse_args()

    colmap_dir = Path(args.dir)
    images_dir = colmap_dir / "images"
    images_txt = colmap_dir / "images.txt"
    points3D_txt = colmap_dir / "points3D.txt"

    format_images(images_dir, images_txt, points3D_txt)


if __name__ == "__main__":
    main()
