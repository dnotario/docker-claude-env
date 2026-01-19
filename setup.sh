#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Image name
IMAGE_NAME="claude-dev-env"
IMAGE_TAG="latest"

# Flags for docker setup
DOCKER_GROUP_ADDED=""
USE_SUDO=""
USE_SG=""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Claude Development Environment Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
    print_info "Detected OS: $OS ${DISTRO:+($DISTRO)}"
}

# Check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null; then
        print_success "Docker is already installed"
        docker --version
        return 0
    else
        print_warning "Docker is not installed"
        return 1
    fi
}

# Install Docker on Linux
install_docker_linux() {
    print_info "Installing Docker on Linux..."

    case $DISTRO in
        ubuntu|debian)
            # Update package index
            sudo apt-get update

            # Install prerequisites
            sudo apt-get install -y \
                ca-certificates \
                curl \
                gnupg \
                lsb-release

            # Add Docker's official GPG key
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

            # Set up the repository
            echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \
                $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Install Docker Engine
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;

        fedora|rhel|centos)
            sudo dnf -y install dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl start docker &> /dev/null
            ;;

        arch|manjaro)
            sudo pacman -Sy --noconfirm docker docker-compose
            sudo systemctl start docker &> /dev/null
            ;;

        *)
            print_error "Unsupported Linux distribution: $DISTRO"
            print_info "Please install Docker manually from https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac

    # Add current user to docker group if not already in it
    if ! groups $USER | grep -q docker; then
        print_info "Adding user to docker group..."
        sudo usermod -aG docker $USER
        DOCKER_GROUP_ADDED=1
    fi

    print_success "Docker installed successfully!"
}

# Install Docker on macOS
install_docker_macos() {
    print_info "Installing Docker on macOS..."

    if command -v brew &> /dev/null; then
        brew install --cask docker
        print_success "Docker installed successfully!"
        print_info "Please start Docker Desktop from your Applications folder"
        print_info "Press Enter once Docker Desktop is running..."
        read
    else
        print_error "Homebrew is not installed"
        print_info "Please install Docker Desktop manually from https://www.docker.com/products/docker-desktop"
        print_info "Or install Homebrew first: https://brew.sh"
        exit 1
    fi
}

# Install Docker
install_docker() {
    if [ "$OS" == "linux" ]; then
        install_docker_linux
    elif [ "$OS" == "macos" ]; then
        install_docker_macos
    fi
}

# Check if Docker daemon is running
check_docker_running() {
    # Try without sudo first
    if docker info &> /dev/null; then
        print_success "Docker daemon is running"
        return 0
    fi

    # If user was just added to docker group, try with sg
    if [ -n "$DOCKER_GROUP_ADDED" ]; then
        if sg docker -c "docker info" &> /dev/null; then
            print_success "Docker daemon is running"
            USE_SG=1
            return 0
        fi
    fi

    # Check with sudo if docker command fails
    if sudo docker info &> /dev/null; then
        print_success "Docker daemon is running"
        USE_SUDO=1
        return 0
    fi

    # Docker daemon is not running, try to start it
    print_error "Docker daemon is not running"
    if [ "$OS" == "linux" ]; then
        print_info "Starting Docker daemon..."
        sudo systemctl start docker &> /dev/null
        sudo systemctl enable docker &> /dev/null
        sleep 3

        # Check if docker is now running
        if docker info &> /dev/null || sudo docker info &> /dev/null; then
            print_success "Docker daemon started successfully"
            USE_SUDO=1
            return 0
        fi
    fi

    return 1
}

# Build Docker image
build_image() {
    print_info "Building Docker image: $IMAGE_NAME:$IMAGE_TAG"
    print_info "This may take several minutes on first build..."
    echo ""

    # Determine which docker command to use
    local DOCKER_CMD="docker"
    if [ -n "$USE_SUDO" ]; then
        DOCKER_CMD="sudo docker"
    elif [ -n "$USE_SG" ]; then
        DOCKER_CMD="sg docker -c docker"
    fi

    if $DOCKER_CMD build -t $IMAGE_NAME:$IMAGE_TAG .; then
        print_success "Docker image built successfully!"
        echo ""
        $DOCKER_CMD images | grep $IMAGE_NAME
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}


# Main setup process
main() {
    detect_os
    echo ""

    # Check and install Docker
    if ! check_docker; then
        echo ""
        read -p "Do you want to install Docker? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_docker
            echo ""
        else
            print_error "Docker is required. Exiting."
            exit 1
        fi
    fi

    echo ""

    # Check if Docker is running
    if ! check_docker_running; then
        print_error "Cannot connect to Docker daemon. Please start Docker and try again."
        exit 1
    fi

    echo ""

    # Build the image
    build_image

    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  Setup Complete!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""

    # Show warning about group changes if needed
    if [ -n "$DOCKER_GROUP_ADDED" ]; then
        echo -e "${YELLOW}Note:${NC} You were added to the docker group."
        echo -e "For the group changes to take effect in new shells:"
        echo -e "  ${YELLOW}• Log out and log back in${NC}"
        echo -e "  ${YELLOW}• Or run: newgrp docker${NC}"
        echo ""
    fi

    echo -e "${BLUE}Quick Start:${NC}"
    echo ""
    local DOCKER_PREFIX=""
    if [ -n "$USE_SUDO" ]; then
        DOCKER_PREFIX="sudo "
    elif [ -n "$USE_SG" ]; then
        DOCKER_PREFIX="sg docker -c "
    fi

    echo -e "  Run the container:"
    echo -e "  ${YELLOW}${DOCKER_PREFIX}docker run -it --rm -v \$(pwd):/workspace $IMAGE_NAME:$IMAGE_TAG${NC}"
    echo ""
    echo -e "  Or use docker-compose (recommended):"
    echo -e "  ${YELLOW}${DOCKER_PREFIX}docker-compose up -d${NC}"
    echo -e "  ${YELLOW}${DOCKER_PREFIX}docker-compose exec dev zsh${NC}"
    echo ""
    echo -e "${BLUE}First-time setup inside the container:${NC}"
    echo -e "  Run ${YELLOW}claude login${NC} to authenticate with Claude Code"
    echo ""
    echo -e "${BLUE}For more information, see README.md${NC}"
    echo ""
}

# Run main function
main
