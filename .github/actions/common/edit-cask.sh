#!/bin/bash
set -e

# Script to edit cask files with specified parameters
# Usage: edit-cask.sh --cask <cask_name> --action <action> [--binary <binary_path>] [--package-json <json>] [--tap <tap_name>] <TAG>

# Initialize variables
CASK_NAME=""
BINARY_PATH=""
PACKAGE_JSON=""
TAG=""
TAP="redis/redis"
ACTION=""

# Function to display usage
usage() {
    echo "Usage: $0 --cask <cask_name> --action <action> [--binary <binary_path>] [--package-json <json>] [--tap <tap_name>] <TAG>"
    echo ""
    echo "Arguments:"
    echo "  --cask <cask_name>        Name of the cask to edit (e.g., redis, redis-rc)"
    echo "  --action <action>         Action caused the change (test or publish)"
    echo "  --binary <binary_path>    Path to the binary package (required for action=test)"
    echo "  --package-json <json>     JSON with package info including sha256 (required for action=publish)"
    echo "  --tap <tap_name>          Optional. Homebrew tap name (default: redis/redis)"
    echo "  <TAG>                     Version tag (positional argument)"
    echo ""
    echo "Examples:"
    echo "  # For testing with binary:"
    echo "  $0 --cask redis --action test --binary redis-oss-8.2.3-arm64.zip 8.2.3"
    echo ""
    echo "  # For publishing with package JSON:"
    echo "  $0 --cask redis --action publish --package-json '{\"arm64\":{\"sha256\":\"abc123...\"}}' 8.2.3"
    exit 1
}

edit_cask_file(){
    action=$1
    tag=$2
    data=$3  # binary_path for test, package_json for publish
    tap=$4
    cask_name=$5
    casks_path=""

    if [ "$action" = "test" ]; then
        casks_path="$(brew --repository $tap)/Casks/${cask_name}.rb"
        # For test action: use binary file
        binary_path="$data"

        # Validate binary path exists
        if [ ! -f "$binary_path" ]; then
            echo "Error: Binary file not found: $binary_path"
            exit 1
        fi

        # Change url to file://
        sed -i '' "s|url \".*\"|url \"file://$binary_path\"|" $casks_path
        # Remove sha256 verification since it's testing
        sed -i '' '/sha256 arm:/,/intel:.*"$/d' $casks_path

    elif [ "$action" = "publish" ]; then
        casks_path="$(pwd)/Casks/${cask_name}.rb"
        # For publish action: use package_json with sha256
        package_json="$data"

        # Validate package_json is valid JSON
        if ! echo "$package_json" | jq empty 2>/dev/null; then
            echo "Error: Invalid JSON in --package-json"
            exit 1
        fi

        # Extract sha256 values for each architecture
        arm_sha=$(echo "$package_json" | jq -r '.arm64.sha256 // empty')
        intel_sha=$(echo "$package_json" | jq -r '.x86_64.sha256 // empty')

        # Update sha256 values in cask file
        if [ -n "$arm_sha" ] && [ -n "$intel_sha" ]; then
            # Replace existing sha256 line with new values
            sed -i '' "s/sha256 arm: \"[^\"]*\",$/sha256 arm: \"$arm_sha\",/" $casks_path
            sed -i '' "/sha256 arm:/,/intel:/ s/intel: \"[^\"]*\"/intel: \"$intel_sha\"/" "$casks_path"
        else
            echo "Error: Missing sha256 values in package_json"
            exit 1
        fi

    else
        echo "Error: Invalid action '$action' in edit_cask_file"
        exit 1
    fi

    # Change version
    sed -i '' "s/version \"[^\"]*\"/version \"$tag\"/" $casks_path
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --cask)
            CASK_NAME="$2"
            shift 2
            ;;
        --binary)
            BINARY_PATH="$2"
            shift 2
            ;;
        --package-json)
            PACKAGE_JSON="$2"
            shift 2
            ;;
        --action)
            ACTION="$2"
            shift 2
            ;;
        --tap)
            TAP="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Error: Unknown option: $1"
            usage
            ;;
        *)
            # Positional argument - assume it's the TAG
            if [ -z "$TAG" ]; then
                TAG="$1"
            else
                echo "Error: Unexpected argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$CASK_NAME" ] || [ -z "$ACTION" ] || [ -z "$TAG" ]; then
    echo "Error: Missing required arguments"
    usage
fi

# Validate action value
if [ "$ACTION" != "test" ] && [ "$ACTION" != "publish" ]; then
    echo "Error: --action must be either 'test' or 'publish'"
    usage
fi

# Validate action-specific requirements and execute
if [ "$ACTION" = "test" ]; then
    if [ -z "$BINARY_PATH" ]; then
        echo "Error: --binary is required when action is 'test'"
        usage
    fi

    edit_cask_file "$ACTION" "$TAG" "$BINARY_PATH" "$TAP" "$CASK_NAME"

elif [ "$ACTION" = "publish" ]; then
    if [ -z "$PACKAGE_JSON" ]; then
        echo "Error: --package-json is required when action is 'publish'"
        usage
    fi
    edit_cask_file "$ACTION" "$TAG" "$PACKAGE_JSON" "$TAP" "$CASK_NAME"
fi

echo "Cask file editing completed successfully"
