#!/bin/bash
# Checks git status and unpushed commits across project repos and the CoS system
#
# Configuration:
#   CODE_DIR: directory containing project repos (default: ~/Code)
#   COS_DIR: CoS system directory (default: ~/.claude)

CODE_DIR="${CODE_DIR:-$HOME/Code}"
COS_DIR="${COS_DIR:-$HOME/.claude}"

for dir in "$CODE_DIR"/*/; do
  if [ -d "$dir/.git" ]; then
    echo "=== $(basename "$dir") ==="
    cd "$dir"
    git status --short 2>/dev/null
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    if [ "$ahead" != "" ] && [ "$ahead" != "0" ]; then
      echo "UNPUSHED: $ahead commits ahead"
    fi
    echo "---"
  fi
done

if [ -d "$COS_DIR/.git" ]; then
  echo "=== claude-config ($COS_DIR) ==="
  cd "$COS_DIR"
  git status --short 2>/dev/null
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
  if [ "$ahead" != "" ] && [ "$ahead" != "0" ]; then
    echo "UNPUSHED: $ahead commits ahead"
  fi
fi
