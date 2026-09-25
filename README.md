# Bank Server Log Analyzer

A modular POSIX shell script designed to parse, analyze, and extract security, transaction, and operational metrics from bank server log files.

## Features

* **Interactive CLI Menu:** Fast navigation across individual analytical tasks or batch execution.
* **Security & Auth Auditing:**
  * Detects failed login attempts and flags potential brute-force sources ($\ge 3$ failures per IP).
  * Tracks user login/logout events and calculates exact session active durations (`HH:MM:SS`).
* **Database & Query Analytics:**
  * Categorizes SQL statements (`SELECT`, `INSERT`, `UPDATE`, `DELETE`).
  * Isolates slow query warnings and identifies the triggering user and execution time.
* **Financial Transaction Tracking:**
  * Counts deposits, withdrawals, declines, and rollbacks.
  * Calculates gross deposit and withdrawal volumes using `bc` arithmetic.
* **System Health & Forensics:**
  * Surfaces timestamped `[CRITICAL]` severity messages.
  * Filters and isolates individual user audit trails.
  * Generates an events-per-hour activity profile across the operating day.
  * Aggregates general log metrics, log levels, and pinpoints the busiest system module.

## Project Structure

```text
.
├── log_analyzer.sh      # Main shell script
├── data/
│   └── bank_server.log  # Input log file
└── README.md
```

## Requirements

* POSIX-compliant shell (`/bin/sh` or `/bin/bash`)
* Standard Unix command-line utilities: `grep`, `awk`, `sed`, `cut`, `sort`, `uniq`, `tr`, `wc`, `date`, `bc`

## Usage

1. **Make the script executable:**
   ```bash
   chmod +x log_analyzer.sh
   ```

2. **Verify data placement:**  
   Ensure the target log file exists at `data/bank_server.log` (or modify the `datafile` variable inside the script to match your custom path).

3. **Run the script:**
   ```bash
   ./log_analyzer.sh
   ```

## Menu Options

| Option | Task | Description |
| :---: | :--- | :--- |
| `1` | **Failed Login Report** | Summarizes failed logins, frequencies by user/IP, and brute-force suspects. |
| `2` | **Query Activity Summary** | Breaks down total database queries by command type. |
| `3` | **Slow Query Detector** | Extracts slow query alerts, responsible users, and runtimes. |
| `4` | **Transaction Report** | Aggregates transaction counts, declines, rollbacks, and total funds moved. |
| `5` | **Critical Events Report** | Filters and formats all critical severity alerts with timestamps. |
| `6` | **User Activity Report** | Prompts for a username and prints all matching log records. |
| `7` | **Login/Logout Session Report** | Pairs session IDs to compute exact duration between sign-in and sign-out. |
| `8` | **Events-per-Hour Report** | Generates hourly distribution frequency for server traffic analysis. |
| `9` | **General Log Summary** | Overview of total lines, counts by log level, and busiest subsystem. |
| `10` | **Run All Reports** | Sequentially executes reports 1 through 9. |
| `0` | **Exit** | Terminates the script interface. |