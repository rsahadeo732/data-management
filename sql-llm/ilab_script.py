#!/usr/bin/env python3
import os
import sys
import csv
import subprocess
import getpass
from io import StringIO

def read_query_from_stdin() -> str:
    # Read everything until EOF (Ctrl+D)
    return sys.stdin.read().strip()

def validate_select_only(q: str) -> None:
    q_stripped = q.strip().lstrip("(").strip()
    q_upper = q_stripped.upper()
    if not (q_upper.startswith("SELECT") or q_upper.startswith("WITH")):
        raise ValueError("Only SELECT (or WITH ... SELECT) queries are allowed.")

def run_psql_csv(query: str, host: str, user: str, db: str) -> str:
    # Use psql's CSV output so we can parse/pretty-print ourselves.
    cmd = [
        "psql",
        "-h", host,
        "-U", user,
        "-d", db,
        "-v", "ON_ERROR_STOP=1",
        "-P", "pager=off",
        "--csv",
        "-c", query
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        # Show psql's stderr (includes auth errors, syntax errors, etc.)
        raise RuntimeError(result.stderr.strip() or "psql command failed.")
    return result.stdout

def format_table(headers, rows) -> str:
    # Compute column widths
    widths = [len(h) for h in headers]
    for r in rows:
        for i, cell in enumerate(r):
            widths[i] = max(widths[i], len(cell))

    def line(sep_char="-"):
        return "+" + "+".join(sep_char * (w + 2) for w in widths) + "+"

    def fmt_row(r):
        return "| " + " | ".join(str(r[i]).ljust(widths[i]) for i in range(len(headers))) + " |"

    out = []
    out.append(line("-"))
    out.append(fmt_row(headers))
    out.append(line("-"))
    for r in rows:
        out.append(fmt_row(r))
    out.append(line("-"))
    out.append(f"({len(rows)} rows)")
    return "\n".join(out)

def main():
    # Defaults (works for most Rutgers iLab setups)
    host = os.getenv("ILAB_DB_HOST", "postgres.cs.rutgers.edu")
    user = os.getenv("ILAB_DB_USER", getpass.getuser())
    db   = os.getenv("ILAB_DB_NAME", user)

    # 1) Get query either from argv[1] or stdin (extra credit behavior)
    if len(sys.argv) >= 2:
        query = sys.argv[1].strip()
    else:
        # Read from stdin until EOF (Ctrl+D)
        query = read_query_from_stdin()

    if not query:
        print("ERROR: No query provided.\n")
        print("Usage:")
        print("  python3 ilab_script.py \"SELECT 1;\"")
        print("  echo \"SELECT 1;\" | python3 ilab_script.py")
        sys.exit(1)

    # 2) Enforce SELECT-only
    try:
        validate_select_only(query)
    except ValueError as e:
        print(f"ERROR: {e}")
        sys.exit(2)

    # 3) Run and parse CSV output
    try:
        csv_text = run_psql_csv(query, host=host, user=user, db=db)
    except Exception as e:
        print(f"ERROR running query: {e}")
        sys.exit(3)

    # 4) Parse CSV into headers + rows
    reader = csv.reader(StringIO(csv_text))
    parsed = list(reader)

    if not parsed:
        print("(0 rows)")
        return

    headers = parsed[0]
    rows = parsed[1:]

    # Convert None-ish / empty to empty strings for printing
    clean_rows = []
    for r in rows:
        clean_rows.append([("" if c is None else str(c)) for c in r])

    print(format_table(headers, clean_rows))

if __name__ == "__main__":
    main()
