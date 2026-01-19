#!/bin/bash

# Verification script for Claude Code Docker Environment
# Tests minimal installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FAILED=0
CONTAINER_RUNNING=false

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Claude Code Environment Verification${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Test function
test_component() {
    local name="$1"
    local command="$2"

    if eval "$command" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $name"
    else
        echo -e "  ${RED}✗${NC} $name"
        FAILED=$((FAILED + 1))
    fi
}

# Test Docker
echo -e "${YELLOW}Checking Docker...${NC}"
test_component "Docker installed" "docker --version"
test_component "Docker running" "docker info"
test_component "Docker Compose" "docker compose version"

# Test image
echo ""
echo -e "${YELLOW}Checking Image...${NC}"
test_component "Image exists" "docker images | grep -q claude-dev-env"

# Test container
echo ""
echo -e "${YELLOW}Checking Container...${NC}"

# Check if container is running
if docker compose ps | grep -q "Up"; then
    echo -e "Container status: ${GREEN}Running${NC}"
    CONTAINER_RUNNING=true
else
    echo -e "Container status: ${YELLOW}Not running (starting it now)${NC}"
    docker compose up -d &> /dev/null
    sleep 5
    CONTAINER_RUNNING=false
fi

# Test minimal tools inside container
echo ""
echo -e "${YELLOW}Checking Essential Tools...${NC}"

test_component "Node.js" "docker compose exec -T claude node --version"
test_component "npm" "docker compose exec -T claude npm --version"
test_component "Git" "docker compose exec -T claude git --version"
test_component "Claude Code CLI" "docker compose exec -T claude which claude"

echo ""
echo -e "${YELLOW}Checking Utilities...${NC}"
test_component "jq" "docker compose exec -T claude jq --version"
test_component "vim" "docker compose exec -T claude vim --version"
test_component "zsh" "docker compose exec -T claude zsh --version"
test_component "curl" "docker compose exec -T claude curl --version"

echo ""
echo -e "${YELLOW}Checking Permissions...${NC}"
test_component "Workspace writable" "docker compose exec -T claude test -w /workspace"

# Stop container if we started it
if [ "$CONTAINER_RUNNING" = false ]; then
    docker compose down &> /dev/null
fi

# Summary
echo ""
echo -e "${BLUE}================================================${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Your environment is ready.${NC}"
    echo ""
    echo -e "To get started:"
    echo -e "  ${YELLOW}docker compose exec claude zsh${NC}  - Enter the development container"
    echo -e "  ${YELLOW}claude login${NC}                    - Authenticate with Claude (first time only)"
    echo ""
    echo -e "Your projects go in: ${YELLOW}./workspace/${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please check the output above.${NC}"
    echo ""
    echo -e "Common fixes:"
    echo -e "  - Run ${YELLOW}./setup.sh${NC} to rebuild"
    echo -e "  - Run ${YELLOW}docker compose down -v && docker compose build --no-cache${NC} to rebuild from scratch"
    echo -e "  - Check Docker is running: ${YELLOW}docker info${NC}"
    exit 1
fi
