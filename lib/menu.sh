#!/bin/bash

menu() {

  while (($#>0)); do
    case "$1" in
      --prompt|-p  ) prompt="$2" ; shift ;;
      --options|-o ) ropts+=(${2}) ; shift ;;
      * ) opts+=("$1") ;;
    esac
    shift
  done

  ropts+=("${_rofi_options[@]}")

  if   command -v i3menu  > /dev/null 2>&1 ; then
    i3menu --prompt "$prompt"      \
           --option "${ropts[*]}"  \
           "${opts[@]}"
  elif command -v rofi    > /dev/null 2>&1 ; then
    rofi "${ropts[@]}" -dmenu -p "$prompt"
  else
    ERX "no 'rofi' installation found"
  fi
  
}
