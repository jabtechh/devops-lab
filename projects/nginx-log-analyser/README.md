# Nginx Log Analyser

This project is a solution for the roadmap.sh Nginx Log Analyser project.

Project URL:
https://roadmap.sh/projects/nginx-log-analyser

## Description

A simple shell script that analyzes an Nginx access log file and shows:

- Top 5 IP addresses with the most requests
- Top 5 most requested paths
- Top 5 response status codes
- Top 5 user agents

## Usage

```bash
chmod +x nginx-log-analyser.sh
./nginx-log-analyser.sh nginx-access.log
