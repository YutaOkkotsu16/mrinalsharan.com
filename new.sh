#!/usr/bin/env bash
# Create a new draft post.
#   ./new.sh notes   "Post title"
#   ./new.sh journal "Post title"
set -euo pipefail
cd "$(dirname "$0")"

usage() { echo 'usage: ./new.sh notes|journal "Post title"' >&2; exit 1; }
[[ $# -eq 2 ]] || usage
section=$1 title=$2
[[ $section == notes || $section == journal ]] || usage
[[ -n ${title// } ]] || usage

date=$(date +%Y-%m-%d)
slug=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' | cut -c1-60 | sed -E 's/-+$//')
[[ -n $slug ]] || { echo "title has no usable characters for a URL slug" >&2; exit 1; }

dir="$section/$date-$slug"
[[ ! -e $dir ]] || { echo "already exists: $dir" >&2; exit 1; }
mkdir -p "$dir"

# Escape for a double-quoted YAML string.
yaml_title=$(printf '%s' "$title" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

cat > "$dir/index.qmd" <<POST
---
title: "$yaml_title"
description: ""  # one sentence; used in listings, link previews and ./share.sh
date: $date
categories: []
draft: true
---

Write here.
POST

echo "created $dir/index.qmd"
echo "preview:  quarto preview $dir/index.qmd"
