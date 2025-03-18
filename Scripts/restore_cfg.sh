#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC1091

# Initialize variables
STOW_DIR="$HOME/HyDE"
PACKAGE="Configs"
TARGET_DIR="$HOME"
BACKUP_FLAG=false
OVERWRITE_FLAG=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -b)
      BACKUP_FLAG=true
      shift
      ;;
    -o)
      OVERWRITE_FLAG=true
      shift
      ;;
    *)
      # If we have other arguments, ignore them
      shift
      ;;
  esac
done

# Run stow in dry-run mode to check for conflicts
echo "Performing dry run to check for conflicts..."
STOW_OUTPUT=$(stow -d "$STOW_DIR" "$PACKAGE" -t "$TARGET_DIR" -n 2>&1)

# Check if there are conflicts in the output
if echo "$STOW_OUTPUT" | grep -q "cannot stow"; then
  echo "Found conflicts in the following files:"
  
  # Extract and display conflicting files with proper handling of spaces
  echo "$STOW_OUTPUT" | grep "cannot stow" | while IFS= read -r line; do
    # Extract the target path more reliably
    target_file=$(echo "$line" | sed -E 's/.*over existing target (.*) since.*/\1/')
    echo "- $TARGET_DIR/$target_file"
  done
  
  # Determine how to handle conflicts
  if [[ "$BACKUP_FLAG" == true ]]; then
    echo "Backing up conflicting files..."
    conflict_action="backup"
  elif [[ "$OVERWRITE_FLAG" == true ]]; then
    echo "Overwriting conflicting files..."
    conflict_action="overwrite"
  else
    # Prompt the user for action
    echo "There are conflicting files. What do you want to do?"
    echo "1. Create backups of conflicting files (append .backup)"
    echo "2. Delete conflicting files"
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
      1)
        echo "Backing up conflicting files..."
        conflict_action="backup"
        ;;
      2)
        echo "Deleting conflicting files..."
        conflict_action="overwrite"
        ;;
      *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
    esac
  fi
  
  # Handle conflicts based on the selected action
  echo "$STOW_OUTPUT" | grep "cannot stow" | while IFS= read -r line; do
    # Extract the target path more reliably
    target_file=$(echo "$line" | sed -E 's/.*over existing target (.*) since.*/\1/')
    full_target_path="$TARGET_DIR/$target_file"
    
    # Make sure the directory exists for the target
    target_dir=$(dirname "$full_target_path")
    if [[ ! -d "$target_dir" ]]; then
      mkdir -p "$target_dir"
    fi
    
    if [[ "$conflict_action" == "backup" ]]; then
      if [[ -f "$full_target_path" ]]; then
        echo "Backing up $full_target_path to ${full_target_path}.backup"
        mv "$full_target_path" "${full_target_path}.backup"
      elif [[ -e "$full_target_path" ]]; then
        # Handle other file types (directories, symlinks, etc.)
        echo "Backing up $full_target_path to ${full_target_path}.backup"
        mv "$full_target_path" "${full_target_path}.backup"
      else
        echo "Warning: $full_target_path does not exist, cannot create backup"
      fi
    elif [[ "$conflict_action" == "overwrite" ]]; then
      echo "Removing $full_target_path"
      rm -f "$full_target_path"
    fi
  done
  
  # Run stow command for real after handling conflicts
  echo "Running stow command to create symlinks..."
  stow -d "$STOW_DIR" "$PACKAGE" -t "$TARGET_DIR"
  
  # Check if stow succeeded
  if [ $? -ne 0 ]; then
    echo "Error: Stow command still encountered issues. Please check the output above."
    exit 1
  fi
else
  echo "No conflicts found. Proceeding with stow..."
  # Run stow command for real
  stow -d "$STOW_DIR" "$PACKAGE" -t "$TARGET_DIR"
fi

echo "Done!"