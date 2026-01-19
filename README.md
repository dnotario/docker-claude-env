# Claude Development Environment

A comprehensive Docker-based development environment with Claude Code and all essential tools for frontend and backend development.

## Features

### Development Tools Included

**Frontend:**
- Node.js 20 (LTS) with npm, yarn, and pnpm
- TypeScript, ts-node
- Vite, Webpack
- ESLint, Prettier
- React (create-react-app), Vue CLI, Angular CLI

**Backend:**
- Python 3 with pip, pipenv, poetry, virtualenv
- Go 1.22
- Rust (latest stable)
- Common Python tools: black, flake8, pylint, pytest, ipython, jupyter

**Databases:**
- PostgreSQL client
- MySQL client
- SQLite3

**DevOps & Tools:**
- Docker CLI and Docker Compose
- Git and Git LFS
- curl, wget
- jq, ripgrep, fd-find
- vim, nano, zsh with oh-my-zsh
- tmux, htop

**AI Development:**
- Claude Code CLI (pre-installed)

## Quick Start

### One-Line Setup

```bash
curl -fsSL https://raw.githubusercontent.com/dnotario/docker-claude-env/main/setup.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/dnotario/docker-claude-env.git
cd docker-claude-env
./setup.sh
```

The setup script will:
1. Detect your operating system
2. Install Docker if not present
3. Configure container user to match your host UID/GID (avoids permission issues)
4. Build the Docker image
5. Provide usage instructions

### Manual Setup

If you prefer manual installation:

```bash
# Install Docker (if not already installed)
# See: https://docs.docker.com/engine/install/

# Build the image
docker build -t claude-dev-env:latest .

# Or use docker-compose
docker-compose build
```

## Usage

### Option 1: Direct Docker Run

Run a one-off container:

```bash
docker run -it --rm \
  -v $(pwd)/workspace:/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 3000:3000 \
  -p 8000:8000 \
  claude-dev-env:latest
```

### Option 2: Docker Compose (Recommended)

Start the development environment:

```bash
# Start the container in detached mode
docker-compose up -d

# Enter the container
docker-compose exec dev zsh

# Stop the container
docker-compose down
```

### Authenticating with Claude Code

After entering the container for the first time, authenticate with Claude Code:

```bash
# Inside the container
claude login
```

This will open a browser for authentication. Your credentials will be persisted in the `dev-home` volume.

## Container Configuration

### Exposed Ports

- `3000` - React, Next.js default
- `4200` - Angular default
- `5000` - Flask default
- `5173` - Vite default
- `8000` - Django, FastAPI default
- `8080` - General HTTP
- `8888` - Jupyter Notebook
- `9000` - Custom applications

You can modify ports in `docker-compose.yml` or when running with `docker run`.

### Volume Mounts

**Default mounts in docker-compose:**
- `./workspace` → `/workspace` - Your project files
- `/var/run/docker.sock` → Container's Docker socket (for docker-in-docker)
- `dev-home` volume → `/home/dev` - Persists user configs and cache

**Optional mounts** (uncomment in docker-compose.yml):
- `~/.ssh` → `/home/dev/.ssh` - SSH keys for git operations
- `~/.gitconfig` → `/home/dev/.gitconfig` - Git configuration

### User Configuration and Permissions

The container runs as a non-root user for security (default: `dev`, UID: 1000, GID: 1000) with sudo access.

**Important for File Permissions:**

When mounting volumes from your host, file permissions can cause issues if the container user's UID/GID doesn't match your host user. The setup script automatically offers to configure this for you.

**Option 1: Automatic Configuration (Recommended)**

Run the setup script, which will detect your host UID/GID and configure automatically:
```bash
./setup.sh
```

**Option 2: Manual Configuration**

1. Check your host user's UID and GID:
```bash
id
# Output: uid=1001(yourname) gid=1001(yourgroup) ...
```

2. Create a `.env` file (or copy from `.env.example`):
```bash
cp .env.example .env
```

3. Edit `.env` and set your values:
```env
USERNAME=yourname
USER_UID=1001
USER_GID=1001
```

4. Build with these settings:
```bash
docker-compose build
```

**Using Different UIDs:**
- UID 1000 matches most Linux desktop users by default
- If you have a different UID, you must configure it to avoid permission errors
- On macOS, Docker Desktop handles permissions automatically, but matching is still recommended
- The container user will have the same permissions as your host user for mounted files

## Using Claude Code

Claude Code is pre-installed in the container.

**First-time setup:**
```bash
# Inside the container, authenticate
claude login
```

**Using Claude Code:**
```bash
# Start an interactive session
claude

# Or run specific commands
claude --help
```

Your authentication credentials are persisted in the `dev-home` volume, so you only need to log in once.

## Common Tasks

### Install Project Dependencies

```bash
# Node.js
npm install
# or
yarn install
# or
pnpm install

# Python
pip install -r requirements.txt
# or
poetry install
# or
pipenv install

# Go
go mod download

# Rust
cargo build
```

### Run Tests

```bash
# Node.js
npm test

# Python
pytest

# Go
go test ./...

# Rust
cargo test
```

### Start Development Server

```bash
# React/Vite
npm run dev

# Django
python manage.py runserver 0.0.0.0:8000

# Flask
flask run --host=0.0.0.0

# Go
go run main.go
```

## Customization

### Adding More Tools

Edit `Dockerfile` and add your required packages:

```dockerfile
# Add system packages
RUN apt-get update && apt-get install -y your-package

# Add Node.js global packages
RUN npm install -g your-package

# Add Python packages
RUN pip install your-package
```

Then rebuild:
```bash
docker-compose build --no-cache
```

### Modifying Ports

Edit `docker-compose.yml` ports section:
```yaml
ports:
  - "HOST_PORT:CONTAINER_PORT"
```

### Resource Limits

Uncomment and modify the deploy section in `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 8G
```

## Troubleshooting

### Docker Permission Issues (Linux)

If you get permission errors:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Port Already in Use

Change the host port in docker-compose.yml:
```yaml
ports:
  - "3001:3000"  # Use 3001 on host instead of 3000
```

### Container Won't Start

Check logs:
```bash
docker-compose logs dev
```

### Reset Everything

```bash
# Stop and remove containers
docker-compose down -v

# Remove image
docker rmi claude-dev-env:latest

# Rebuild
./setup.sh
```

## File Structure

```
.
├── Dockerfile              # Main Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── setup.sh               # Automated setup script
├── workspace/             # Your project files (mounted)
└── README.md             # This file
```

## Contributing

Feel free to submit issues and pull requests to improve this development environment.

## License

MIT License - feel free to use and modify as needed.

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [Anthropic API Documentation](https://docs.anthropic.com/)
