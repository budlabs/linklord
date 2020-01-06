#!/usr/bin/env bash

verifytitle() {
  local title="$1" url="$2" file="$3"

  # test non accepted characters
  [[ -n $_char_blacklist && $title =~ ([${_char_blacklist}]) ]] && {
    echo "'${BASH_REMATCH[1]}' in $title, illegal character "
    return 1
  }

  allfiles
  # same title can be entered in any number of files
  # but only once in each file. A title can only be used for one url
  awk  -v title="$title" -v url="$url" -v file="$file" -F "[][]" '
    $2 == title {
      currenturl   = gensub("^." $2 ".:[[:space:]]*","",1,$0)
      currenttitle = $2
      msg=""
      
      if (currenturl != url) {
        msg = sprintf("%s is used for: %s in %s",
                      title, currenturl, FILENAME)
      } else if (FILENAME == file) {
        msg = FILENAME
      }

      if (msg != "") {
        print msg
        exit
      }
    }
  ' "${_files[@]}"
}
