# Log Archive Tool

This project is a solution for the roadmap.sh Log Archive Tool challenge.

Project URL:  
https://roadmap.sh/projects/log-archive-tool

---

## Description

This is a Bash CLI tool that archives logs from a specified directory by compressing them into a `.tar.gz` file with a timestamp.

The tool helps manage log files by reducing disk usage while preserving logs for future reference.

---

## Features

- Accepts a log directory as input
- Compresses logs into `.tar.gz`
- Uses timestamped archive filenames
- Stores archives in a separate directory
- Logs archive operations with date and time

---

## Usage

Make the script executable:

```bash
chmod +x log-archive.sh
