import json
import glob

def format_json():
    """Format all json files quick & dirty."""
    files = glob.glob("../*_json/*.json")
    for file in files:
        with open(file, "r") as f:
            content = json.load(f)
        with open(file, "w") as f:
            json.dump(content, f, indent=4)

if __name__ == "__main__":
    format_json()