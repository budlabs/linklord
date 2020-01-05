#!/bin/bash


allfiles() {
  declare -ga _files
  # store path to all files in array 'files'
  # separet with null char -d ''
  readarray -t -d '' _files < <(find "$LINKLORD_DIR" \
                                     -mindepth 1     \
                                     -not -name ".*" \
                                     -type f         \
                                     -print0         \
                               )
}
