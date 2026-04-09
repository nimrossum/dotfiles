#!/usr/bin/env bash
parse_git() {
  if ! command -v git >/dev/null 2>&1; then
    return
  fi
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
      echo "@$branch"
    fi
  fi
}

parse_pr() {
  if ! command -v gh >/dev/null 2>&1; then
    return
  fi
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local pr
    pr=$(gh pr view --json number --jq '.number' 2>/dev/null)
    if [ -n "$pr" ]; then
      echo "#${pr}"
    else
      echo "#-"
    fi
  fi
}

parse_git_status() {
  if ! command -v git >/dev/null 2>&1; then
    return
  fi
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi

  local dirty untracked ahead behind counts behind_count ahead_count out
  dirty=""
  untracked=""
  ahead=""
  behind=""

  if ! git diff --quiet --ignore-submodules --cached 2>/dev/null || \
     ! git diff --quiet --ignore-submodules 2>/dev/null; then
    dirty="*"
  fi

  if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
    untracked="?"
  fi

  if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
    counts=$(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
    behind_count=${counts%%[[:space:]]*}
    ahead_count=${counts##*[[:space:]]}

    if [[ ! "$ahead_count" =~ ^[0-9]+$ ]]; then
      ahead_count=0
    fi
    if [[ ! "$behind_count" =~ ^[0-9]+$ ]]; then
      behind_count=0
    fi

    if [ "${ahead_count:-0}" -gt 0 ]; then
      ahead="↑${ahead_count}"
    fi
    if [ "${behind_count:-0}" -gt 0 ]; then
      behind="↓${behind_count}"
    fi
  fi

  out="${dirty}${untracked}${ahead}${behind}"
  if [ -n "$out" ]; then
    echo "$out"
  else
    echo "clean"
  fi
}

parse_repo_line() {
  if ! command -v git >/dev/null 2>&1; then
    return
  fi
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch pr repo_state
    branch=$(parse_git)
    pr=$(parse_pr)
    repo_state=$(parse_git_status)
    echo " ${branch} ${pr} ${repo_state}"
  fi
}
