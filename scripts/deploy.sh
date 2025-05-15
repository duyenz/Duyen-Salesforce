#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
TARGET_ORG=""
CHECKONLY="false"
TEST_LEVEL="RunLocalTests"
SPECIFIED_TESTS=""
SOURCE_PATH="force-app"

# Function to display usage
usage() {
    echo "Usage: $0 [-o <target_org>] [-c] [-t <test_level>] [-s <specified_tests>] [-p <source_path>]"
    echo "  -o : Target org alias (required)"
    echo "  -c : Check only (validation)"
    echo "  -t : Test level (NoTestRun, RunSpecifiedTests, RunLocalTests, RunAllTestsInOrg)"
    echo "  -s : Specified tests (comma-separated list of test classes)"
    echo "  -p : Source path (defaults to force-app)"
    exit 1
}

# Parse command line options
while getopts "o:ct:s:p:" opt; do
    case $opt in
        o) TARGET_ORG="$OPTARG";;
        c) CHECKONLY="true";;
        t) TEST_LEVEL="$OPTARG";;
        s) SPECIFIED_TESTS="$OPTARG";;
        p) SOURCE_PATH="$OPTARG";;
        ?) usage;;
    esac
done

# Validate required parameters
if [ -z "$TARGET_ORG" ]; then
    echo -e "${RED}Error: Target org (-o) is required${NC}"
    usage
fi

# Validate test level
valid_test_levels=("NoTestRun" "RunSpecifiedTests" "RunLocalTests" "RunAllTestsInOrg")
if [[ ! " ${valid_test_levels[@]} " =~ " ${TEST_LEVEL} " ]]; then
    echo -e "${RED}Error: Invalid test level. Must be one of: ${valid_test_levels[*]}${NC}"
    exit 1
fi

# If RunSpecifiedTests is selected, ensure tests are specified
if [ "$TEST_LEVEL" == "RunSpecifiedTests" ] && [ -z "$SPECIFIED_TESTS" ]; then
    echo -e "${RED}Error: -s parameter with specified tests is required when using RunSpecifiedTests${NC}"
    exit 1
fi

# Build the deployment command
DEPLOY_CMD="sfdx force:source:deploy"
DEPLOY_CMD="$DEPLOY_CMD -p $SOURCE_PATH"
DEPLOY_CMD="$DEPLOY_CMD -u $TARGET_ORG"

if [ "$CHECKONLY" == "true" ]; then
    DEPLOY_CMD="$DEPLOY_CMD -c"
    echo -e "${YELLOW}Performing validation only...${NC}"
fi

# Add test level
DEPLOY_CMD="$DEPLOY_CMD -l $TEST_LEVEL"

# Add specified tests if provided
if [ ! -z "$SPECIFIED_TESTS" ]; then
    DEPLOY_CMD="$DEPLOY_CMD -r $SPECIFIED_TESTS"
fi

# Print deployment information
echo -e "${GREEN}Deployment Details:${NC}"
echo "Target Org: $TARGET_ORG"
echo "Source Path: $SOURCE_PATH"
echo "Check Only: $CHECKONLY"
echo "Test Level: $TEST_LEVEL"
if [ ! -z "$SPECIFIED_TESTS" ]; then
    echo "Specified Tests: $SPECIFIED_TESTS"
fi

# Execute deployment
echo -e "\n${GREEN}Executing deployment...${NC}"
echo "Command: $DEPLOY_CMD"
eval $DEPLOY_CMD

# Check deployment status
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment completed successfully!${NC}"
else
    echo -e "${RED}Deployment failed!${NC}"
    exit 1
fi