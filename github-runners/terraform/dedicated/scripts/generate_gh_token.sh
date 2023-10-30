#!/bin/bash

# GitHub repository and access token
repo="owner/repo"
token="YOUR_GITHUB_TOKEN"

# API endpoint
url="https://api.github.com/repos/$repo/actions/runners/registration-token"

# Send POST request to get the registration token
response=$(curl -X POST -H "Authorization: token $token" -s "$url")

# Extract the token value from the response
runner_token=$(echo "$response" | jq -r '.token')

# Export the token as an environment variable
echo "export RUNNER_TOKEN=$runner_token" >> $GITHUB_ENV

# Set the runner token as an environment variable
export RUNNER_TOKEN="$runner_token"

# Store the token as a secret in GitHub Actions
gh secret set RUNNER_TOKEN -r "$repo" -b "$runner_token"
