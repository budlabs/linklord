#!/bin/bash

listlinks() {
  local cur="$1" trg choice
  local format="${_prefixlink}%s\n"
  # local format="<span lang='%s'></span>%s\n"

  choice="$(
  {
    {
      # list all links ('[TITLE]: URL')
      [[ $cur = "$LINKLORD_DIR" ]] && [[ -f $_history ]] \
        && cat "$_history"
      
      if [[ -f $cur ]]; then
        cat "$cur"
      else
        find "$cur" "${_find_options[@]}" -type f -exec cat '{}' \;
      fi
      # format linklist and remove duplicates with awk
    } | awk -v format="$format" -F "[][]" '
          NF == 3 && !a[$2]++ {
            printf(format, $2)
          }
        '

    # list all files and directories if $cur is a dir
    [[ -d $cur ]] && {
      find "$cur" "${_find_options[@]}" -type f -printf "${_prefixfile}%f\n"
      find "$cur" "${_find_options[@]}" -type d -printf "${_prefixfolder}%f\n"
    }

  } | "${_menu_browse[@]}"
  )"

  [[ -z $choice ]] && ERX nothing selected

  # test if choice has markup, if true, its a link
  if [[ $choice =~ ^${_prefixlink} ]];then
   linkaction "$choice"
  else
    # trim prefix, append trg to cur to get path
    trg="${choice#${_prefixfile}}" trg="${trg#${_prefixfolder}}"
    trg="$cur/$trg"

    # if path is neither a file or directory
    [[ -d $trg || -f $trg ]] || ERX i dont know what "${trg}" is
    
    listlinks "$trg"
  fi
}
