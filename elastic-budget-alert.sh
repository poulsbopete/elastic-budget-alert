#!/bin/bash

# Load variables from .env file
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "❌ .env file not found!"
  exit 1
fi

# API call to Elastic Cloud
response=$(curl -s -H "Authorization: ApiKey $API_KEY" \
  "https://api.elastic-cloud.com/api/v1/billing/costs/organizations/$ORG_ID")

# Parse the cost
current_cost=$(echo "$response" | jq -r '.current_month.total_cost')

# Error handling
if [[ "$current_cost" == "null" || -z "$current_cost" ]]; then
  echo "❌ Failed to fetch current cost. Full response:"
  echo "$response"
  exit 1
fi

# Threshold math
threshold=$(echo "$MAX_BUDGET * 0.8" | bc)

# Output
echo "📊 Current Cost: \$$current_cost"
echo "🎯 Alert Threshold (80%): \$$threshold"

# Alert
if (( $(echo "$current_cost >= $threshold" | bc -l) )); then
  echo "🚨 Warning: You are within 20% of your monthly budget!"
else
  echo "✅ Spending is below alert threshold."
fi