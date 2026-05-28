#!/usr/bin/env bash
set -euo pipefail

LITELLM_BASE="http://litellm.thing.vserver.wg0.maxhbr.local/v1"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <model> [additional mini args...]"
    echo ""
    echo "Available models from litellm proxy:"
    curl -s "$LITELLM_BASE/models" | jq -r '.data[].id' | sort -u | sed 's/^/  /'
    exit 1
fi

MODEL="$1"
shift

# Validate model exists on the proxy
MODELS=$(curl -s "$LITELLM_BASE/models" | jq -r '.data[].id')
if ! echo "$MODELS" | grep -qx "$MODEL"; then
    echo "ERROR: Model '$MODEL' not found on litellm proxy."
    echo ""
    echo "Available models:"
    echo "$MODELS" | sort -u | sed 's/^/  /'
    exit 1
fi

echo "Starting mini-swe-agent with model: $MODEL"

exec env MSWEA_CONFIGURED=true OPENAI_API_KEY=dummy nix run .# -- \
    -m "openai/$MODEL" \
    -c mini.yaml \
    -c "model.model_kwargs.api_base=$LITELLM_BASE" \
    -c "model.cost_tracking=ignore_errors" \
    "$@"
