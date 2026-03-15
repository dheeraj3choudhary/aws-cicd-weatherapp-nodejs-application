#!/bin/bash
set -e

echo "Fetching API key from Parameter Store..."
AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
WEATHER_API_KEY=$(aws ssm get-parameter --name /weather-app/api-key --with-decryption --query Parameter.Value --output text --region $AWS_REGION)

echo "Starting weather-app container..."
docker run -d \
  --name weather-app \
  --restart always \
  -p 3000:3000 \
  -e WEATHER_API_KEY=$WEATHER_API_KEY \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/weather-app:latest

echo "Container started successfully"