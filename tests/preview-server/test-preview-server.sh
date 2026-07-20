#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
PORT=18765
SERVER_LOG="${TEST_ROOT}/server.log"
SERVER_PID=""

cleanup() {
    if [[ -n "${SERVER_PID}" ]] && kill -0 "${SERVER_PID}" 2>/dev/null; then
        kill "${SERVER_PID}" 2>/dev/null || true
        wait "${SERVER_PID}" 2>/dev/null || true
    fi
    rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

OUTPUT="${TEST_ROOT}/website"

mkdir -p \
    "${OUTPUT}/pages" \
    "${OUTPUT}/sections" \
    "${OUTPUT}/components" \
    "${OUTPUT}/assets" \
    "${OUTPUT}/styles" \
    "${OUTPUT}/scripts" \
    "${OUTPUT}/config"

cat > "${OUTPUT}/manifest.json" <<'JSON'
{
  "website": "preview-server-test",
  "pages": "pages",
  "sections": "sections",
  "components": "components",
  "assets": "assets",
  "styles": "styles",
  "scripts": "scripts",
  "config": "config"
}
JSON

cat > "${OUTPUT}/index.html" <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Preview Server Test</title>
</head>
<body>
  <h1>Preview Server Test</h1>
</body>
</html>
HTML

"${PROJECT_ROOT}/core/preview-server/engine/start-preview-server.sh" \
    "${OUTPUT}" \
    "127.0.0.1" \
    "${PORT}" \
    >"${SERVER_LOG}" 2>&1 &

SERVER_PID=$!

for _ in {1..30}; do
    if curl -fsS "http://127.0.0.1:${PORT}/index.html" >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done

curl -fsS "http://127.0.0.1:${PORT}/index.html" \
    | grep -q "Preview Server Test"

echo "PASS: Preview server HTTP response"

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "FAIL: Preview server stopped unexpectedly"
    cat "${SERVER_LOG}"
    exit 1
fi

echo "PASS: Preview server lifecycle"

kill "${SERVER_PID}"
wait "${SERVER_PID}" 2>/dev/null || true
SERVER_PID=""

echo "PASS: Preview server shutdown"

echo
echo "PASS: Local Preview Server"
