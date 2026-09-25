# Bank Server Log Analyzer (`program.sh`)

A POSIX-compliant shell script designed to parse, aggregate, and analyze bank server log files. It offers an interactive menu to generate operational security reports, query statistics, financial transaction summaries, and session tracking metrics.

---

## Authors
* **Wadee Fatafta** (ID: 1250758)
* **Obada Sabbah** (ID: 1240032)

---

## Prerequisites & Dependencies

The script relies on standard Unix/Linux command-line utilities:
* `sh` / `bash`
* `grep`, `awk`, `sed`, `cut`, `sort`, `uniq`, `wc`, `tr`
* `bc` (used for floating-point transaction arithmetic)
* `date` (supports GNU `-d` syntax for session duration calculation)

---

## Log File Setup

By default, the script reads from:
```
data/bank_server.log
```

Ensure the target file exists before running the script. You can create the directory and place your log file there:
```sh
mkdir -p data
# Place your bank_server.log inside ./data/
```

### Expected Log Format
The script parses logs structured with bracketed metadata tags, timestamps, severity levels, modules, session IDs, and descriptive messages:
```text
[2024-05-10 14:22:01] [ERROR] [AUTH] [user1] [192.168.1.10] - failed login attempt
[2024-05-10 14:23:15] [WARNING] [QUERY] [user2] - slow query execution time 3.42s
[2024-05-10 14:25:00] [INFO] [TRANSACTION] [SESSION_101] - deposit $250.00
[2024-05-10 14:26:00] [INFO] [AUTH] [SESSION_101] - successful login
[2024-05-10 14:35:00] [INFO] [AUTH] [SESSION_101] - logged out
```

---

## Usage

1. **Grant execution permissions:**
   ```sh
   chmod +x program.sh
   ```

2. **Run the script:**
   ```sh
   ./program.sh
   ```
   *(Alternatively: `sh program.sh`)*

---

## Menu Options & Tasks

| Option | Report Name | Description |
| :---: | :--- | :--- |
| `1` | **Failed Login Report** | Counts total failed authentication attempts, aggregates frequency per `USER` and `IP`, and identifies potential brute-force sources ($\ge 3$ failed attempts from a single IP). |
| `2` | **Query Activity Summary** | Summarizes database query traffic and breaks down queries by type (`SELECT`, `UPDATE`, `INSERT`, `DELETE`). |
| `3` | **Slow Query Detector** | Filters `[WARNING]` logs flagged as slow and outputs a formatted table of the username and execution time. |
| `4` | **Transaction Report** | Summarizes volume of deposits, withdrawals, declines, and rollbacks, calculating total dollar sums for deposits and withdrawals using `bc`. |
| `5` | **Critical Events Report** | Extracts all `[CRITICAL]` severity messages alongside their event timestamps. |
| `6` | **User Activity Report** | Prompts for a target username and displays all chronological events associated with that user. |
| `7` | **Login/Logout Session Report** | Tracks unique session IDs, pairs corresponding login and logout times, and calculates total session duration (`HH:MM:SS`). |
| `8` | **Events-per-Hour Report** | Generates an hourly event distribution breakdown across the 24-hour log period. |
| `9` | **General Log Summary** | Displays overall log line counts, event distribution across severity levels (`INFO`, `WARNING`, `ERROR`, `CRITICAL`), and identifies the busiest subsystem module (`AUTH`, `QUERY`, `TRANSACTION`, `BACKUP`). |
| `10` | **Run All Reports** | Sequentially executes tasks 1 through 9. |
| `0` | **Exit** | Terminates the interactive loop. |

---

## Implementation Notes

* **Temporary Files:** Each reporting function uses localized `.tmp` scratch files (`failedLogin.tmp`, `sessions.tmp`, etc.) and removes them upon task completion.
* **Non-destructive Operations:** The log file is read-only; no transformations or deletions are applied to the source log file during execution.
