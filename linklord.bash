#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
linklord - version: 2020.01
updated: 2020-01-04 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${LINKLORD_DIR:=$HOME/tmp/links}"
: "${LINKLORD_SETTINGS:=$LINKLORD_DIR/.settings}"


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

___printhelp(){
  
cat << 'EOB' >&2
linklord - a markdown flavored bookmarks manager


SYNOPSIS
--------
linklord [--dir|-d LINKLORD_DIR] [--print|-p FORMAT]|[--clipboard|-s FORMAT]|[--exec|-x FORMAT]
linklord [--dir|-d LINKLORD_DIR] [--category|-c CATEGORY] [--title|-t TITLE]|[--filter|-f TITLE] --add LINK
linklord [--dir|-d LINKLORD_DIR] MARKDOWN_FILE
linklord --help|-h
linklord --version|-v

OPTIONS
-------

--dir|-d MARKDOWN_FILE  

--print|-p FORMAT  

--clipboard|-s FORMAT  

--exec|-x FORMAT  

--category|-c CATEGORY  

--title|-t TITLE  

--filter|-f TITLE  

--add LINK  

--help|-h  
Show help and exit.


--version|-v  
Show version and exit.
EOB
}


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

addtohistory() {
  local name tmpf

  tmpf="$(mktemp)"

  name="$1"

  if [[ -f $_history ]]; then
  
    awk -v name="$name" '
      BEGIN {a[name]=1 ; print name}
      !a[$0]++
    ' "${_history:-}" > "$tmpf"

    mv -f "$tmpf" "$_history"
  else
    echo "$name" > "$_history"
  fi
}


allfiles() {
  declare -ga _files
  # store path to all files in array 'files'
  # separet with null char -d ''
  readarray -t -d '' _files < <(find "$LINKLORD_DIR" \
                                     -mindepth 1     \
                                     -not -name ".*" \
                                     -type f         \
                                     -print0         \
                               )
}
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
set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERM(){

  local mode

  getopts xr mode
  case "$mode" in
    x ) urg=critical ; prefix='[ERROR]: '   ;;
    r ) urg=low      ; prefix='[WARNING]: ' ;;
    * ) urg=normal   ; mode=m ;;
  esac
  shift $((OPTIND-1))

  msg="${prefix}$*"

  if [[ -t 2 ]]; then
    echo "$msg" >&2
  else
    notify-send -u "$urg" "$msg"
  fi

  [[ $mode = x ]] && exit 77
}

ERX() { ERM -x "$*" ;}
ERR() { ERM -r "$*" ;}
ERH(){
  {
    ___printhelp 
    [[ -n "$*" ]] && printf '\n%s\n' "$*"
  } >&2 
  exit 77
}
getlinks() {

  local targetfile="$1"
  
  allfiles

  awk -v reportfile="$_reportfile" -v targetfile="$targetfile" -F "[][]" '

    # first line not yaml start
    NR == 1 && FILENAME == targetfile && $0 !~ /^---$/ {dashcount=2}
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
        else if (($(i+1) ~ /^\s*[^(]/ || !$(i+1)) ) {
          # [][] - $(i+1) is nothing
          # NF-1 != i to not include block at end of line
          # ![] - image, previous block ends with !
          if (!(!$(i+1) && (NF-1) != i) && $(i-1) !~ /!$/)
            if ($i in links) {
              printf("%-7s: %s\n", "ADDED", $i) > reportfile
              found[$i]=links[$i]
            }  else {
              printf("%-7s: %s\n", "NO URL", $i) > reportfile
            }
        }
      }
    }
    END { for (k in found) {print found[k]} }
  ' "${_files[@]}" "$1"
}

linkaction() {
  local url title printformat choice
  # <span lang='URL'></span>${_prefixlink}TITLE
  url=$(cut -f2 -d\' <<< "$1")
  title="${1##*>}"
  title="${title#${_prefixlink}}"

  addtohistory "$(printf '[%s]: %s' "$title" "$url")"

  printformat="${__o[exec]:-${__o[clipboard]:-${__o[print]:-}}}"

  [[ -z $printformat ]] && {

    [[ -f $_actions ]] || {
      printf '%s\n'            \
             "print %u"        \
             "clipboard %u"    \
             "clipboard [%t]"  \
             "exec browser %u" \
             "clipboard %t"    \
      > "$_actions"
    }
    
    choice="$(cat "$_actions"       \
      | menu  --prompt "action: "   \
              --layout A            \
              --fallback '--layout D --fallback "--layout C"'
    )"

    [[ -z $choice ]] && ERX no action selected
    __o["${choice%% *}"]=1
    printformat="${choice#* }"
  }

  printformat="${printformat//%u/$url}"
  printformat="${printformat//%t/$title}"

  if  [[ -n ${__o[exec]} ]]; then
    eval "${printformat}"
  elif [[ -n ${__o[print]} ]]; then
    echo "$printformat"
  else
    xclip -r -sel c <<< "$printformat"
    xclip -r -sel p <<< "$printformat"
  fi
}

