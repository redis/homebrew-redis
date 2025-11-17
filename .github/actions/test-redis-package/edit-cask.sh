#!/bin/bash
set -e

# Script to edit cask files with specified parameters
# Usage: edit-cask.sh --cask <cask_name> --binary <binary_path> [--tap <tap_name>] <TAG>

# Initialize variables
CASK_NAME=""
BINARY_PATH=""
TAG=""
TAP="redis/redis"

# Function to display usage
usage() {
    echo "Usage: $0 --cask <cask_name> --binary <binary_path> [--tap <tap_name>] <TAG>"
    echo ""
    echo "Arguments:"
    echo "  --cask <cask_name>      Name of the cask to edit (e.g., redis, redis-rc)"
    echo "  --binary <binary_path>  Path to the binary package"
    echo "  --tap <tap_name>        Optional. Homebrew tap name (default: redis/redis)"
    echo "  <TAG>                   Version tag (positional argument)"
    echo ""
    echo "Examples:"
    echo "  $0 --cask redis --binary redis-ce-8.2.3-arm64.zip 8.2.3"
    echo "  $0 --cask redis --binary redis-ce-8.2.3-arm64.zip --tap redis/redis 8.2.3"
    exit 1
}

edit_cask_file(){
    tag=$1
    binary_path=$2
    tap=$3
    cask_name=$4

    casks_path="$(brew --repository $tap)/Casks/${cask_name}.rb"

    # Change version
    sed -i '' "s/version \"[^\"]*\"/version \"$tag\"/" $casks_path
    # change url to file://
    sed -i '' "s|url \".*\"|url \"file://$binary_path\"|" $casks_path
    # Remove sha256 verification since it's local testing
    sed -i '' '/sha256 arm:/,/intel:.*"$/d' $casks_path
    #temporary remove conflicts_with
    sed -i '' '/conflicts_with/d' $casks_path

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
if [ -z "$CASK_NAME" ]; then
    echo "Error: --cask argument is required"
    usage
fi

if [ -z "$BINARY_PATH" ]; then
    echo "Error: --binary argument is required"
    usage
fi

if [ -z "$TAG" ]; then
    echo "Error: TAG argument is required"
    usage
fi

edit_cask_file $TAG $BINARY_PATH $TAP $CASK_NAME

echo "Cask editing completed successfully"
