#!/usr/bin/env bash
# =============================================================================
# script/start_tunnel.sh
#
# Starts a Cloudflare Quick Tunnel (trycloudflare.com) for Ollama,
# extracts the public URL, writes it to .env, and optionally pushes
# it to Render via the Render API.
#
# Usage:
#   ./script/start_tunnel.sh
#
# Requirements:
#   - cloudflared installed (https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/)
#   - (Optional) RENDER_API_KEY and RENDER_SERVICE_ID env vars set to auto-push URL
# =============================================================================

set -euo pipefail

OLLAMA_PORT="${OLLAMA_PORT:-11434}"
LOG_FILE="/tmp/cloudflared_tunnel.log"
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env"

echo "🚀 Starting Cloudflare Quick Tunnel → localhost:${OLLAMA_PORT}"
echo "   Log: ${LOG_FILE}"

# Kill any existing cloudflared process
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 1

# Start cloudflared in background, capture output to log
cloudflared tunnel --url "http://localhost:${OLLAMA_PORT}" \
  --http-host-header localhost \
  --no-autoupdate \
  2>&1 | tee "${LOG_FILE}" &

CF_PID=$!
echo "   cloudflared PID: ${CF_PID}"

# Wait for the URL to appear in logs (up to 30 seconds)
echo "⏳ Waiting for tunnel URL..."
TUNNEL_URL=""
for i in $(seq 1 30); do
  TUNNEL_URL=$(grep -oP 'https://[a-z0-9\-]+\.trycloudflare\.com' "${LOG_FILE}" 2>/dev/null | head -1 || true)
  if [[ -n "${TUNNEL_URL}" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "${TUNNEL_URL}" ]]; then
  echo "❌ Failed to get tunnel URL after 30 seconds. Check ${LOG_FILE}"
  exit 1
fi

echo ""
echo "✅ Tunnel is LIVE!"
echo "   Public URL: ${TUNNEL_URL}"
echo ""

# ── Update local .env ──────────────────────────────────────────────────────
if [[ -f "${ENV_FILE}" ]]; then
  # Remove old OLLAMA_URL line if present
  grep -v '^OLLAMA_URL=' "${ENV_FILE}" > "${ENV_FILE}.tmp" && mv "${ENV_FILE}.tmp" "${ENV_FILE}"
fi
echo "OLLAMA_URL=${TUNNEL_URL}" >> "${ENV_FILE}"
echo "📝 Updated .env → OLLAMA_URL=${TUNNEL_URL}"

# ── Push to Render (optional) ──────────────────────────────────────────────
if [[ -n "${RENDER_API_KEY:-}" && -n "${RENDER_SERVICE_ID:-}" ]]; then
  echo "☁️  Pushing OLLAMA_URL to Render..."
  HTTP_STATUS=$(curl -s -o /tmp/render_response.json -w "%{http_code}" \
    -X PUT "https://api.render.com/v1/services/${RENDER_SERVICE_ID}/env-vars" \
    -H "Authorization: Bearer ${RENDER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "[{\"key\":\"OLLAMA_URL\",\"value\":\"${TUNNEL_URL}\"}]")

  if [[ "${HTTP_STATUS}" == "200" ]]; then
    echo "✅ Render updated — service will redeploy automatically."
  else
    echo "⚠️  Render update failed (HTTP ${HTTP_STATUS}):"
    cat /tmp/render_response.json
    echo ""
    echo "   Manually set OLLAMA_URL=${TUNNEL_URL} in Render dashboard."
  fi
else
  echo ""
  echo "──────────────────────────────────────────────────────────────────"
  echo "  ACTION REQUIRED: Set this in Render Dashboard → Environment"
  echo ""
  echo "    OLLAMA_URL = ${TUNNEL_URL}"
  echo ""
  echo "  Or set RENDER_API_KEY and RENDER_SERVICE_ID in your shell to"
  echo "  have this script push the URL automatically."
  echo "──────────────────────────────────────────────────────────────────"
fi

echo ""
echo "📌 Tunnel will stay alive in the background (PID: ${CF_PID})"
echo "   To stop: pkill -f 'cloudflared tunnel'"
echo "   To view logs: tail -f ${LOG_FILE}"
echo ""

# Keep script alive so the user can see output; cloudflared runs in bg
wait ${CF_PID}
