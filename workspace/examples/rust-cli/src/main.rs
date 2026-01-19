use clap::{Parser, Subcommand};
use serde::{Deserialize, Serialize};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Say hello to someone
    Hello {
        /// Name of the person to greet
        name: String,

        /// Number of times to greet
        #[arg(short, long, default_value_t = 1)]
        count: u8,
    },
    /// Show system information
    Info,
    /// Echo JSON data
    Echo {
        /// JSON string to echo
        data: String,
    },
}

#[derive(Serialize, Deserialize)]
struct Message {
    message: String,
    timestamp: String,
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Hello { name, count } => {
            for _ in 0..count {
                println!("Hello, {}!", name);
            }
        }
        Commands::Info => {
            let info = Message {
                message: "Rust CLI Starter".to_string(),
                timestamp: chrono::Local::now().to_rfc3339(),
            };
            println!("{}", serde_json::to_string_pretty(&info).unwrap());
        }
        Commands::Echo { data } => {
            match serde_json::from_str::<serde_json::Value>(&data) {
                Ok(json) => {
                    println!("{}", serde_json::to_string_pretty(&json).unwrap());
                }
                Err(e) => {
                    eprintln!("Error parsing JSON: {}", e);
                    std::process::exit(1);
                }
            }
        }
    }
}
