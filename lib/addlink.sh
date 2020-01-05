#!/bin/bash

addlink() {
  local trg msg
  local url="$1"
  local title="${__o[title]:-}"
  local category="${__o[category]:-}"

  : "${title:=$(menu --prompt "title for $url: " \
                     ${__o[filter]:+--options} \
                     "${__o[filter]:+-filter "'${__o[filter]}'"}" \
                     --layout titlebar 
               )}"

  [[ -z $title ]] || : "${category:=$(
    find "$LINKLORD_DIR" "${_find_options_all[@]}" -type f \
    | sed "s;${LINKLORD_DIR}/;;g" \
    | menu --prompt "category for $title: " --layout window
           
  )}"

  dunstify -C 123454
  [[ -z $category || -z $title ]] && ERX no category

  trg="${LINKLORD_DIR}/$category"

  assert="$(verifytitle "$title" "$url" "$trg")"
  if [[ $assert = "$trg" ]]; then
    ERM "$title already exist in $category"
  elif [[ -n $assert ]]; then
    dunstify -r 123454 -u critical "$assert"
    addurl "$url" --category "$category"
    exit
  else
    mkdir -p "${trg%/*}"

    printf '[%s]: %s\n' "$title" "$url" >> "$trg"

    msg="$(printf 'added url: %s\nas %s in %s\n' \
                  "$url" "$title" "$category"
          )"

    ERM "$msg"
  fi
}
