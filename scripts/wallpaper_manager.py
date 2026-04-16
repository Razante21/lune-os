import os
import sys
import json
import subprocess
from pathlib import Path

def list_wallpapers():
    """List all images in the wallpapers directory."""
    wallpaper_dir = Path.home() / "Pictures" / "wallpapers"

    # Create directory if it doesn't exist
    wallpaper_dir.mkdir(parents=True, exist_ok=True)

    extensions = {'.jpg', '.jpeg', '.png', '.webp'}
    images = [str(f.absolute()) for f in wallpaper_dir.iterdir() if f.suffix.lower() in extensions]

    return json.dumps(images)

def apply_wallpaper(path):
    """Apply wallpaper using swww and generate colors using matugen."""
    try:
        # Apply image via swww
        subprocess.run(["swww", "img", path], check=True)

        # Generate colors via matugen
        subprocess.run(["matugen", "image", path], check=True)

        return json.dumps({"status": "success", "path": path})
    except subprocess.CalledProcessError as e:
        return json.dumps({"status": "error", "message": str(e)})
    except FileNotFoundError as e:
        return json.dumps({"status": "error", "message": f"Tool not found: {e}"})

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "message": "No command provided"}))
        sys.exit(1)

    command = sys.argv[1]

    if command == "list":
        print(list_wallpapers())
    elif command == "apply" and len(sys.argv) == 3:
        print(apply_wallpaper(sys.argv[2]))
    else:
        print(json.dumps({"status": "error", "message": "Invalid command or missing arguments"}))
        sys.exit(1)
