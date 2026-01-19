# Quick Start Guide

Get Claude Code running in Docker in under 10 minutes.

## Prerequisites

- Linux, macOS, or Windows (with WSL2)
- Internet connection
- That's it! Docker will be installed automatically if needed

## Three Steps to Start

### 1. Clone & Setup

```bash
git clone https://github.com/yourusername/docker-claude-env.git
cd docker-claude-env
./setup.sh
```

**What happens:**
- Installs Docker (if needed)
- Configures user permissions automatically
- Builds minimal Claude Code environment (~777MB)
- Takes 5-10 minutes on first run

### 2. Enter the Environment

```bash
make shell
# Or: docker-compose exec dev zsh
```

You're now in an isolated container with Claude Code installed.

### 3. Login to Claude

```bash
claude login
```

Opens browser for authentication. Credentials saved - only needed once.

**Done!** Start using Claude Code:
```bash
claude
```

## Your Workspace

```bash
cd docker-claude-env/workspace/
# Put your projects here - accessible inside and outside container
```

## Essential Commands

```bash
make shell     # Enter container
make start     # Start in background
make stop      # Stop container
make restart   # Restart
make logs      # View logs
make clean     # Reset everything
```

## What's Inside

**Minimal environment:**
- Claude Code CLI (latest)
- Node.js 20 LTS
- Git
- Zsh with Oh-My-Zsh
- Basic utilities (vim, curl, wget, jq)

**Not included (add if needed):**
- Python, Go, Rust
- Database clients
- Heavy frameworks

Keep it minimal, add per-project.

## Common Use Cases

**Simple project:**
```bash
make shell
cd /workspace
mkdir my-project && cd my-project
npm init -y
# Start coding with Claude
claude
```

**With Python:**
```dockerfile
# Edit Dockerfile, add:
RUN apt-get update && apt-get install -y python3 python3-pip
```
```bash
docker-compose build  # Rebuild
make shell           # Use Python
```

**With Go:**
```dockerfile
# Edit Dockerfile, add:
ENV GO_VERSION=1.22.0
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH=/usr/local/go/bin:$PATH
```
```bash
docker-compose build
make shell
```

## Accessing Running Services

Container exposes common dev ports:

```bash
# Start a dev server inside container
npm run dev  # Usually on port 3000

# Access from host browser
# http://localhost:3000
```

**Default ports:** 3000, 4200, 5000, 5173, 8000, 8080, 8888, 9000

Change in `docker-compose.yml` if needed.

## File Permissions

The setup script automatically matches container user to your host user - no permission issues!

**Manual override if needed:**
```bash
# Create .env
cat > .env <<EOF
USERNAME=yourname
USER_UID=$(id -u)
USER_GID=$(id -g)
EOF

docker-compose build
```

## Troubleshooting

**"Permission denied" (Docker):**
```bash
sudo usermod -aG docker $USER
newgrp docker  # Or logout/login
```

**"Port 3000 already in use":**
```bash
# Edit docker-compose.yml
ports:
  - "3001:3000"  # Use different host port
```

**Container won't start:**
```bash
docker-compose logs dev  # Check what's wrong
make clean              # Nuclear option - reset everything
./setup.sh             # Rebuild from scratch
```

**Need to verify setup:**
```bash
./verify.sh  # Runs comprehensive checks
```

## Platform-Specific Notes

**Ubuntu/Debian:**
Works out of the box.

**Fedora/RHEL/CentOS:**
Works with dnf package manager.

**Arch/Manjaro:**
Works with pacman.

**macOS:**
Requires Homebrew for Docker installation.
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
./setup.sh
```

**Windows:**
Use WSL2 + Docker Desktop. Run commands in WSL2 terminal.

## Next Steps

**Read the full README:**
```bash
cat README.md
# Or view on GitHub
```

**Customize your environment:**
Edit `Dockerfile` and `docker-compose.yml` for your needs.

**Start a project:**
```bash
make shell
cd /workspace
# Your projects here
```

**Learn Claude Code:**
```bash
claude --help
claude      # Start interactive session
```

## Architecture Overview

```
Host Machine
│
├─ docker-claude-env/
│  ├─ workspace/           ← Your projects (shared)
│  ├─ Dockerfile           ← Environment definition
│  ├─ docker-compose.yml   ← Container config
│  └─ setup.sh            ← Automated setup
│
└─ Docker Container
   ├─ /workspace           ← Mounted from host
   ├─ /home/[user]        ← Persistent volume (configs, auth)
   └─ Claude Code CLI     ← Pre-installed
```

**Key points:**
- Files in `workspace/` are shared between host and container
- Claude Code auth persists in Docker volume
- Container is isolated - safe to experiment
- Destroy and rebuild anytime with `make clean`

## Why Use This?

**Instead of installing Claude Code directly:**
- ✅ No host system modification
- ✅ Reproducible environment
- ✅ Easy to reset/recreate
- ✅ Team consistency
- ✅ Safe experimentation
- ✅ Version controlled setup

**Trade-offs:**
- Requires Docker (installed automatically)
- Container overhead (minimal)
- Learning curve (basic Docker knowledge helps)

## Support

**Issues?** Check [README.md](README.md) troubleshooting section.

**Questions?** Open an issue on GitHub.

**Want to contribute?** Pull requests welcome!

---

**That's it!** Three commands and you're running Claude Code in Docker. Happy coding! 🚀
