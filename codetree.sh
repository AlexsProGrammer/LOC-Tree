#!/usr/bin/env bash

# Colors
C_RESET="\033[0m"
C_DIR="\033[1;34m"
C_FILE="\033[0;32m"
C_COUNT="\033[1;33m"
C_DIM="\033[2m"

# Parse arguments
TARGET_DIR="${1:-.}"
MIN_LINES="${2:-200}"

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist." >&2
    exit 1
fi

# Switch into target directory so all relative traversal is cleanly isolated
cd "$TARGET_DIR" || exit 1

# Quick helper to count lines safely in text files
count_lines() {
    local file="$1"
    if [ -f "$file" ] && [ -r "$file" ]; then
        wc -l < "$file" 2>/dev/null | tr -d ' '
    else
        echo 0
    fi
}

# Recursive check: does this folder or any of its subfolders contain matching files?
has_matching_descendant() {
    local dir="$1"
    local entry
    for entry in "$dir"/*; do
        [ ! -e "$entry" ] && continue
        local name
        name="$(basename "$entry")"
        [[ "$name" == .* ]] && continue

        if [ -f "$entry" ]; then
            local lines
            lines=$(count_lines "$entry")
            if [ "$lines" -gt "$MIN_LINES" ] 2>/dev/null; then
                return 0
            fi
        elif [ -d "$entry" ]; then
            if has_matching_descendant "$entry"; then
                return 0
            fi
        fi
    done
    return 1
}

# Recursive tree printer
print_tree() {
    local current_dir="$1"
    local prefix="$2"

    local matching_subdirs=()
    local matching_files=()

    # Collect valid matching files & qualifying subdirectories
    for entry in "$current_dir"/*; do
        [ ! -e "$entry" ] && continue
        local name
        name="$(basename "$entry")"
        [[ "$name" == .* ]] && continue

        if [ -d "$entry" ]; then
            if has_matching_descendant "$entry"; then
                matching_subdirs+=("$entry")
            fi
        elif [ -f "$entry" ]; then
            local lines
            lines=$(count_lines "$entry")
            if [ "$lines" -gt "$MIN_LINES" ] 2>/dev/null; then
                matching_files+=("$entry|$lines")
            fi
        fi
    done

    # Merge items into an indexed list
    local total_items=$(( ${#matching_subdirs[@]} + ${#matching_files[@]} ))
    local current_idx=0

    # 1. Print valid subdirectories first
    for dir in "${matching_subdirs[@]}"; do
        ((current_idx++))
        local is_last=0
        [ "$current_idx" -eq "$total_items" ] && is_last=1

        local connector="├── "
        local next_prefix="${prefix}│   "
        if [ "$is_last" -eq 1 ]; then
            connector="└── "
            next_prefix="${prefix}    "
        fi

        echo -e "${prefix}${connector}${C_DIR}📁 $(basename "$dir")/${C_RESET}"
        print_tree "$dir" "$next_prefix"
    done

    # 2. Print matching files
    for item in "${matching_files[@]}"; do
        ((current_idx++))
        local is_last=0
        [ "$current_idx" -eq "$total_items" ] && is_last=1

        local connector="├── "
        [ "$is_last" -eq 1 ] && connector="└── "

        local filepath="${item%|*}"
        local lines="${item#*|}"
        local filename
        filename="$(basename "$filepath")"

        echo -e "${prefix}${connector}${C_FILE}📄 ${filename}${C_RESET} ${C_COUNT}(${lines} lines)${C_RESET}"
    done
}

# Execution
ROOT_LABEL="$(basename "$(pwd)")"
echo -e "${C_DIM}Scanning '${TARGET_DIR}' for files with > ${MIN_LINES} lines...${C_RESET}\n"

if has_matching_descendant "."; then
    echo -e "${C_DIR}📁 ${ROOT_LABEL}/${C_RESET}"
    print_tree "." ""
else
    echo "No files found exceeding $MIN_LINES lines."
fi
