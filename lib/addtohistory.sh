#!/bin/bash

addtohistory() {
  local name tmpf

  tmpf="$(mktemp)"

  name="$1"

  if [[ -f $_history ]]; then
  
    awk -v name="$name" '
      BEGIN {a[name]=1 ; print name}
      !a[$0]++
    ' "${_history:-}" > "$tmpf"

    mv -f "$tmpf" "$_history"
  else
    echo "$name" > "$_history"
  fi
}
