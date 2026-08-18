#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path

def count_lines(filepath: Path) -> int:
    """Return number of lines in a text file, ignoring binary/unreadable files."""
    try:
        with filepath.open('r', encoding='utf-8', errors='ignore') as f:
            return sum(1 for _ in f)
    except (OSError, UnicodeError):
        return 0

def build_tree_data(directory: Path, min_lines: int, ignore_hidden: bool = True):
    """Recursively collect subdirectories and files matching line threshold."""
    matching_files = []
    sub_trees = []

    try:
        entries = sorted(directory.iterdir(), key=lambda p: (not p.is_dir(), p.name.lower()))
    except PermissionError:
        return None

    for entry in entries:
        if ignore_hidden and entry.name.startswith('.'):
            continue

        if entry.is_file():
            lines = count_lines(entry)
            if lines > min_lines:
                matching_files.append((entry.name, lines))
        elif entry.is_dir():
            subtree = build_tree_data(entry, min_lines, ignore_hidden)
            if subtree and (subtree['files'] or subtree['subdirs']):
                sub_trees.append(subtree)

    return {
        'name': directory.name,
        'path': directory,
        'files': matching_files,
        'subdirs': sub_trees
    }

def print_tree(node, prefix: str = "", is_root: bool = True):
    if is_root:
        print(f"\033[1;34m📁 {node['path'].resolve().name}/\033[0m")
    
    entries = []
    for d in node['subdirs']:
        entries.append(('dir', d))
    for f in node['files']:
        entries.append(('file', f))

    total = len(entries)
    for idx, (entry_type, item) in enumerate(entries):
        is_last = (idx == total - 1)
        connector = "└── " if is_last else "├── "
        extension = "    " if is_last else "│   "

        if entry_type == 'dir':
            print(f"{prefix}{connector}\033[1;34m📁 {item['name']}/\033[0m")
            print_tree(item, prefix + extension, is_root=False)
        else:
            filename, lines = item
            print(f"{prefix}{connector}\033[0;32m📄 {filename}\033[0m \033[1;33m({lines:,} lines)\033[0m")

def main():
    parser = argparse.ArgumentParser(
        description="Display a directory tree showing only files exceeding a line threshold."
    )
    parser.add_argument(
        "folder",
        nargs="?",
        default=".",
        help="Target folder path (defaults to current directory)"
    )
    parser.add_argument(
        "-l", "--min-lines",
        type=int,
        default=200,
        help="Minimum line count threshold (default: 200)"
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Include hidden files and folders"
    )

    args = parser.parse_args()
    target_path = Path(args.folder)

    if not target_path.exists() or not target_path.is_dir():
        print(f"Error: '{args.folder}' is not a valid directory.", file=sys.stderr)
        sys.exit(1)

    print(f"Scanning '{target_path.resolve()}' for files with > {args.min_lines} lines...\n")
    tree_data = build_tree_data(target_path, min_lines=args.min_lines, ignore_hidden=not args.all)

    if not tree_data or (not tree_data['files'] and not tree_data['subdirs']):
        print("No files found exceeding the specified line threshold.")
        return

    print_tree(tree_data)

if __name__ == "__main__":
    main()
