#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="development"
CONFIG_DIR="config/environments"

# Function to display usage
usage() {
    echo "Usage: $0 [-e <environment>]"
    echo "  -e : Environment (development, qa, uat, production)"
    exit 1
}

# Parse command line options
while getopts "e:" opt; do
    case $opt in
        e) ENVIRONMENT="$OPTARG";;
        ?) usage;;
    esac
done

# Validate environment
valid_environments=("development" "qa" "uat" "production")
if [[ ! " ${valid_environments[@]} " =~ " ${ENVIRONMENT} " ]]; then
    echo -e "${RED}Error: Invalid environment. Must be one of: ${valid_environments[*]}${NC}"
    exit 1
fi

# Check if configuration file exists
CONFIG_FILE="$CONFIG_DIR/$ENVIRONMENT.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file $CONFIG_FILE does not exist${NC}"
    exit 1
fi

# Load and validate JSON configuration
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${RED}Error: Invalid JSON in configuration file $CONFIG_FILE${NC}"
    exit 1
fi

# Export environment variables from configuration
echo -e "${GREEN}Loading configuration for $ENVIRONMENT environment...${NC}"

# Extract and export key configuration values
export SF_ENVIRONMENT=$ENVIRONMENT
export SF_INSTANCE_URL=$(jq -r .instanceUrl "$CONFIG_FILE")
export SF_API_VERSION=$(jq -r .apiVersion "$CONFIG_FILE")
export SF_TEST_LEVEL=$(jq -r .deploymentSettings.testLevel "$CONFIG_FILE")
export SF_SOURCE_DIR=$(jq -r .sourceDirectory "$CONFIG_FILE")

# Print configuration summary
echo -e "\n${GREEN}Configuration loaded:${NC}"
echo "Environment: $SF_ENVIRONMENT"
echo "Instance URL: $SF_INSTANCE_URL"
echo "API Version: $SF_API_VERSION"
echo "Test Level: $SF_TEST_LEVEL"
echo "Source Directory: $SF_SOURCE_DIR"

# Additional environment-specific settings
case $ENVIRONMENT in
    "production")
        echo -e "\n${YELLOW}Production environment detected - additional safety measures enabled:${NC}"
        echo "- Deployment window restrictions active"
        echo "- Approval required for deployments"
        echo "- Enhanced security settings enabled"
        ;;
    "uat")
        echo -e "\n${YELLOW}UAT environment detected:${NC}"
        echo "- Email deliverability disabled"
        echo "- Test endpoints configured for integrations"
        ;;
    "qa")
        echo -e "\n${YELLOW}QA environment detected:${NC}"
        echo "- Test data loading enabled"
        echo "- Parallel test execution enabled"
        ;;
    "development")
        echo -e "\n${YELLOW}Development environment detected:${NC}"
        echo "- Debug mode enabled"
        echo "- Test data loading enabled"
        ;;
esac

echo -e "\n${GREEN}Configuration loaded successfully!${NC}"