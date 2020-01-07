#!/bin/bash

linkaction() {
  local url title printformat choice hstr

  title="${1#$_prefixlink}"
  url="$(geturl "$title")"

  printformat="${__o[exec]:-${__o[print]:-}}"

  [[ -z $printformat ]] && {

    [[ -f $_actionfile ]] \
      || { echo "print %u" > "$_actionfile" ;}

    choice="$(
      {
        [[ -f "$_history_actions" ]] && cat "$_history_actions"
        cat "$_actionfile"
      } | awk '!a[$0]++' | "${_menu_action[@]}"
    )"

    [[ -z $choice ]] && ERX no action selected

    addtohistory "$choice" "$_history_actions"
    __o["${choice%% *}"]=1
    printformat="${choice#* }"

  }

  hstr="$(printf '[%s]: %s' "$title" "$url")"
  addtohistory "$hstr" "$_history_links" "$_history_size"

  printformat="${printformat//%u/$url}"
  printformat="${printformat//%t/$title}"

  if  [[ -n ${__o[exec]} ]]; then
    eval "${printformat}"
  elif [[ -n ${__o[print]} ]]; then
    echo "$printformat"
  fi
}