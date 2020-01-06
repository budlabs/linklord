getlinks() {

  local targetfile="$1"
  
  allfiles

  awk -v reportfile="$_reportfile" -v targetfile="$targetfile" -F "[][]" '

    # first line not yaml start
    FNR == 1 && FILENAME == targetfile && $0 !~ /^---$/ {dashcount=2}
    /^---$/     {dashcount++}
    /^```|~~~/ {codeblock++}
    
    NF == 3 && dashcount < 1 {links[$2]=$0}

    /./ && dashcount > 1 && codeblock%2 == 0  {

      # ignore inline code
      gsub(/`[^`]+`/,"")

      # ignore image links
      gsub(/![[][^]]+[]]]/,"")
      for (i=2;i<NF;i+=2) {

        # dont include referenced
        if ($(i+1) ~ /^:/)
          delete found[$i]

        # dont include direct url []() or ref []:
        # dont bother with links not in the database
        else if (($(i+1) ~ /^\s*[^(]/ || !$(i-1)) ) {
          # [][] - $(i+1) is nothing
          # NF-1 != i to not include block at end of line
          # ![] - image, previous block ends with !
          if (!(!$(i+1) && (NF-1) != i) && $(i-1) !~ /!$/)
            name = gensub(/^.*[/]/,"",1,FILENAME)
            if ($i in links) {
              printf("%s: %s: %s\n",name, "ADDED", $i) > reportfile
              found[$i]=links[$i]
            }  else {
              printf("%s: %s: %s\n",name, "NO URL", $i) > reportfile
            }
        }
      }
    }
    END { for (k in found) {print found[k]} }
  ' "${_files[@]}" "$1"
}
