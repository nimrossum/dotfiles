#!/usr/bin/env bash
parse_pr() {
  if ! command -v gh >/dev/null 2>&1; then
    return
  fi
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local pr
    pr=$(gh pr view --json number --jq '.number' 2>/dev/null)
    if [ -n "$pr" ]; then
      echo " PR#$pr"
    fi
  fi
}
