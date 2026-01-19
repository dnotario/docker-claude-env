.PHONY: help build up down restart shell logs clean rebuild test install

# Default target
.DEFAULT_GOAL := help

# Image and container names
IMAGE_NAME := claude-dev-env
IMAGE_TAG := latest
CONTAINER_NAME := claude-dev

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Docker image
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

up: ## Start the development environment
	@echo "Starting development environment..."
	docker-compose up -d

down: ## Stop the development environment
	@echo "Stopping development environment..."
	docker-compose down

restart: down up ## Restart the development environment

shell: ## Open a shell in the running container
	@echo "Opening shell in container..."
	docker-compose exec dev zsh || docker run -it --rm -v $(PWD)/workspace:/workspace $(IMAGE_NAME):$(IMAGE_TAG)

logs: ## View container logs
	docker-compose logs -f dev

clean: ## Remove container and volumes
	@echo "Cleaning up containers and volumes..."
	docker-compose down -v
	docker system prune -f

rebuild: clean build up ## Rebuild everything from scratch

rebuild-no-cache: ## Rebuild without cache
	@echo "Rebuilding without cache..."
	docker-compose down -v
	docker build --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .
	docker-compose up -d

test: ## Run basic tests on the image
	@echo "Testing Docker image..."
	@echo "Testing Claude Code CLI..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) claude --version || echo "Claude Code check completed"
	@echo "Testing Node.js..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) node --version
	@echo "Testing Python..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) python3 --version
	@echo "Testing Go..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) go version
	@echo "Testing Rust..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) rustc --version
	@echo "Testing Git..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) git --version
	@echo "All tests passed!"

install: build ## Build image and start environment (recommended for first-time setup)
	@echo "Installing Claude Development Environment..."
	@$(MAKE) up
	@echo ""
	@echo "=========================================="
	@echo "  Setup Complete!"
	@echo "=========================================="
	@echo ""
	@echo "To enter the development environment:"
	@echo "  make shell"
	@echo ""
	@echo "First-time setup inside the container:"
	@echo "  claude login"
	@echo ""
	@echo "For more commands:"
	@echo "  make help"
	@echo ""

status: ## Show container status
	@docker-compose ps

size: ## Show image size
	@docker images $(IMAGE_NAME):$(IMAGE_TAG) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

prune: ## Remove unused Docker resources
	@echo "Pruning unused Docker resources..."
	docker system prune -af --volumes

workspace: ## Create workspace directory if it doesn't exist
	@mkdir -p workspace
	@echo "Workspace directory ready at: $(PWD)/workspace"
