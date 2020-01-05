#!/usr/bin/env bash

createconf() {
local trgdir="$1"
declare -a aconfdirs

aconfdirs=(
)

mkdir -p "$1" "${aconfdirs[@]}"

cat << 'EOCONF' > "$trgdir/.settings"
_spliton="linklord was here"
_illegaltitlechars="[]<'"
_prefixlink=" " 
_prefixfile=" " 
_prefixfolder=" "
EOCONF

cat << 'EOCONF' > "$trgdir/.actions"
print %u
clipboard %u
clipboard [%t]
exec browser %u
clipboard %t
EOCONF

cat << 'EOCONF' > "$trgdir/budlabs"
[budlabs github]: https://github.com/budlabs
[budlabs youtube channel]: https://youtube.com/c/dubbeltumme
EOCONF

}