listlinks() {
  local cur="$1" trg url choice title
  local format="<span lang='%s'></span>%s\n"

  choice="$(
  {
    {
      # list all links ('[TITLE]: URL')
      [[ $cur = "$LINKLORD_DIR" ]] && [[ -f $_history ]] \
        && cat "$_history"
      
      if [[ -f $cur ]]; then
        cat "$cur"
      else
        find "$cur" "${_find_options[@]}" -type f -exec cat '{}' \;
      fi
      # format linklist and remove duplicates with awk
    } | awk -v format="$format" -v _prefixlink="$_prefixlink" -F "[][]" '
          NF == 3 && !a[$2]++ {
            url=gensub(/^:\s*/,"",1,$3)
            printf(format, url, _prefixlink $2)
          }
        '

    # list all files and directories if $cur is a dir
    [[ -d $cur ]] && {
      find "$cur" "${_find_options[@]}" -type f -printf "${_prefixfile}%f\n"
      find "$cur" "${_find_options[@]}" -type d -printf "${_prefixfolder}%f\n"
    }

  } | menu --prompt "select url or tag: "  \
           --options "-no-custom"          \
           --layout A                      \
           --fallback '--layout D --fallback "--layout C"'
  )"

  [[ -z $choice ]] && ERX nothing selected

  # test if choice has markup, if true, its a link
  if [[ $choice =~ ^\< ]];then
   linkaction "$choice"
  else
    # trim prefix, append trg to cur to get path
    trg="${choice#${_prefixfile}}" trg="${trg#${_prefixfolder}}"
    trg="$cur/$trg"

    # if path is neither a file or directory
    [[ -d $trg || -f $trg ]] || ERX i dont know what "${trg}" is
    
    listlinks "$trg"
  fi
}

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

verifytitle() {
  local title="$1" url="$2" file="$3"

  # test for illegal characters

  [[ -n $_illegaltitlechars ]] \
    && [[ $title =~ ([${_illegaltitlechars}]) ]] \
      && ERX "'${BASH_REMATCH[1]}' in $title, illegal character "

  allfiles
  # same title can be entered in any number of files
  # but only once in each file. A title can only be used for one url
  awk  -v title="$title" -v url="$url" -v file="$file" -F "[][]" '
    $2 == title {
      currenturl   = gensub("^." $2 ".:[[:space:]]*","",1,$0)
      currenttitle = $2
      msg=""
      
      if (currenturl != url) {
        msg = sprintf("%s is used for: %s in %s",
                      title, currenturl, FILENAME)
      } else if (FILENAME == file) {
        msg = FILENAME
      }

      if (msg != "") {
        print msg
        exit
      }
    }
  ' "${_files[@]}"
}

declare -A __o
options="$(
  getopt --name "[ERROR]:linklord" \
    --options "d:p:s:x:c:t:f:hv" \
    --longoptions "dir:,print:,clipboard:,exec:,category:,title:,filter:,add:,help,version," \
    -- "$@" || exit 77
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --dir        | -d ) __o[dir]="${2:-}" ; shift ;;
    --print      | -p ) __o[print]="${2:-}" ; shift ;;
    --clipboard  | -s ) __o[clipboard]="${2:-}" ; shift ;;
    --exec       | -x ) __o[exec]="${2:-}" ; shift ;;
    --category   | -c ) __o[category]="${2:-}" ; shift ;;
    --title      | -t ) __o[title]="${2:-}" ; shift ;;
    --filter     | -f ) __o[filter]="${2:-}" ; shift ;;
    --add        ) __o[add]="${2:-}" ; shift ;;
    --help       | -h ) ___printhelp && exit ;;
    --version    | -v ) ___printversion && exit ;;
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" 


main "${@:-}"


