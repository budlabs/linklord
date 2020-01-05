appendlinks() {

  local trgpath="$*" trgfile tdir regex linklist

  [[ ! $trgpath =~ ^/ ]] && trgpath="$PWD/$trgpath"
  trgfile="${trgpath##*/}"

  rm -f "$_reportfile"
  linklist="$(getlinks "$trgpath")" 

  [[ -f "$_reportfile" ]] && ERM "$(< "$_reportfile")"
  
  [[ -n $linklist ]] && tdir="$(mktemp -d)" && (
    cd "$tdir" || ERX could not create temp dir
    cp "$trgpath" .

    regex="$(printf '/[[]%s[]]: #/' "$_spliton")"
    csplit "$trgfile" "$regex" > /dev/null 2>&1 \
      && mv -f xx00 "$trgfile"

    {
     echo "$(< "$trgfile")"
     printf '\n[%s]: #\n%s' "$_spliton" "$linklist"
    } > "$trgpath"
    
    rm -rf "$tdir"  
  )
}
