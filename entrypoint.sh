#!/bin/bash
set -e

# Use environment variables with defaults
BROKER_URI="${N8N_RUNNERS_TASK_BROKER_URI:-http://n8n:5679}"
AUTH_TOKEN="${N8N_RUNNERS_AUTH_TOKEN}"

if [ -z "$AUTH_TOKEN" ]; then
  echo "Error: N8N_RUNNERS_AUTH_TOKEN not set"
  exit 1
fi

# Start n8n as a task runner
exec n8n start --runner --task-broker-uri "$BROKER_URI" --auth-token "$AUTH_TOKEN"
