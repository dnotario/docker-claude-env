# Rust CLI Starter

Simple Rust command-line application starter template.

## Setup

```bash
# Build will download dependencies automatically
cargo build
```

## Run

```bash
# Run directly
cargo run -- hello World

# Or build and run binary
cargo build --release
./target/release/rust-cli-starter hello World
```

## Commands

```bash
# Say hello
cargo run -- hello Alice
cargo run -- hello Bob --count 3

# Show info
cargo run -- info

# Echo JSON
cargo run -- echo '{"test": "data"}'
```

## Features

- Command-line parsing with clap
- JSON serialization with serde
- Subcommands
- Error handling

## Next Steps

- Add configuration file support (config crate)
- Add logging (env_logger, tracing)
- Add async support (tokio)
- Add HTTP client (reqwest)
- Add database support (sqlx, diesel)
- Add tests (built-in testing)
- Add CI/CD
