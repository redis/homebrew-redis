#!/bin/bash
set -e

# Input TAG is expected in $1
TAG="$1"

if [ -z "$TAG" ]; then
    echo "Error: TAG is required as first argument"
    exit 1
fi

echo "TAG: $TAG"

# Function to update redis_version.json
update_redis_version() {
    local version_file="$1"
    local tag="$2"

    if [ ! -f "$version_file" ]; then
        echo "Warning: $version_file not found, skipping"
        return 1
    fi

    echo "Updating $version_file..."

    # Check if this version already exists in version_file
    if [ "$(jq -r '.ref' "$version_file")" = "$tag" ]; then
        echo "Version $tag already exists in $version_file, skipping"
        return 1
    fi

    # Create temporary file with new entry
    temp_version_file=$(mktemp)

    # Change version
    jq --arg tag "$tag" '.ref = $tag' $version_file > $temp_version_file

    # Replace original with updated version
    mv "$temp_version_file" "$version_file"

    echo "Successfully updated $version_file with version $tag"
    return 0
}

version_file="configs/redis_version.json"
# Track which files were modified
changed_files=()

# Update the version_file
if update_redis_version "$version_file" "$TAG"; then
    changed_files+=("$version_file_file")
fi

# Check what files actually changed in git
mapfile -t changed_files < <(git diff --name-only "$version_file")

# Output the list of changed files for GitHub Actions
if [ ${#changed_files[@]} -gt 0 ]; then
    echo "Files were modified:"
    printf '%s\n' "${changed_files[@]}"

    if [ -z "$GITHUB_OUTPUT" ]; then
        GITHUB_OUTPUT=/dev/stdout
    fi

    # Set GitHub Actions output
    changed_files_output=$(printf '%s\n' "${changed_files[@]}")
    {
        echo "changed_files<<EOF"
        echo "$changed_files_output"
        echo "EOF"
    } >> "$GITHUB_OUTPUT"

    echo "Changed files output set for next step"
else
    echo "No files were modified"
    echo "changed_files=" >> "$GITHUB_OUTPUT"
fi