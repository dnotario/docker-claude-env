# Claude Code Docker Environment

**Minimal, isolated Docker environment for Claude Code** - secure, reproducible, and portable.

Run Claude Code in a sandboxed container with only essential tools. No host system modification, easy to reset, consistent across machines.

---

## Quick Start

### Three Steps to Start

**1. Clone & Setup**
```bash
git clone https://github.com/dnotario/docker-claude-env.git
cd docker-claude-env
./setup.sh  # Installs Docker if needed, builds image (~5-10 min)
```

**2. Enter Container**
```bash
make shell
# Or: docker-compose exec claude zsh
```

**3. Login to Claude**
```bash
claude login  # Browser auth, credentials persist
claude        # Start coding!
```

**Done!** Your workspace: `./workspace/` (shared with container)

### Common Commands
```bash
make shell     # Enter container
make start     # Start in background
make stop      # Stop container
make restart   # Restart
make logs      # View logs
make clean     # Reset everything
```

---

## Purpose

This provides a lightweight, containerized development environment specifically for Claude Code:

**Benefits:**
- **Isolation** - Sandboxed from host system, safe to experiment
- **Portability** - Identical environment across Linux, macOS, Windows
- **Minimal** - Only essentials (~777MB): Node.js, Git, Claude Code
- **Secure** - Non-root user, controlled permissions
- **Reproducible** - Version-controlled environment definition
- **Disposable** - Easy to destroy and rebuild

**Use Cases:**
- Safe experimentation with Claude Code
- Consistent team development environments
- Quick setup on new machines or cloud instances
- Learning Claude Code in isolation
- CI/CD pipelines

---

## What's Included

**Essential Tools:**
- **Claude Code CLI** - Latest version, pre-installed
- **Node.js 20 (LTS)** - Required for Claude Code, includes npm
- **Git** - Version control
- **Zsh + Oh-My-Zsh** - Enhanced shell
- **Basic utilities** - vim, curl, wget, jq, unzip

**Intentionally Excluded:**
- Language runtimes (Python, Go, Rust) - add per project
- Database clients - add if needed
- Heavy frameworks or build tools - keeps image minimal
- IDEs - use your host IDE with shared workspace

Philosophy: Start minimal, add only what you need.

---

## Usage Options

### Option 1: Docker Compose (Recommended)

```bash
docker-compose up -d              # Start in background
docker-compose exec claude zsh    # Enter container ('claude' is the service name)
docker-compose down               # Stop
```

**Note:** `claude` is the service name defined in `docker-compose.yml`. It's a label that identifies the container configuration, not the username or image name. Docker Compose uses this to know which container to target.

### Option 2: Direct Docker

```bash
docker run -it --rm \
  -v $(pwd)/workspace:/workspace \
  -p 3000:3000 \
  claude-dev-env:latest
```

### Option 3: Make Commands

```bash
make shell     # Enter container (starts if needed)
make start     # Start background
make stop      # Stop
make restart   # Restart
make logs      # View logs
make clean     # Remove everything
make help      # Show all commands
```

---

## Configuration

### File Permissions (Important!)

Container user must match your host UID/GID to avoid permission issues.

**Automatic (recommended):**
```bash
./setup.sh  # Auto-detects and configures
```

**Manual:**
```bash
id  # Check your UID/GID

cat > .env <<EOF
USERNAME=yourname
USER_UID=1002
USER_GID=1003
EOF

docker-compose build
```

### Ports

Default exposed ports (change in `docker-compose.yml`):
- `3000` - Node.js dev servers (React, Next.js)
- `4200` - Angular
- `5000` - Flask
- `5173` - Vite
- `8000` - Django, FastAPI
- `8080` - General HTTP
- `8888` - Jupyter
- `9000` - Custom

### Volumes

**Default mounts:**
- `./workspace` → `/workspace` - Your projects (shared)
- `dev-home` volume → `/home/${USERNAME}` - Configs, Claude auth (persistent)

**Optional (uncomment in docker-compose.yml):**
- `~/.ssh` → `/home/${USERNAME}/.ssh` - SSH keys for git
- `~/.gitconfig` → `/home/${USERNAME}/.gitconfig` - Git config

