from pathlib import Path
import csv
from datetime import datetime

# ==========================================
# Configuration
# ==========================================

ROOT_DIR = Path.cwd()
print(ROOT_DIR)

OUTPUT_DIR = ROOT_DIR / "project_reference"
OUTPUT_DIR.mkdir(exist_ok=True)

TREE_FILE = OUTPUT_DIR / "Project_Structure.md"
CSV_FILE = OUTPUT_DIR / "Project_File_Inventory.csv"

EXCLUDE_DIRS = {
    "__pycache__",
    ".git",
    ".venv",
    "venv",
    ".pytest_cache",
    ".mypy_cache",
    ".idea",
    ".vscode",
    "node_modules",
    "venvswinst"
}

EXCLUDE_FILES = {
    ".DS_Store"
}

EXCLUDE_EXTENSIONS = {
    ".pyc",
    ".log",
    ".tmp"
}

# ==========================================
# Tree Builder
# ==========================================

def is_excluded(path: Path) -> bool:

    if path.name in EXCLUDE_DIRS:
        return True

    if path.name in EXCLUDE_FILES:
        return True

    if path.suffix.lower() in EXCLUDE_EXTENSIONS:
        return True

    return False


def build_tree(directory: Path, prefix=""):

    entries = sorted(
        [p for p in directory.iterdir() if not is_excluded(p)],
        key=lambda p: (p.is_file(), p.name.lower())
    )

    lines = []

    for index, item in enumerate(entries):

        connector = "└── " if index == len(entries) - 1 else "├── "

        lines.append(f"{prefix}{connector}{item.name}")

        if item.is_dir():

            extension = (
                "    "
                if index == len(entries) - 1
                else "│   "
            )

            lines.extend(
                build_tree(
                    item,
                    prefix + extension
                )
            )

    return lines


# ==========================================
# CSV Inventory
# ==========================================

def generate_inventory(root_dir: Path):

    rows = []

    for path in root_dir.rglob("*"):

        if is_excluded(path):
            continue

        if any(part in EXCLUDE_DIRS for part in path.parts):
            continue

        if path.is_file():

            stats = path.stat()

            rows.append([
                str(path.relative_to(root_dir)),
                path.suffix,
                round(stats.st_size / 1024, 2),
                datetime.fromtimestamp(
                    stats.st_mtime
                ).strftime("%Y-%m-%d %H:%M:%S")
            ])

    return rows


# ==========================================
# Main
# ==========================================

def main():

    tree_lines = [
        "# Project Structure",
        "",
        f"Generated: {datetime.now()}",
        "",
        "```text",
        ROOT_DIR.name,
    ]

    tree_lines.extend(
        build_tree(ROOT_DIR)
    )

    tree_lines.append("```")

    TREE_FILE.write_text(
        "\n".join(tree_lines),
        encoding="utf-8"
    )

    inventory = generate_inventory(ROOT_DIR)

    with open(
        CSV_FILE,
        "w",
        newline="",
        encoding="utf-8"
    ) as csvfile:

        writer = csv.writer(csvfile)

        writer.writerow([
            "File",
            "Extension",
            "Size(KB)",
            "Last Modified"
        ])

        writer.writerows(inventory)

    print(f"Generated: {TREE_FILE}")
    print(f"Generated: {CSV_FILE}")


if __name__ == "__main__":
    main()