# Claude Development Environment
# Optimized for Claude Code CLI with isolation
FROM ubuntu:22.04 AS base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Set up locale (combined in single layer)
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install system dependencies in optimized layers
# Layer 1: Core build tools and essential utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Development tools and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    vim \
    nano \
    zsh \
    tmux \
    htop \
    jq \
    unzip \
    zip \
    tree \
    fd-find \
    ripgrep \
    netcat \
    iputils-ping \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Layer 3: Database clients and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    mysql-client \
    sqlite3 \
    python3-dev \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS version) - separate layer for better caching
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g npm@latest yarn pnpm

# Install Go - use latest stable version
ENV GO_VERSION=1.22.0
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    mkdir -p /go/bin

ENV PATH=/usr/local/go/bin:/go/bin:$PATH
ENV GOPATH=/go

# Skip Rust installation for root user to save space
# Rust will be installed for the dev user below

# Install Python tools - separate layer for better caching
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
    pipenv \
    poetry \
    virtualenv \
    black \
    flake8 \
    pylint \
    pytest \
    ipython \
    jupyter \
    requests

# Install Docker CLI (for docker-in-docker scenarios) - optimized
RUN mkdir -p /usr/share/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI and common frontend tools in one layer
RUN npm install -g \
    @anthropic-ai/claude-code \
    typescript \
    ts-node \
    vite \
    webpack \
    webpack-cli \
    eslint \
    prettier \
    create-react-app \
    @vue/cli \
    @angular/cli \
    && npm cache clean --force

# Setup working directory
WORKDIR /workspace

# Configure git to be safe with mounted volumes
RUN git config --global --add safe.directory '*'

# Install oh-my-zsh for better terminal experience
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
RUN chsh -s $(which zsh)

# Set zsh as default shell
ENV SHELL=/bin/zsh

# Create a non-root user (optional but recommended)
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh && \
    apt-get update && \
    apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Install oh-my-zsh for the non-root user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set up Rust for non-root user (minimal install without docs to save space)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
ENV PATH="/home/$USERNAME/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Expose common development ports
EXPOSE 3000 4200 5000 5173 8000 8080 8888 9000

CMD ["/bin/zsh"]
