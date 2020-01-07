#!/bin/bash

# store path to all files in array '_files'
# if it doesn't already exist
# separet with null char -d ''
allfiles() {
  [[ -z ${_files[0]} ]] && {
    declare -ga _files
    
    readarray -t -d '' _files  \
      < <(find "$LINKLORD_LINKS_DIR" \
               -mindepth 1     \
               -not -name ".*" \
               -type f         \
               -print0         \
         )
  }        
}
