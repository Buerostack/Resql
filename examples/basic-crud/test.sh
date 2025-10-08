#!/bin/bash

# Basic CRUD Operations Test Script
# This script demonstrates all CRUD operations using Resql

set -e

BASE_URL="http://localhost:8080"
AUTH="admin:password"

echo "=== Resql Basic CRUD Example ==="
echo ""

# Create User
echo "1. Creating user..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/example/users/create" \
  -H "Content-Type: application/json" \
  -u "$AUTH" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "status": "active"
  }')

echo "Response: $CREATE_RESPONSE"
USER_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1)
echo "Created user with ID: $USER_ID"
echo ""

# Read User by ID
echo "2. Getting user by ID..."
curl -s "$BASE_URL/example/users/get-by-id?id=$USER_ID" \
  -u "$AUTH" | jq '.'
echo ""

# Find User by Email
echo "3. Finding user by email..."
curl -s -X POST "$BASE_URL/example/users/find-by-email" \
  -H "Content-Type: application/json" \
  -u "$AUTH" \
  -d '{
    "email": "john.doe@example.com"
  }' | jq '.'
echo ""

# Update User
echo "4. Updating user..."
curl -s -X POST "$BASE_URL/example/users/update" \
  -H "Content-Type: application/json" \
  -u "$AUTH" \
  -d "{
    \"id\": $USER_ID,
    \"name\": \"Jane Doe\",
    \"status\": \"inactive\"
  }" | jq '.'
echo ""

# List Users
echo "5. Listing all users..."
curl -s "$BASE_URL/example/users/list?limit=10" \
  -u "$AUTH" | jq '.'
echo ""

# Delete User
echo "6. Deleting user..."
curl -s -X POST "$BASE_URL/example/users/delete" \
  -H "Content-Type: application/json" \
  -u "$AUTH" \
  -d "{
    \"id\": $USER_ID
  }" | jq '.'
echo ""

echo "=== Test Complete ==="
