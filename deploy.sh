#!/usr/bin/env bash
# Load schema.sql into Railway Postgres.
#
# This script does nothing until you run it.
#
#   railway login
#   ./deploy.sh
#
# Requires the Railway CLI, psql, and python3.
#
# If this directory is not linked to a Railway project, the script creates one
# named pipF26-thursday-app-demo. Override the name with RAILWAY_PROJECT_NAME.
# If project creation asks for a workspace, set RAILWAY_WORKSPACE to the
# workspace name or id and run the script again.
#
# Re-running drops and reloads students, tools, student_tools,
# availability_slots, and student_availability.

set -euo pipefail

cd "$(dirname "$0")"

project_name="${RAILWAY_PROJECT_NAME:-pipF26-thursday-app-demo}"
postgres_service="${RAILWAY_POSTGRES_SERVICE:-}"

if ! command -v railway >/dev/null 2>&1; then
  echo "railway CLI is not on PATH. Install it, then run: railway login" >&2
  exit 1
fi
if ! command -v psql >/dev/null 2>&1; then
  echo "psql is not on PATH." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is not on PATH." >&2
  exit 1
fi
if [[ ! -f schema.sql ]]; then
  echo "schema.sql is missing from $(pwd)" >&2
  exit 1
fi

if ! railway whoami >/dev/null 2>&1; then
  echo "Not logged in to Railway. Run: railway login" >&2
  exit 1
fi

if ! railway status --json >/dev/null 2>&1; then
  echo "Linking a new Railway project: ${project_name}"
  if [[ -n "${RAILWAY_WORKSPACE:-}" ]]; then
    railway init --name "$project_name" --workspace "$RAILWAY_WORKSPACE" --json >/dev/null
  else
    railway init --name "$project_name" --json >/dev/null
  fi
fi

find_postgres_service() {
  railway service list --json | python3 -c '
import json, sys
raw = sys.stdin.read().strip()
data = json.loads(raw) if raw else []
if isinstance(data, dict):
    data = data.get("services") or data.get("edges") or []
names = []
for item in data:
    if isinstance(item, dict) and item.get("name"):
        names.append(item["name"])
for name in names:
    if name.lower() == "postgres":
        print(name)
        break
else:
    for name in names:
        if "postgres" in name.lower():
            print(name)
            break
'
}

if [[ -z "$postgres_service" ]]; then
  postgres_service="$(find_postgres_service)"
fi

if [[ -z "$postgres_service" ]]; then
  echo "Adding Postgres to the linked Railway project"
  railway add --database postgres --json >/dev/null
  postgres_service="$(find_postgres_service)"
fi

if [[ -z "$postgres_service" ]]; then
  echo "Postgres service was not created. Check the Railway project and rerun." >&2
  exit 1
fi

echo "Waiting for ${postgres_service} to accept connections"

public_url=""
for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
  json=""
  if json="$(railway variable list --service "$postgres_service" --json 2>/dev/null)"; then
    :
  else
    json=""
  fi
  if [[ -n "$json" ]]; then
    public_url="$(
      printf '%s' "$json" | python3 -c '
import json, sys
raw = sys.stdin.read().strip()
url = ""
try:
    data = json.loads(raw) if raw else {}
except json.JSONDecodeError:
    data = {}
if isinstance(data, dict):
    url = data.get("DATABASE_PUBLIC_URL") or data.get("databasePublicUrl") or ""
elif isinstance(data, list):
    for item in data:
        if not isinstance(item, dict):
            continue
        key = item.get("name") or item.get("key") or ""
        if key == "DATABASE_PUBLIC_URL":
            url = item.get("value") or ""
            break
if url:
    sys.stdout.write(url)
'
    )"
  fi
  if [[ -n "$public_url" ]]; then
    if DATABASE_PUBLIC_URL="$public_url" python3 - <<'PY' >/dev/null 2>&1
import os, subprocess, sys
from urllib.parse import parse_qs, unquote, urlparse
url = os.environ["DATABASE_PUBLIC_URL"]
parsed = urlparse(url)
query = parse_qs(parsed.query)
env = os.environ.copy()
env.pop("DATABASE_PUBLIC_URL", None)
env["PGHOST"] = parsed.hostname or ""
env["PGPORT"] = str(parsed.port or 5432)
env["PGUSER"] = unquote(parsed.username or "")
env["PGPASSWORD"] = unquote(parsed.password or "")
env["PGDATABASE"] = parsed.path.lstrip("/")
env["PGSSLMODE"] = (query.get("sslmode") or ["require"])[0]
result = subprocess.run(["psql", "-q", "-c", "SELECT 1"], env=env)
sys.exit(result.returncode)
PY
    then
      break
    fi
  fi
  public_url=""
  sleep 10
done

if [[ -z "$public_url" ]]; then
  echo "Postgres did not become reachable. The service may still be deploying." >&2
  exit 1
fi

echo "Loading schema.sql into ${postgres_service}"
echo "This drops and reloads the five survey tables."

DATABASE_PUBLIC_URL="$public_url" python3 - schema.sql <<'PY'
import os
import subprocess
import sys
from urllib.parse import parse_qs, unquote, urlparse

url = os.environ["DATABASE_PUBLIC_URL"]
schema = sys.argv[1]
parsed = urlparse(url)
query = parse_qs(parsed.query)
env = os.environ.copy()
env.pop("DATABASE_PUBLIC_URL", None)
env["PGHOST"] = parsed.hostname or ""
env["PGPORT"] = str(parsed.port or 5432)
env["PGUSER"] = unquote(parsed.username or "")
env["PGPASSWORD"] = unquote(parsed.password or "")
env["PGDATABASE"] = parsed.path.lstrip("/")
env["PGSSLMODE"] = (query.get("sslmode") or ["require"])[0]

load = subprocess.run(["psql", "-v", "ON_ERROR_STOP=1", "-f", schema], env=env)
if load.returncode != 0:
    sys.exit(load.returncode)

check_sql = """
SELECT students, tools, student_tools, slots, availability, null_working_style
FROM (
    SELECT
        (SELECT count(*) FROM students) AS students,
        (SELECT count(*) FROM tools) AS tools,
        (SELECT count(*) FROM student_tools) AS student_tools,
        (SELECT count(*) FROM availability_slots) AS slots,
        (SELECT count(*) FROM student_availability) AS availability,
        (SELECT count(*) FROM students WHERE working_style IS NULL) AS null_working_style
) counts;
SELECT netid
FROM students
WHERE netid IN ('ks7532', 'yo2162', 'ryf2010', 'N16059079', 'N16141501')
ORDER BY netid;
"""
checked = subprocess.run(
    ["psql", "-q", "-v", "ON_ERROR_STOP=1", "-At", "-F", "|", "-c", check_sql],
    env=env,
    capture_output=True,
    text=True,
)
if checked.returncode != 0:
    sys.stderr.write(checked.stderr)
    sys.exit(checked.returncode)

lines = [line for line in checked.stdout.splitlines() if line]
expected_counts = "23|5|74|6|73|1"
expected_ids = ["N16059079", "N16141501", "ks7532", "ryf2010", "yo2162"]
if not lines or lines[0] != expected_counts or lines[1:] != expected_ids:
    sys.stderr.write("Load finished, but the row checks did not match.\n")
    sys.stderr.write("Got:\n")
    sys.stderr.write("\n".join(lines) + "\n")
    sys.exit(1)

print("students=23 tools=5 student_tools=74 availability_slots=6 student_availability=73 null_working_style=1")
print("netids ok: " + ", ".join(expected_ids))
PY

unset public_url json
echo "Loaded schema.sql"
