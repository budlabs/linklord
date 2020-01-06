#!/usr/bin/env bash

createconf() {
local trgdir="$1"
declare -a aconfdirs

aconfdirs=(
)

mkdir -p "$1" "${aconfdirs[@]}"

cat << 'EOCONF' > "$trgdir/.settings"
#!/bin/bash

_reportfile="$LINKLORD_DIR/.log"
_actionfile="$LINKLORD_DIR/.actions"
_historyfile="$LINKLORD_DIR/.history"
_history_size=5
_spliton="linklord was here"
_char_blacklist="[]<'"
_prefixlink=" " 
_prefixfile=" " 
_prefixfolder=" "
_menu_browse=(dmenu -p "select link: ")
_menu_action=(dmenu -p "select action: ")
_menu_add_title=(dmenu -p "title for url: ")
_menu_add_category=(dmenu -p "store in category: ")

# shellcheck disable=SC2034
EOCONF

cat << 'EOCONF' > "$trgdir/.actions"
print %t - %u
exec browser %u
EOCONF

cat << 'EOCONF' > "$trgdir/budlabs"
[budlabs github]: https://github.com/budlabs
[budlabs youtube channel]: https://youtube.com/c/dubbeltumme
EOCONF

}
