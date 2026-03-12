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
ARGS_FILE="${TEST_ARGS_FILE:?}"
printf '%s\n' "$*" >>"$ARGS_FILE"
cat <<'JSON'
{"choices":[{"message":{"content":"ok"}}]}
JSON
EOF
chmod +x "$FAKE_BIN/curl"

ARGS_FILE="$TMP_DIR/curl-args.log"

# Load run.sh functions without executing main.
RUNNER_LIB="$TMP_DIR/run-lib.sh"
sed '/^main "\$@"$/d' "$REPO_ROOT/runner/run.sh" >"$RUNNER_LIB"
# shellcheck disable=SC1090
source "$RUNNER_LIB"

PATH="$FAKE_BIN:$PATH" \
TEST_ARGS_FILE="$ARGS_FILE" \
OPENROUTER_API_KEY="test-key" \
OPENROUTER_BASE_URL="https://openrouter.ai/api/v1" \
HTTPS_PROXY="http://127.0.0.1:9" \
api_request "openrouter" "chat/completions" '{"messages":[]}' >/dev/null

if ! rg -q -- '--noproxy openrouter.ai' "$ARGS_FILE"; then
  echo "expected openrouter calls to include --noproxy openrouter.ai under local proxy env" >&2
  exit 1
fi

echo "openrouter local proxy bypass smoke test passed"
