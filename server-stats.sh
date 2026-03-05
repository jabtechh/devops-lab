#!/usr/bin/env bash
set -euo pipefail

# ---------- helpers ----------
hr() { printf '%*s\n' "${COLUMNS:-60}" '' | tr ' ' '-'; }

have() { command -v "$1" >/dev/null 2>&1; }

# CPU usage from /proc/stat:
# Read two samples and compute utilization = 1 - (idle_delta / total_delta)
cpu_usage() {
  local cpu user nice system idle iowait irq softirq steal guest guest_nice
  read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  local idle1=$((idle + iowait))
  local total1=$((user + nice + system + idle + iowait + irq + softirq + steal))

  sleep 1

  read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  local idle2=$((idle + iowait))
  local total2=$((user + nice + system + idle + iowait + irq + softirq + steal))

  local idle_delta=$((idle2 - idle1))
  local total_delta=$((total2 - total1))

  if (( total_delta == 0 )); then
    echo "N/A"
    return
  fi

  awk -v idle="$idle_delta" -v total="$total_delta" 'BEGIN {
    usage = (1 - idle/total) * 100
    printf "%.2f%%\n", usage
  }'
}

memory_usage() {
  # free output is widely available
  if have free; then
    # Use "Mem:" line. total used free shared buff/cache available
    local total used free
    read -r total used free < <(free -m | awk '/^Mem:/ {print $2, $3, $4}')
    local pct
    pct=$(awk -v used="$used" -v total="$total" 'BEGIN { printf "%.2f", (used/total)*100 }')
    echo "Total: ${total}MB | Used: ${used}MB (${pct}%) | Free: ${free}MB"
  else
    echo "free command not found"
  fi
}

disk_usage() {
  # Show root filesystem usage; also show all local filesystems as extra.
  if have df; then
    echo "Root filesystem (/):"
    df -hP / | awk 'NR==1{print "  " $0} NR==2{print "  " $0}'
    echo
    echo "All mounted filesystems:"
    df -hP | awk 'NR==1{print "  " $0} NR>1{print "  " $0}'
  else
    echo "df command not found"
  fi
}

top_processes() {
  local sort_key="$1"   # %cpu or %mem
  local title="$2"

  if have ps; then
    echo "$title"
    # -e: all processes, -o: custom columns, --sort: sort desc by key
    # head -n 6 => header + top 5
    ps -eo pid,comm,%cpu,%mem --sort="-$sort_key" | head -n 6 | awk '{print "  " $0}'
  else
    echo "ps command not found"
  fi
}

os_info() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "${PRETTY_NAME:-Unknown OS}"
  else
    uname -a
  fi
}

uptime_load() {
  if have uptime; then
    uptime
  else
    # fallback: /proc/uptime and /proc/loadavg
    local up secs mins hours days
    up=$(awk '{print int($1)}' /proc/uptime)
    days=$((up/86400)); up=$((up%86400))
    hours=$((up/3600)); up=$((up%3600))
    mins=$((up/60)); secs=$((up%60))
    echo "uptime: ${days}d ${hours}h ${mins}m ${secs}s | loadavg: $(cat /proc/loadavg)"
  fi
}

logged_in_users() {
  if have who; then
    who | awk '{print "  " $0}'
  else
    echo "who command not found"
  fi
}

failed_logins() {
  # This varies by distro and logging system.
  # Try common locations; if journalctl exists, use it as another fallback.
  local count="N/A"

  if [[ -f /var/log/auth.log ]]; then
    count=$(grep -i "failed password" /var/log/auth.log 2>/dev/null | wc -l | tr -d ' ')
  elif [[ -f /var/log/secure ]]; then
    count=$(grep -i "failed password" /var/log/secure 2>/dev/null | wc -l | tr -d ' ')
  elif have journalctl; then
    # sshd failures in systemd journal (best-effort)
    count=$(journalctl -u ssh --no-pager 2>/dev/null | grep -i "failed password" | wc -l | tr -d ' ')
  fi

  echo "$count"
}

# ---------- main ----------
echo "Server Performance Stats Report"
hr
echo "Host: $(hostname 2>/dev/null || echo "unknown")"
echo "OS: $(os_info)"
echo "Kernel: $(uname -r 2>/dev/null || echo "unknown")"
echo "Time: $(date)"
hr

echo "Total CPU Usage: $(cpu_usage)"
echo "Total Memory Usage: $(memory_usage)"
hr

echo "Disk Usage:"
disk_usage
hr

top_processes "%cpu" "Top 5 processes by CPU usage:"
echo
top_processes "%mem" "Top 5 processes by Memory usage:"
hr

echo "Uptime / Load:"
uptime_load
hr

echo "Logged-in users:"
logged_in_users
hr

echo "Failed login attempts (best-effort): $(failed_logins)"
hr
