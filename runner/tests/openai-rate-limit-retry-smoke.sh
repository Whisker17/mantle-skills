#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_BIN="$TMP_DIR/fake-bin"
mkdir -p "$FAKE_BIN"

cat >"$FAKE_BIN/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
STATE_FILE="${TEST_STATE_FILE:?}"
count=0
if [[ -f "$STATE_FILE" ]]; then
  count=$(cat "$STATE_FILE")
fi
count=$((count + 1))
printf '%s' "$count" >"$STATE_FILE"

if [[ "$count" == "1" ]]; then
  echo "curl: (22) The requested URL returned error: 429" >&2
  exit 22
fi

cat <<'JSON'
{"output_text":"ok"}
JSON
EOF
chmod +x "$FAKE_BIN/curl"

STATE_FILE="$TMP_DIR/state.txt"
OUTPUT_FILE="$TMP_DIR/out.json"

# Load run.sh functions without executing main.
RUNNER_LIB="$TMP_DIR/run-lib.sh"
sed '/^main "\$@"$/d' "$REPO_ROOT/runner/run.sh" >"$RUNNER_LIB"
# shellcheck disable=SC1090
source "$RUNNER_LIB"

PATH="$FAKE_BIN:$PATH" \
TEST_STATE_FILE="$STATE_FILE" \
OPENAI_API_KEY="test-key" \
api_request "openai" "responses" '{"input":[]}' >"$OUTPUT_FILE"

if [[ "$(cat "$STATE_FILE")" -lt 2 ]]; then
  echo "expected at least one retry after an initial rate-limit error" >&2
  exit 1
fi

if ! rg -q '"output_text":"ok"' "$OUTPUT_FILE"; then
  echo "expected successful response payload after retry" >&2
  exit 1
fi

echo "openai rate-limit retry smoke test passed"
