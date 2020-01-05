#!/bin/bash

linkaction() {
  local url title printformat choice
  # <span lang='URL'></span>${_prefixlink}TITLE
  url=$(cut -f2 -d\' <<< "$1")
  title="${1##*>}"
  title="${title#${_prefixlink}}"

  

  printformat="${__o[exec]:-${__o[clipboard]:-${__o[print]:-}}}"

  [[ -z $printformat ]] && {

    [[ -f $_actions ]] || {
      printf '%s\n'            \
             "print %u"        \
             "clipboard %u"    \
             "clipboard [%t]"  \
             "exec browser %u" \
             "clipboard %t"    \
      > "$_actions"
    }
    
    choice="$(cat "$_actions"       \
      | menu  --prompt "action: "   \
              --layout A            \
              --fallback '--layout D --fallback "--layout C"'
    )"

    [[ -z $choice ]] && ERX no action selected
    __o["${choice%% *}"]=1
    printformat="${choice#* }"
  }

  addtohistory "$(printf '[%s]: %s' "$title" "$url")"

  printformat="${printformat//%u/$url}"
  printformat="${printformat//%t/$title}"

  if  [[ -n ${__o[exec]} ]]; then
    eval "${printformat}"
  elif [[ -n ${__o[print]} ]]; then
    echo "$printformat"
  else
    xclip -r -sel c <<< "$printformat"
    xclip -r -sel p <<< "$printformat"
  fi
}
