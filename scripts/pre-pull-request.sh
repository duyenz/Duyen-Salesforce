#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running Pre-Pull Request Checks...${NC}"

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)
echo -e "\n${YELLOW}Current branch: ${CURRENT_BRANCH}${NC}"

# Check if branch is up to date with main
echo -e "\n${YELLOW}Checking if branch is up to date with main...${NC}"
git fetch origin main:main
BEHIND_BY=$(git rev-list --count $CURRENT_BRANCH..main)
if [ $BEHIND_BY -gt 0 ]; then
    echo -e "${RED}Warning: Your branch is behind main by $BEHIND_BY commits${NC}"
    echo "Consider rebasing with main: git rebase main"
fi

# Check for uncommitted changes
echo -e "\n${YELLOW}Checking for uncommitted changes...${NC}"
if ! git diff --quiet HEAD; then
    echo -e "${RED}Warning: You have uncommitted changes${NC}"
    git status --short
fi

# Run Apex tests if sfdx is available
if command -v sfdx &> /dev/null; then
    echo -e "\n${YELLOW}Running Apex tests...${NC}"
    if ! sfdx force:apex:test:run -c -r human; then
        echo -e "${RED}Warning: Apex tests failed${NC}"
    fi
fi

# Check for hardcoded IDs in modified files
echo -e "\n${YELLOW}Checking for hardcoded IDs...${NC}"
git diff --name-only main | while read -r file; do
    if [[ -f "$file" ]]; then
        if grep -E "['\"][0-9a-zA-Z]{15,18}['\"]" "$file"; then
            echo -e "${RED}Warning: Possible hardcoded ID found in $file${NC}"
        fi
    fi
done

# Check for proper API version in modified files
echo -e "\n${YELLOW}Checking API versions...${NC}"
if [ -f "sfdx-project.json" ]; then
    API_VERSION=$(jq -r '.sourceApiVersion' sfdx-project.json)
    echo "Project API Version: $API_VERSION"
fi

# Check code coverage if available
echo -e "\n${YELLOW}Checking code coverage...${NC}"
if [ -d "force-app/main/default/classes" ]; then
    echo "Remember to ensure >75% code coverage for Apex classes"
fi

# Final recommendations
echo -e "\n${YELLOW}Pre-Pull Request Checklist:${NC}"
echo "□ Code has been tested locally"
echo "□ All Apex tests are passing"
echo "□ Code coverage is above 75%"
echo "□ No hardcoded IDs are present"
echo "□ API versions are consistent"
echo "□ Documentation has been updated"
echo "□ Commit messages are clear and descriptive"
echo "□ Branch is up to date with main"

# Print instructions for creating PR
echo -e "\n${GREEN}If all checks pass, you can create your pull request:${NC}"
echo "1. Push your changes: git push origin $CURRENT_BRANCH"
echo "2. Go to GitHub repository"
echo "3. Click 'New Pull Request'"
echo "4. Select 'main' as base and '$CURRENT_BRANCH' as compare"
echo "5. Fill out the pull request template"
echo "6. Request reviews from team members"