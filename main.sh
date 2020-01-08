#!/usr/bin/env bash

main(){


  _menu_browse=(dmenu -p "select link: ")
  _menu_action=(dmenu -p "select action: ")
  _menu_add_title=(dmenu -p "title for url: ")
  _menu_add_category=(dmenu -p "store in category: ")
  _find_options=(-maxdepth 1 -mindepth 1 -not -name ".*")

  [[ -n "${__o[settings-dir]}" ]] \
    && LINKLORD_SETTINGS_DIR="${__o[settings-dir]}"

  [[ -n "${__o[links-dir]}" ]] \
    && LINKLORD_LINKS_DIR="${__o[links-dir]}"
  
  local sd=$LINKLORD_SETTINGS_DIR
  local ld=$LINKLORD_LINKS_DIR

  [[ -d $sd ]] || createconf "$sd"
  [[ -f $sd/settings ]] && . "$sd/settings"

  _history_links="$sd/.history-l"
  _history_categories="$sd/.history-c"
  _reportfile="$sd/.log"
  _actionfile="$sd/actions"

  : "${_history_size:=10}"
  : "${_spliton:="linklord was here"}"
  : "${_char_blacklist:="][<>"}"
  : "${_prefixlink:=" " }"
  : "${_prefixfile:=" " }"
  : "${_prefixfolder:=" "}"

  if [[ -f $* ]]; then
    appendlinks "$*"
  elif [[ -n ${__o[add]} ]]; then
    addlink "${__o[add]}"
  elif [[ -z $* ]]; then
    [[ -d $ld ]] || ERX "$ld doesn't exist"
    listlinks "$ld"
  fi

}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud



main "${@}"                                     #bashbud
