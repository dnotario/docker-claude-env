# Quick Start - New Machine Setup

Set up the Claude Development Environment on any new machine with one script.

## Prerequisites

- A fresh Linux or macOS machine
- Internet connection
- That's it! (Docker will be installed automatically)

## One-Line Setup

```bash
curl -fsSL https://raw.githubusercontent.com/dnotario/docker-claude-env/main/setup.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/dnotario/docker-claude-env.git
cd docker-claude-env
./setup.sh
```

## What the Setup Script Does

1. ✅ Detects your operating system (Linux/macOS)
2. ✅ Installs Docker if not present
3. ✅ Configures container user to match your host UID/GID (prevents permission issues)
4. ✅ Builds the Docker image with all tools pre-installed
5. ✅ Sets up docker-compose configuration

**Build time:** 5-10 minutes (only needed once)

## Start Working

After setup completes:

```bash
# Enter the development environment
make shell

# Or using docker-compose
docker-compose exec dev zsh
```

## First Time in Container

Authenticate with Claude Code:

```bash
claude login
```

Your credentials are saved in a Docker volume, so you only need to do this once.

## Your Workspace

Put your projects in the `workspace/` directory:

```bash
cd docker-claude-env/workspace
# Your files here are accessible both inside and outside the container
```

## Common Commands

```bash
make help      # Show all available commands
make shell     # Enter the container
make restart   # Restart the environment
make logs      # View container logs
make clean     # Remove everything and start fresh
```

## What's Included

**Languages & Runtimes:**
- Node.js 20 (npm, yarn, pnpm)
- Python 3 (pip, pipenv, poetry)
- Go 1.22
- Rust (latest)

**Tools:**
- Claude Code CLI
- Docker & Docker Compose
- Git & Git LFS
- TypeScript, ESLint, Prettier
- pytest, black, flake8
- And much more!

**Development Tools:**
- vim, nano
- zsh with oh-my-zsh
- tmux, htop
- jq, ripgrep, fd

## Supported Platforms

- ✅ Ubuntu / Debian
- ✅ Fedora / RHEL / CentOS
- ✅ Arch / Manjaro
- ✅ macOS (with Homebrew)

## Troubleshooting

**"Docker not found"**
- The setup script installs Docker automatically
- On Linux, you may need to log out and back in after installation

**"Permission denied"**
- Run: `newgrp docker`
- Or log out and back in

**"Port already in use"**
- Edit `docker-compose.yml` and change the host port
- Example: `"3001:3000"` instead of `"3000:3000"`

## Need Help?

See the full [README.md](README.md) for detailed documentation.

---

**That's it!** Clone, run setup.sh, start coding with Claude.
