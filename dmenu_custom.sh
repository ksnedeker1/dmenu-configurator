#!/bin/bash

FILE="$0"
ACTION_FLAG="--add-item"

declare -A actions
actions=(
    ["firefox"]="firefox"
    ["kitty"]="kitty"
)


# If the script is called with the --add-item flag
if [ "$1" == "$ACTION_FLAG" ] && [ "$#" -eq 3 ]; then
    # Hint on invalid param pattern
    if [ "$#" -ne 3 ]; then
        echo "Usage: $0 $ACTION_FLAG <name> <command>"
        exit 1
    fi

    KEY="$2"
    VALUE="$3"

    # Check if the key is already in the actions dictionary
    if [[ "${actions[$KEY]}" ]]; then
        echo "Error: Key '$KEY' already exists in actions."
        exit 1
    fi

    # Check if the value (program/command) is executable
    if ! command -v "$VALUE" &>/dev/null && ! [[ -x "$VALUE" ]]; then
        echo "Error: Program '$VALUE' does not exist or is not executable on the system."
        exit 1
    fi

    # Insert the new item after first pattern match
    awk -v key="$KEY" -v value="$VALUE" \
    '/actions=\(/ && !found {print; print "    [\"" key "\"]=\"" value "\""; found=1; next} 1' \
    "$FILE" > "$FILE.tmp"
    mv "$FILE.tmp" "$FILE"
    chmod +x "$FILE"

    echo "Added [$2]=$3 to actions."
    exit 0
fi

# Call dmenu with choices and receive user selection
CHOICES=$(printf "%s\n" "${!actions[@]}")
CHOICE=$(echo -e "$CHOICES" | dmenu -i -p "Choose:")

if [[ -n "$CHOICE" && -n "${actions[$CHOICE]}" ]]; then
    "${actions[$CHOICE]}" &
fi
