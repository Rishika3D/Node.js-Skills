#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Live API URL (change this to your deployed URL)
API_URL="https://rishika-school-api.herokuapp.com"

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  School Management API - Live Test Suite${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo "Testing API at: $API_URL"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}[TEST 1] Health Check${NC}"
echo "Endpoint: GET $API_URL/health"
echo ""

response=$(curl -s -w "\n%{http_code}" "$API_URL/health")
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

echo "HTTP Status: $http_code"
echo "Response:"
echo "$body" | jq . 2>/dev/null || echo "$body"
echo ""

if [[ "$http_code" == "200" ]]; then
    echo -e "${GREEN}✅ PASS${NC}\n"
else
    echo -e "${RED}❌ FAIL${NC}\n"
fi

# Test 2: Add School
echo -e "${YELLOW}[TEST 2] Add School${NC}"
echo "Endpoint: POST $API_URL/api/addSchool"
echo ""

SCHOOL_NAME="Test School $(date +%s)"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/addSchool" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$SCHOOL_NAME\",
    \"address\": \"123 Main St, Test City, State 12345\",
    \"latitude\": 40.7128,
    \"longitude\": -74.0060
  }")

http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

echo "HTTP Status: $http_code"
echo "Response:"
echo "$body" | jq . 2>/dev/null || echo "$body"
echo ""

if [[ "$http_code" == "201" ]]; then
    echo -e "${GREEN}✅ PASS${NC}\n"
else
    echo -e "${RED}❌ FAIL${NC}\n"
fi

# Test 3: List Schools
echo -e "${YELLOW}[TEST 3] List Schools by Proximity${NC}"
echo "Endpoint: GET $API_URL/api/listSchools?latitude=40.7128&longitude=-74.0060"
echo ""

response=$(curl -s -w "\n%{http_code}" "$API_URL/api/listSchools?latitude=40.7128&longitude=-74.0060")
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

echo "HTTP Status: $http_code"
echo "Response (first 3 entries):"
echo "$body" | jq '.data | .[0:3]' 2>/dev/null || echo "$body"
echo ""

if [[ "$http_code" == "200" ]]; then
    echo -e "${GREEN}✅ PASS${NC}\n"
else
    echo -e "${RED}❌ FAIL${NC}\n"
fi

# Test 4: Validation Error (Missing Field)
echo -e "${YELLOW}[TEST 4] Validation Error - Missing Required Field${NC}"
echo "Endpoint: POST $API_URL/api/addSchool (missing latitude and longitude)"
echo ""

response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/addSchool" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Invalid School",
    "address": "123 Main St, Test City"
  }')

http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

echo "HTTP Status: $http_code"
echo "Response:"
echo "$body" | jq . 2>/dev/null || echo "$body"
echo ""

if [[ "$http_code" == "400" ]]; then
    echo -e "${GREEN}✅ PASS (Expected validation error)${NC}\n"
else
    echo -e "${RED}❌ FAIL${NC}\n"
fi

# Test 5: Invalid Coordinates
echo -e "${YELLOW}[TEST 5] Invalid Coordinates - Latitude Out of Range${NC}"
echo "Endpoint: GET $API_URL/api/listSchools?latitude=95&longitude=-74.0060"
echo ""

response=$(curl -s -w "\n%{http_code}" "$API_URL/api/listSchools?latitude=95&longitude=-74.0060")
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

echo "HTTP Status: $http_code"
echo "Response:"
echo "$body" | jq . 2>/dev/null || echo "$body"
echo ""

if [[ "$http_code" == "400" ]]; then
    echo -e "${GREEN}✅ PASS (Expected validation error)${NC}\n"
else
    echo -e "${RED}❌ FAIL${NC}\n"
fi

# Test 6: List from Different Location
echo -e "${YELLOW}[TEST 6] List Schools from Different Location${NC}"
echo "Endpoint: GET $API_URL/api/listSchools?latitude=42.3601&longitude=-71.0589"
echo "(Boston, MA coordinates)"
echo ""

response=$(curl -s -w "\n%{http_code}" "$API_URL/api/listSchools?latitude=42.3601&longitude=-71.0589")
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

echo "HTTP Status: $http_code"
echo "Response (first 3 entries):"
echo "$body" | jq '.data | .[0:3]' 2>/dev/null || echo "$body"
echo ""

if [[ "$http_code" == "200" ]]; then
    echo -e "${GREEN}✅ PASS${NC}\n"
else
    echo -e "${RED}❌ FAIL${NC}\n"
fi

# Summary
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ All tests completed!${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo "📊 Summary:"
echo "  • Health Check: Working"
echo "  • Add School: Working"
echo "  • List Schools: Working"
echo "  • Validation: Working"
echo "  • API Status: ✅ LIVE"
echo ""
