#!/usr/bin/env bash
# Print the live URL plus draft X and LinkedIn posts for a post, ready to edit.
# No network calls: everything comes from the post's front matter and headings.
#   ./share.sh notes/2026-10-26-my-post
set -euo pipefail
cd "$(dirname "$0")"
SITE="https://mrinalsharan.com"

[[ $# -eq 1 ]] || { echo "usage: ./share.sh path/to/post-folder-or-file" >&2; exit 1; }
target=${1%/}
if [[ -d $target ]]; then
  for ext in qmd md ipynb; do [[ -f $target/index.$ext ]] && { file=$target/index.$ext; break; }; done
else
  file=$target
fi
[[ -n ${file:-} && -f $file ]] || { echo "no post found at $1" >&2; exit 1; }

# Pull title, description, draft flag and ## headings. Notebooks: read the markdown cells.
if [[ $file == *.ipynb ]]; then
  text=$(python3 -I -c 'import json,sys
nb=json.load(open(sys.argv[1]))
print("\n".join("".join(c["source"]) for c in nb["cells"] if c["cell_type"] in ("markdown","raw")))' "$file")
else
  text=$(cat "$file")
fi
front=$(printf '%s\n' "$text" | awk 'NR==1 && /^---/ {f=1; next} f && /^---/ {exit} f')
field() { printf '%s\n' "$front" | sed -nE "s/^$1:[[:space:]]*//p" | head -1 | sed -E 's/[[:space:]]+#.*$//; s/^"(.*)"$/\1/; s/^'"'"'(.*)'"'"'$/\1/'; }
title=$(field title)
desc=$(field description)
draft=$(field draft)
# Top-level ## headings only: skip code blocks and ::: divs (callouts have their own ## titles).
headings=$(printf '%s\n' "$text" | awk '
  /^```/ {c = !c; next}
  c {next}
  /^:::+[[:space:]]*$/ {if (d > 0) d--; next}
  /^:::+/ {d++; next}
  d == 0 && /^## / {sub(/^## +/, ""); sub(/ *\{.*\}$/, ""); print}')

dir=$(dirname "$file")
url="$SITE/${dir#./}/"

[[ $draft == true ]] && echo "⚠  draft: true — this post is not live yet. Set draft: false and push first."$'\n'
[[ -z $desc ]] && echo "⚠  no description in front matter; the drafts below will be thin."$'\n'

echo "URL"
echo "$url"
echo
echo "──── X thread (draft) ────"
n=1
echo "$n/ $title"$'\n\n'"$desc"; echo
while IFS= read -r h; do
  [[ -z $h ]] && continue
  [[ $n -ge 4 ]] && break
  n=$((n + 1))
  echo "$n/ $h: [one or two lines on the key point]"; echo
done <<< "$headings"
if [[ $n -eq 1 ]]; then n=2; echo "2/ [the one thing you want people to take away]"; echo; fi
echo "$((n + 1))/ Full write-up: $url"
echo
echo "──── LinkedIn (draft) ────"
echo "$title"
echo
echo "$desc"
if [[ -n $headings ]]; then
  echo; echo "What's in it:"
  printf '%s\n' "$headings" | head -5 | sed 's/^/• /'
fi
echo
echo "Read it here: $url"
