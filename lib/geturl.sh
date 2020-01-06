#!/bin/bash

geturl() {

  local title="$1"

  allfiles

  awk -F "[][]" -v title="$title" '
    $2 == title {
      print(gensub(/^.*[]]:\s*/,"",1,$0))
      exit
    }
  ' "${_files[@]}"
}
