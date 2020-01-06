#!/bin/bash

addtohistory() {
  local name="$1" history="$2" limit="${3:-666}" tmpf

  if [[ -f $history ]]; then

    tmpf="$(mktemp)"

    awk -v limit="${limit}" -v name="$name" '
      BEGIN {a[name]=1 ; print name}
      !a[$0]++ && limit > ++i {print}
    ' "$history" > "$tmpf"

    mv -f "$tmpf" "$history"
  else
    echo "$name" > "$history"
  fi
}
