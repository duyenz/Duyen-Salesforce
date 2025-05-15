#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
SOURCE_ORG=""
TARGET_DIR="force-app/main/default"
PACKAGE_FILE="manifest/package.xml"

# Function to display usage
usage() {
    echo "Usage: $0 [-o <source_org>] [-d <target_directory>] [-p <package_file>]"
    echo "  -o : Source org alias (required)"
    echo "  -d : Target directory (defaults to force-app/main/default)"
    echo "  -p : Package.xml file path (defaults to manifest/package.xml)"
    exit 1
}

# Parse command line options
while getopts "o:d:p:" opt; do
    case $opt in
        o) SOURCE_ORG="$OPTARG";;
        d) TARGET_DIR="$OPTARG";;
        p) PACKAGE_FILE="$OPTARG";;
        ?) usage;;
    esac
done

# Validate required parameters
if [ -z "$SOURCE_ORG" ]; then
    echo -e "${RED}Error: Source org (-o) is required${NC}"
    usage
fi

# Check if package.xml exists
if [ ! -f "$PACKAGE_FILE" ]; then
    echo -e "${RED}Error: Package file $PACKAGE_FILE does not exist${NC}"
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Build the retrieve command
RETRIEVE_CMD="sfdx force:source:retrieve"
RETRIEVE_CMD="$RETRIEVE_CMD -x $PACKAGE_FILE"
RETRIEVE_CMD="$RETRIEVE_CMD -u $SOURCE_ORG"
RETRIEVE_CMD="$RETRIEVE_CMD -r $TARGET_DIR"

# Print retrieve information
echo -e "${GREEN}Retrieve Details:${NC}"
echo "Source Org: $SOURCE_ORG"
echo "Target Directory: $TARGET_DIR"
echo "Package File: $PACKAGE_FILE"

# Execute retrieve
echo -e "\n${GREEN}Executing retrieve...${NC}"
echo "Command: $RETRIEVE_CMD"
eval $RETRIEVE_CMD

# Check retrieve status
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Retrieve completed successfully!${NC}"
else
    echo -e "${RED}Retrieve failed!${NC}"
    exit 1
fi