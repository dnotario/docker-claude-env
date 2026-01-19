#!/bin/bash

# Verification script for Claude Development Environment
# Run this after setup to verify everything is working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Claude Development Environment Verification${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Test counter
PASSED=0
FAILED=0

# Function to test a component
test_component() {
    local name=$1
    local command=$2
    local expected=$3

    echo -n "Testing $name... "

    if eval "$command" &> /dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# Test Docker installation
echo -e "${YELLOW}Checking Host System...${NC}"
test_component "Docker installation" "docker --version"
test_component "Docker daemon" "docker info"
test_component "Docker Compose" "docker-compose --version"
echo ""

# Test image existence
echo -e "${YELLOW}Checking Docker Image...${NC}"
test_component "Image exists" "docker images | grep -q claude-dev-env"

# Get image size
if docker images | grep -q claude-dev-env; then
    SIZE=$(docker images claude-dev-env:latest --format "{{.Size}}")
    echo -e "  Image size: ${GREEN}${SIZE}${NC}"
fi
echo ""

# Test container
echo -e "${YELLOW}Checking Container...${NC}"

# Check if container is running
if docker-compose ps | grep -q "Up"; then
    echo -e "Container status: ${GREEN}Running${NC}"
    CONTAINER_RUNNING=true
else
    echo -e "Container status: ${YELLOW}Not running (starting it now)${NC}"
    docker-compose up -d &> /dev/null
    sleep 5
    CONTAINER_RUNNING=false
fi

# Test tools inside container
echo ""
echo -e "${YELLOW}Checking Tools Inside Container...${NC}"

test_component "Node.js" "docker-compose exec -T dev node --version"
test_component "Python" "docker-compose exec -T dev python3 --version"
test_component "Go" "docker-compose exec -T dev go version"
test_component "Rust" "docker-compose exec -T dev rustc --version"
test_component "Git" "docker-compose exec -T dev git --version"
test_component "Docker CLI" "docker-compose exec -T dev docker --version"
test_component "Claude Code CLI" "docker-compose exec -T dev which claude"

echo ""
echo -e "${YELLOW}Checking Package Managers...${NC}"
test_component "npm" "docker-compose exec -T dev npm --version"
test_component "yarn" "docker-compose exec -T dev yarn --version"
test_component "pnpm" "docker-compose exec -T dev pnpm --version"
test_component "pip" "docker-compose exec -T dev pip3 --version"
test_component "poetry" "docker-compose exec -T dev poetry --version"
test_component "cargo" "docker-compose exec -T dev cargo --version"

echo ""
echo -e "${YELLOW}Checking Development Tools...${NC}"
test_component "TypeScript" "docker-compose exec -T dev tsc --version"
test_component "ESLint" "docker-compose exec -T dev eslint --version"
test_component "Prettier" "docker-compose exec -T dev prettier --version"
test_component "pytest" "docker-compose exec -T dev pytest --version"
test_component "black" "docker-compose exec -T dev black --version"

echo ""
echo -e "${YELLOW}Checking Utilities...${NC}"
test_component "jq" "docker-compose exec -T dev jq --version"
test_component "ripgrep" "docker-compose exec -T dev rg --version"
test_component "zsh" "docker-compose exec -T dev zsh --version"

# Check workspace directory
echo ""
echo -e "${YELLOW}Checking Workspace...${NC}"
if [ -d "workspace" ]; then
    echo -e "Workspace directory: ${GREEN}✓ EXISTS${NC}"
    ((PASSED++))
else
    echo -e "Workspace directory: ${RED}✗ MISSING${NC}"
    echo "  Creating workspace directory..."
    mkdir -p workspace
    ((PASSED++))
fi

# Check file permissions
test_component "Workspace writable" "docker-compose exec -T dev test -w /workspace"

# Stop container if we started it
if [ "$CONTAINER_RUNNING" = false ]; then
    echo ""
    echo "Stopping container..."
    docker-compose down &> /dev/null
fi

# Summary
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Verification Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "Tests passed: ${GREEN}$PASSED${NC}"
echo -e "Tests failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Your environment is ready.${NC}"
    echo ""
    echo -e "To get started:"
    echo -e "  ${YELLOW}make shell${NC}       - Enter the development container"
    echo -e "  ${YELLOW}claude login${NC}     - Authenticate with Claude (first time only)"
    echo ""
    echo -e "Your projects go in: ${YELLOW}./workspace/${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please check the output above.${NC}"
    echo ""
    echo -e "Common fixes:"
    echo -e "  - Run ${YELLOW}./setup.sh${NC} to rebuild"
    echo -e "  - Run ${YELLOW}make rebuild${NC} to rebuild from scratch"
    echo -e "  - Check Docker is running: ${YELLOW}docker info${NC}"
    exit 1
fi
