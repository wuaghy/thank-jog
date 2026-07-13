import os
import glob
from PIL import Image

TARGET_SIZE = (240, 200)

def process_image(path):
    try:
        img = Image.open(path).convert("RGBA")
        # The user said: "Hãy chỉnh tất cả về size 240x200 cho tôi"
        # We resize all images directly to 240x200
        img = img.resize(TARGET_SIZE, Image.Resampling.LANCZOS)
        img.save(path)
        print(f"Resized {path} to {TARGET_SIZE}")
    except Exception as e:
        print(f"Failed {path}: {e}")

if __name__ == "__main__":
    base_dir = "Assets/characters/horse_rider"
    for file in glob.glob(f"{base_dir}/**/*.png", recursive=True):
        process_image(file)
    print("Done resizing all images.")
