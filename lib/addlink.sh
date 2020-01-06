#!/bin/bash

addlink() {
  local trg str dunstifyis
  local url="$1"
  local title="${__o[title]:-}"
  local category="${__o[category]:-}"

  : "${title:=$(echo -n | "${_menu_add_title[@]}")}"

  [[ -z $title ]] || : "${category:=$(
    {
      allfiles
      [[ -f "$_history_categories" ]] && cat "$_history_categories"
      printf '%s\n' "${_files[@]}" | sed "s;${LINKLORD_DIR}/;;g"
    } | awk '!a[$0]++' | "${_menu_add_category[@]}"
           
  )}"

  # close Error message from previous add link if
  # dunstifyis (installed)
  [[ ${dunstifyis:=$(command -v dunstify)} ]] \
    && dunstify -C 123454

  [[ -z $category || -z $title ]] && ERX add link canceled

  addtohistory "$category" "$_history_categories"
  # addtohistory
  trg="${LINKLORD_DIR}/$category"

  assert="$(verifytitle "$title" "$url" "$trg")"
  if [[ $assert = "$trg" ]]; then
    ERM "$title already exist in $category"

  elif [[ -n $assert ]]; then

    if [[ $dunstifyis ]]; then
      dunstify -r 123454 -u critical "$assert"
    else
      notify-send -u critical "$assert"
    fi

    addlink "$url" --category "$category"
    exit
  else

    mkdir -p "${trg%/*}"

    str="$(printf '[%s]: %s' "$title" "$url")"

    echo "$str" >> "$trg"

    ((__o["add-to-history"] == 1)) \
      && addtohistory "$str" "$_history_links" "$_history_size"

    ERM "$(printf 'added url: %s\nas %s in %s\n' \
                  "$url" "$title" "$category"
          )"
  fi
}
