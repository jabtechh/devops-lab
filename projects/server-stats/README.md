# Server Stats Analyzer (server-stats.sh)

A simple Bash script that analyzes basic Linux server performance stats.

Project URL:  
https://roadmap.sh/projects/server-stats

## What it shows

- Total CPU usage
- Total memory usage (free vs used + percentage)
- Total disk usage (free vs used + percentage)
- Top 5 processes by CPU usage
- Top 5 processes by memory usage

**Optional/extra stats (if enabled in script):**
- OS version
- Uptime / load average
- Logged-in users
- Failed login attempts (best-effort; may require sudo depending on distro)

## Requirements

- Linux environment
- Bash
- Common CLI tools: `ps`, `df`, `free`, `awk`, `uptime` (most are installed by default)

## How to run

From the `server-stats/` directory:

```bash
chmod +x server-stats.sh
./server-stats.sh
