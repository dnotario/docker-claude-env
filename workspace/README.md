# Workspace Directory

This directory is mounted into the Docker container at `/workspace`.

## What is this?

Any files you create here are accessible both:
- **Inside the container** at `/workspace/`
- **Outside the container** in this directory

This makes it easy to:
- Edit files with your host IDE (VS Code, etc.)
- Run code inside the isolated container
- Keep your work persistent across container restarts

## Getting Started

### 1. Enter the Container

```bash
# From the project root
cd ..
make shell

# Or
docker-compose exec dev zsh
```

### 2. You're Now Inside the Container!

```bash
# You start in /workspace
pwd  # Shows: /workspace

# All your tools are available
node --version
python3 --version
go version
rustc --version
claude --version
```

### 3. Create a Project

```bash
# Node.js project
mkdir my-app && cd my-app
npm init -y
npm install express

# Python project
mkdir my-python-app && cd my-python-app
python3 -m venv venv
source venv/bin/activate
pip install requests

# Go project
mkdir my-go-app && cd my-go-app
go mod init myapp

# Rust project
cargo new my-rust-app
cd my-rust-app
```

### 4. Use Claude Code

```bash
# First time only - authenticate
claude login

# Start coding with Claude
claude

# Or run specific commands
claude "help me write a REST API"
```

## Example Projects

Check the `examples/` directory for starter templates:

- `examples/node-express/` - Simple Express.js API
- `examples/python-flask/` - Flask web app
- `examples/go-api/` - Go REST API
- `examples/rust-cli/` - Rust command-line tool

Copy any example to get started:

```bash
cp -r examples/node-express my-new-project
cd my-new-project
npm install
```

## File Permissions

Files created inside the container will have the same owner as your host user (if you configured UID/GID during setup).

If you encounter permission issues:
- Check your `.env` file in the project root
- Rebuild with: `make rebuild`

## Tips

1. **Version Control**: Initialize git repos here
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

2. **Port Forwarding**: Expose your app on container ports
   - Already mapped: 3000, 5000, 8000, 8080, 8888
   - Edit `docker-compose.yml` to add more

3. **Environment Variables**: Create `.env` files for your projects
   ```bash
   echo "DATABASE_URL=postgres://..." > .env
   ```

4. **Install Dependencies**: Use package managers as normal
   ```bash
   npm install
   pip install -r requirements.txt
   go get
   cargo build
   ```

## Cleaning Up

Files in this directory persist even when you:
- Stop the container
- Rebuild the image
- Restart your machine

To clean up:
```bash
# Remove project folders you don't need
rm -rf old-project/

# Or start fresh
rm -rf *
```

## Need Help?

- See the main [README.md](../README.md) for full documentation
- Run `claude` inside the container for AI assistance
- Check `examples/` for starter code

Happy coding!