**Note:** Home directory path uses the `USERNAME` variable from `.env` (defaults to `dev`). This ensures Claude Code auth and configs persist correctly even with custom usernames.

---

## Customization

### Adding Languages/Tools

Edit `Dockerfile`, then rebuild:

**Add Python:**
```dockerfile
RUN apt-get update && apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*
```

**Add Go:**
```dockerfile
ENV GO_VERSION=1.22.0
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH=/usr/local/go/bin:$PATH
```

**Rebuild:**
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

---

## Common Use Cases

### Basic Project
```bash
make shell
cd /workspace
mkdir my-project && cd my-project
npm init -y
claude  # Start coding with Claude
```

### With Custom Tools
```dockerfile
# Edit Dockerfile, add your tools
RUN apt-get update && apt-get install -y python3 python3-pip
```
```bash
docker-compose build
make shell
python3 --version  # Now available
```

### Running Dev Server
```bash
# Inside container
npm run dev  # Usually on port 3000

# Access from host browser
# http://localhost:3000
```

---

## Troubleshooting

**Docker permission denied:**
```bash
sudo usermod -aG docker $USER
newgrp docker  # Or logout/login
```

**Port already in use:**
```bash
# Edit docker-compose.yml
ports:
  - "3001:3000"  # Use different port
```

**Container won't start:**
```bash
docker-compose logs claude  # Check errors
make clean                  # Reset everything
./setup.sh                  # Rebuild
```

**File permission issues:**
```bash
# Ensure UID/GID matches (see Configuration)
./setup.sh  # Or manually configure .env
```

**Complete reset:**
```bash
make clean
docker rmi claude-dev-env:latest
./setup.sh
```

**Verify installation:**
```bash
./verify.sh  # Runs comprehensive checks
```

---

## Platform Support

**Linux:**
- ✅ Ubuntu/Debian (apt)
- ✅ Fedora/RHEL/CentOS (dnf)
- ✅ Arch/Manjaro (pacman)

**macOS:**
- ✅ Requires Homebrew for Docker install
- Docker Desktop handles permissions

**Windows:**
- ✅ WSL2 + Docker Desktop
- Run commands in WSL2 terminal

---

## Project Structure

```
.
├── Dockerfile              # Minimal environment definition
├── docker-compose.yml      # Container orchestration (defines 'claude' service)
├── setup.sh               # Automated setup script
├── verify.sh              # Environment verification
├── Makefile               # Convenience commands
├── .env                   # User config (USERNAME, UID, GID)
├── .env.example           # User config template
├── workspace/             # Your projects (mounted)
└── README.md             # This file
```

**Key concepts:**
- **Service name (`claude`)** - Label in docker-compose.yml used by `docker-compose exec claude zsh`
- **Image name (`claude-dev-env`)** - The Docker image built from Dockerfile
- **Container name (`claude-dev`)** - The running container instance
- **Username** - User inside container (from .env, defaults to `dev`)

---

## Design Philosophy

**Why minimal?**
- Faster builds and startup
- Smaller attack surface
- Lower disk usage
- Easier to understand and maintain
- Add only what you need

**Why Docker?**
- Complete isolation from host
- Reproducible across machines
- Easy to destroy/recreate
- No host system modification
- Portable environment definition

**Why non-root user?**
- Security best practice
- Matches typical workflows
- Prevents accidental system modifications

---

## Advanced

### Docker-in-Docker

To use Docker inside the container, uncomment in `docker-compose.yml`:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Custom Environment Variables

Edit `docker-compose.yml`:
```yaml
environment:
  - MY_VAR=value
  - NODE_ENV=development
```

### Multiple Projects

```bash
# Project A
cd project-a
docker-compose up -d
docker-compose exec claude zsh

# Project B (different container)
cd project-b
docker-compose up -d
docker-compose exec claude zsh
```

---

## Resources

- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [Docker Documentation](https://docs.docker.com/)
- [Anthropic API Documentation](https://docs.anthropic.com/)

---

## Contributing

Issues and pull requests welcome!

**Guidelines:**
- Maintain minimal image philosophy
- Update documentation
- Test on Ubuntu/Debian and macOS
- Keep setup.sh portable

---

## License

MIT License - See LICENSE file for details.
