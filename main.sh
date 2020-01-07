#!/usr/bin/env bash

main(){

  _menu_browse=(dmenu -p "select link: ")
  _menu_action=(dmenu -p "select action: ")
  _menu_add_title=(dmenu -p "title for url: ")
  _menu_add_category=(dmenu -p "store in category: ")
  _find_options=(-maxdepth 1 -mindepth 1 -not -name ".*")

  [[ -n "${__o[dir]}" ]] && LINKLORD_DIR="${__o[dir]}"
  [[ -d $LINKLORD_DIR ]] || createconf "$LINKLORD_DIR"
  [[ -n "${__o[settings]}" ]] && LINKLORD_SETTINGS="${__o[settings]}"
  [[ -f $LINKLORD_SETTINGS ]] && . "$LINKLORD_SETTINGS"

  : "${_history_links:="$LINKLORD_DIR/.history-l"}"
  : "${_history_actions:="$LINKLORD_DIR/.history-a"}"
  : "${_history_categories="$LINKLORD_DIR/.history-c"}"
  : "${_history_size:=10}"
  : "${_reportfile:="$LINKLORD_DIR/.log"}"
  : "${_actionfile:="$LINKLORD_DIR/.actions"}"
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
    listlinks "$LINKLORD_DIR"
  fi

}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud



main "${@}"                                     #bashbud
