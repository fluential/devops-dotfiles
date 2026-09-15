#!/bin/bash

# ==============================================================================
# CLAUDE CODE WITH DEEPSEEK 4.1 FLASH LAUNCHER
# ==============================================================================
# This script sets the required environment variables to route Anthropic's 
# Claude Code CLI tool through the DeepSeek API using their Anthropic-compatible 
# endpoint wrapper.
# ==============================================================================

# 1. Provide your DeepSeek API Key here
# NOTE: Replace 'your_actual_key_here' with your real DeepSeek API key.
# Alternatively, leave this blank if you already export DEEPSEEK_API_KEY in your shell.
DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY:-your_actual_key_here}"

# 2. Safety check: Ensure the API key is not empty or using the placeholder
if [ -z "$DEEPSEEK_API_KEY" ] || [ "$DEEPSEEK_API_KEY" == "your_actual_key_here" ]; then
    echo "❌ Error: DeepSeek API Key is missing!"
    echo "Please edit this script and replace 'your_actual_key_here' with your real key."
    exit 1
fi

# 3. Export Anthropic-compatible routing variables for this session
export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_API_KEY"

# 4. Bind both the main agent and sub-agents to DeepSeek 4.1 Flash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_MODEL=deepseek-flash[1m]
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-flash[1m]
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-flash[1m]
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-flash
export CLAUDE_CODE_EFFORT_LEVEL=max
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=786432



# 5. Print a quick status message
echo "🚀 Routing Claude Code through DeepSeek V4.1 Flash..."
echo "📍 API Base: $ANTHROPIC_BASE_URL"
echo "🤖 Active Model: $ANTHROPIC_MODEL"
echo "--------------------------------------------------------"

# 6. Launch Claude Code (passes along any arguments you give the script)
claude "$@"

