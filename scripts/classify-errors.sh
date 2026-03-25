#!/usr/bin/env bash
# Error Classification Script — NIST 800-53 CM-6, CM-7
# Classifies nix flake check / nixos-rebuild output into severity buckets.
#
# Usage:
#   nix flake check 2>&1 | ./scripts/classify-errors.sh
#   ./scripts/classify-errors.sh build.log

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m'

classify_error() {
  local line="$1"

  if echo "$line" | grep -qE "error: builder failed|syntax error|not found|undefined variable|attribute.*missing|does not exist"; then
    printf '%sCRITICAL: %s%s\n' "$RED" "$line" "$NC"
    return 1
  elif echo "$line" | grep -qE "cross-compilation|incompatible systems|warning:|deprecated|experimental"; then
    printf '%sEXPECTED: %s%s\n' "$YELLOW" "$line" "$NC"
    return 0
  elif echo "$line" | grep -qE "configuration|setting|option"; then
    printf '%sCONFIG:   %s%s\n' "$BLUE" "$line" "$NC"
    return 0
  elif echo "$line" | grep -qE "slow|optimization|performance|memory|disk space"; then
    printf '%sWARNING:  %s%s\n' "$ORANGE" "$line" "$NC"
    return 0
  else
    printf '%sINFO:     %s%s\n' "$GREEN" "$line" "$NC"
    return 0
  fi
}

main() {
  local input="${1:-/dev/stdin}"
  local total=0 critical=0

  echo "Classifying errors..."
  echo "========================================"

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    total=$((total + 1))
    classify_error "$line" || critical=$((critical + 1))
  done < "$input"

  echo ""
  echo "Summary: $total lines, $critical critical"

  if [ "$critical" -gt 0 ]; then
    printf '%s%d critical errors — immediate action required%s\n' "$RED" "$critical" "$NC"
    exit 1
  else
    printf '%sNo critical errors%s\n' "$GREEN" "$NC"
    exit 0
  fi
}

main "$@"
