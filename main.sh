#!/usr/bin/env bash

main(){

  _history="$LINKLORD_DIR/.history"
  _reportfile="$LINKLORD_DIR/.log"
  _settings="$LINKLORD_DIR/.settings"
  _actions="$LINKLORD_DIR/.actions"

  [[ -d $LINKLORD_DIR ]] || createconf "$LINKLORD_DIR"
  [[ -f $_settings ]] && . "$_settings"

  : "${_spliton:="linklord was here"}"
  : "${_illegaltitlechars:="[]<'"}"
  : "${_prefixlink:=" " }"
  : "${_prefixfile:=" " }"
  : "${_prefixfolder:=" "}"
  
  _rofi_options=(-i -markup-rows)
  _find_options=(-maxdepth 1 -mindepth 1 -not -name ".*")

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
