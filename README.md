# Claude Code Docker Environment

**Minimal, isolated Docker environment for Claude Code development** - secure, reproducible, and portable.

> **🚀 First time? See [QUICKSTART.md](QUICKSTART.md) for automated setup!**

## Purpose

This project provides a lightweight, containerized development environment specifically designed for Claude Code:

- **Isolation:** Run Claude Code in a sandboxed container, separate from your host system
- **Portability:** Identical environment across any machine - Linux, macOS, or Windows
- **Minimal:** Only essential tools (Node.js, Git, Claude Code) - small image size (~777MB)
- **Secure:** Non-root user, controlled permissions, no host system modification
- **Reproducible:** Version-controlled environment definition

**Use cases:**
- Safely experiment with Claude Code without affecting your main system
- Consistent development environment across team members
- Quick setup on new machines or cloud instances
- Learning and testing Claude Code features in isolation

## What's Included

**Essential Tools:**
- **Claude Code CLI** - Latest version, pre-installed
- **Node.js 20 (LTS)** - Required for Claude Code, includes npm
- **Git** - Version control
- **Zsh + Oh-My-Zsh** - Enhanced shell experience
- **Basic utilities:** vim, curl, wget, jq, unzip

**Not included (by design):**
- Language runtimes (Python, Go, Rust, etc.) - install per project if needed
- Database clients - add to Dockerfile if needed
- Heavy IDEs or frameworks - keeps image minimal

## Quick Start

### Automated Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/docker-claude-env.git
cd docker-claude-env

# Run setup script (installs Docker if needed, builds image)
./setup.sh
```

The setup script:
1. Installs Docker (if not present)
2. Configures user UID/GID matching (prevents permission issues)
3. Builds the Docker image
4. Provides next steps

### Manual Setup

```bash
# Build image (optional: configure .env for UID/GID matching)
docker build -t claude-dev-env:latest .

# Or use docker-compose
docker-compose build
```

## Usage Options

### Option 1: Docker Compose (Recommended)

**Start the environment:**
```bash
docker-compose up -d           # Start container in background
docker-compose exec dev zsh    # Enter the container
```

**Stop:**
```bash
docker-compose down            # Stop and remove container
```

### Option 2: Direct Docker Run

```bash
docker run -it --rm \
  -v $(pwd)/workspace:/workspace \
  -p 3000:3000 \
  claude-dev-env:latest
```

### Option 3: Using Make Commands

```bash
make shell     # Enter container (starts if needed)
make start     # Start container in background
make stop      # Stop container
make restart   # Restart container
make logs      # View container logs
make clean     # Remove container and volumes
```

## First-Time Setup

After entering the container, authenticate with Claude Code:

```bash
claude login
```

Your credentials persist in the `dev-home` volume - only needed once.

## Configuration

### File Permissions (Important!)

The container user must match your host UID/GID to avoid permission issues with mounted volumes.

**Automatic (via setup.sh):**
```bash
./setup.sh  # Detects and configures automatically
```

**Manual:**
```bash
# Check your UID/GID
id  # Example output: uid=1002(yourname) gid=1003(yourgroup)

# Create .env file
cat > .env <<EOF
USERNAME=yourname
USER_UID=1002
USER_GID=1003
EOF

# Build with custom user
docker-compose build
```

### Exposed Ports

Default ports (modify in `docker-compose.yml`):
- `3000` - Node.js development servers (React, Next.js, etc.)
- `4200` - Angular
- `5000` - Flask, general HTTP
- `5173` - Vite
- `8000` - Django, FastAPI
- `8080` - General HTTP
- `8888` - Jupyter
- `9000` - Custom

### Volume Mounts

**Default mounts (docker-compose.yml):**
- `./workspace` → `/workspace` - Your project files
- `dev-home` volume → `/home/[user]` - Persistent home directory (configs, Claude Code auth)

**Optional mounts (uncomment in docker-compose.yml):**
- `~/.ssh` → `/home/[user]/.ssh` - SSH keys for git
- `~/.gitconfig` → `/home/[user]/.gitconfig` - Git settings

## Customization

### Adding Tools

Edit `Dockerfile` to add project-specific dependencies:

```dockerfile
# Example: Add Python
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Example: Add Go
ENV GO_VERSION=1.22.0
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
```

Then rebuild:
```bash
docker-compose build --no-cache
```

### Changing Ports

Edit `docker-compose.yml`:
```yaml
ports:
  - "3001:3000"  # Use different host port
```

### Resource Limits

Uncomment in `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G
```

## Project Structure

```
.
├── Dockerfile              # Minimal environment definition
├── docker-compose.yml      # Container orchestration
├── setup.sh               # Automated setup script
├── verify.sh              # Environment verification
├── .env.example           # User configuration template
├── workspace/             # Your projects go here (mounted)
├── README.md             # This file
└── QUICKSTART.md         # Quick start guide
```

## Troubleshooting

**Permission denied (Docker socket):**
```bash
sudo usermod -aG docker $USER
newgrp docker  # Or log out/in
```

**Port already in use:**
```bash
# Edit docker-compose.yml and change host port
ports:
  - "3001:3000"  # Instead of 3000:3000
```

**Container won't start:**
```bash
docker-compose logs dev  # Check logs
docker-compose down -v   # Reset everything
./setup.sh              # Rebuild
```

**File permission issues:**
Ensure UID/GID matches (see Configuration section above).

**Need to reset completely:**
```bash
make clean              # Remove container and volumes
docker rmi claude-dev-env:latest  # Remove image
./setup.sh             # Fresh build
```

## Verification

Test your setup:
```bash
./verify.sh
```

Checks:
- Docker installation and running
- Image built successfully
- Container can start
- Claude Code CLI accessible
- Volume mounting working
- Port forwarding working

## Design Decisions

**Why minimal?**
- Faster builds and container startup
- Smaller attack surface
- Lower disk usage
- Easier to understand and maintain
- Add only what you need per project

**Why Docker?**
- Complete isolation from host
- Reproducible across machines
- Easy to destroy/recreate
- No host system modification
- Portable environment definition

**Why non-root user?**
- Security best practice
- Matches typical development workflows
- Prevents accidental system modifications

## Resources

- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [Docker Documentation](https://docs.docker.com/)
- [Anthropic API Documentation](https://docs.anthropic.com/)

## License

MIT License - See LICENSE file for details.

## Contributing

Issues and pull requests welcome! Please ensure:
- Changes maintain minimal image philosophy
- Documentation is updated
- Setup script works on major platforms (Ubuntu, Debian, macOS)
