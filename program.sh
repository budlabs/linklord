#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
linklord - version: 2020.01
updated: 2020-01-05 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${LINKLORD_DIR:=$XDG_CONFIG_HOME/linklord}"
: "${LINKLORD_SETTINGS:=$LINKLORD_DIR/.settings}"


main(){

  if [[ -f $* ]]; then
    appendlinks "$*"
  elif [[ -n ${__o[add]} ]]; then
    addlink "${__o[add]}"
  elif [[ -z $* ]]; then
    listlinks "$LINKLORD_DIR"
  fi

}


_menu_browse=(dmenu -p "select link: ")
_menu_action=(dmenu -p "select action: ")
_menu_add_title=(dmenu -p "title for url: ")
_menu_add_category=(dmenu -p "store in category: ")
_find_options=(-maxdepth 1 -mindepth 1 -not -name ".*")

[[ -n "${__o[dir]}" ]] && LINKLORD_DIR="${__o[dir]}"
[[ -d $LINKLORD_DIR ]] || createconf "$LINKLORD_DIR"
[[ -n "${__o[settings]}" ]] && LINKLORD_SETTINGS="${__o[settings]}"
[[ -f $LINKLORD_SETTINGS ]] && . "$LINKLORD_SETTINGS"

: "${_historyfile:="$LINKLORD_DIR/.history"}"
: "${_history_size:=10}"
: "${_reportfile:="$LINKLORD_DIR/.log"}"
: "${_actionfile:="$LINKLORD_DIR/.actions"}"
: "${_spliton:="linklord was here"}"
: "${_char_blacklist:="][<>"}"
: "${_prefixlink:=" " }"
: "${_prefixfile:=" " }"
: "${_prefixfolder:=" "}"

___printhelp(){
  
cat << 'EOB' >&2
linklord - a markdown flavored bookmarks manager


SYNOPSIS
--------
linklord [--dir|-d DIR] [--settings|-s FILE] [--print|-p FORMAT]|[--exec|-x FORMAT]
linklord [--dir|-d DIR] [--settings|-s FILE] [--category|-c CATEGORY] [--title|-t TITLE] [--add-to-history] --add|-a LINK
linklord [--dir|-d DIR] [--settings|-s FILE] MARKDOWN_FILE
linklord --help|-h
linklord --version|-v

OPTIONS
-------

--dir|-d DIR  
Override the environment variable: LINKLORD_DIR


--settings|-s FILE  
Override the environment variable:
LINKLORD_SETTINGS


--print|-p FORMAT  
Print the FORMAT string to stdout when a link is
selected.  %u and %t in FORMAT will be replaced
with URL and TITLE of the selected link.


--exec|-x FORMAT  
the FORMAT string will get evaluated when a link
is selected.  %u and %t in FORMAT will be replaced
with URL and TITLE of the selected link.


--category|-c CATEGORY  
If set the prompt for category when using the
--add option will get bypassed. The link will get
saved to CATEGORY, (the relative path to a file in
LINKLORD_DIR).


--title|-t TITLE  
If set the prompt for title when using the --add
option will get bypassed.  The value of TITLE will
be used as title for the link.


--add-to-history  
If set links will get added to the history file
when the --add option is used.



--add|-a LINK  
Add URL to the database.


--help|-h  
Show help and exit.


--version|-v  
Show version and exit.

EOB
}


addlink() {
  local trg str dunstifyis
  local url="$1"
  local title="${__o[title]:-}"
  local category="${__o[category]:-}"

  ERM "${_menu_add_title[@]}"
  : "${title:=$(echo -n | "${_menu_add_title[@]}")}"

  [[ -z $title ]] || : "${category:=$(
    find "$LINKLORD_DIR" "${_find_options_all[@]}" -type f \
    | sed "s;${LINKLORD_DIR}/;;g" \
    | "${_menu_add_category[@]}"
           
  )}"

  # close Error message from previous add link if
  # dunstifyis (installed)
  [[ ${dunstifyis:=$(command -v dunstify)} ]] \
    && dunstify -C 123454

  [[ -z $category || -z $title ]] && ERX add link canceled

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
      && addtohistory "$str"

    ERM "$(printf 'added url: %s\nas %s in %s\n' \
                  "$url" "$title" "$category"
          )"
  fi
}

addtohistory() {
  local name tmpf

  tmpf="$(mktemp)"

  name="$1"

  if [[ -f $_historyfile ]]; then
  
    awk -v limit="${_history_size:=5}" -v name="$name" '
      BEGIN {a[name]=1 ; print name}
      !a[$0]++ && limit > ++i {print}
    ' "${_historyfile:-}" > "$tmpf"

    mv -f "$tmpf" "$_historyfile"
  else
    echo "$name" > "$_historyfile"
  fi
}

# store path to all files in array '_files'
# if it doesn't already exist
# separet with null char -d ''
allfiles() {
  [[ -z ${_files[0]} ]] && {
    declare -ga _files
    
    readarray -t -d '' _files  \
      < <(find "$LINKLORD_DIR" \
               -mindepth 1     \
               -not -name ".*" \
               -type f         \
               -print0         \
         )
  }        
}
appendlinks() {

  local trgpath="$*" trgfile tdir regex linklist

  [[ ! $trgpath =~ ^/ ]] && trgpath="$PWD/$trgpath"
  trgfile="${trgpath##*/}"

  rm -f "$_reportfile"
  linklist="$(getlinks "$trgpath")" 

  [[ -f "$_reportfile" ]] && ERM "$(sort -u "$_reportfile")"
  
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

geturl() {

  local title="$1"

  allfiles

  awk -F "[][]" -v title="$title" '
    $2 == title {
      print(gensub(/^.*[]]:\s*/,"",1,$0))
      exit
    }
  ' "${_files[@]}"
}

linkaction() {
  local url title printformat choice

  title="${1#$_prefixlink}"
  url="$(geturl "$title")"

  printformat="${__o[exec]:-${__o[print]:-}}"

  [[ -z $printformat ]] && {

    [[ -f $_actionfile ]] \
      || { echo "print %u" > "$_actionfile" ;}

    choice="$(< "$_actionfile" "${_menu_action[@]}")"

    [[ -z $choice ]] && ERX no action selected

    __o["${choice%% *}"]=1
    printformat="${choice#* }"

  }

  addtohistory "$(printf '[%s]: %s' "$title" "$url")"

  printformat="${printformat//%u/$url}"
  printformat="${printformat//%t/$title}"

  if  [[ -n ${__o[exec]} ]]; then
    eval "${printformat}"
  elif [[ -n ${__o[print]} ]]; then
    echo "$printformat"
  fi
}

listlinks() {
  local cur="$1" trg choice
  local format="${_prefixlink}%s\n"
  # local format="<span lang='%s'></span>%s\n"

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
    } | awk -v format="$format" -F "[][]" '
          NF == 3 && !a[$2]++ {
            printf(format, $2)
          }
        '

    # list all files and directories if $cur is a dir
    [[ -d $cur ]] && {
      find "$cur" "${_find_options[@]}" -type f -printf "${_prefixfile}%f\n"
      find "$cur" "${_find_options[@]}" -type d -printf "${_prefixfolder}%f\n"
    }

  } | "${_menu_browse[@]}"
  )"

  [[ -z $choice ]] && ERX nothing selected

  # test if choice has markup, if true, its a link
  if [[ $choice =~ ^${_prefixlink} ]];then
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

verifytitle() {
  local title="$1" url="$2" file="$3"

  # test non accepted characters
  [[ -n $_char_blacklist && $title =~ ([${_char_blacklist}]) ]] && {
    echo "'${BASH_REMATCH[1]}' in $title, illegal character "
    return 1
  }

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
    --options "d:s:p:x:c:t:a:hv" \
    --longoptions "dir:,settings:,print:,exec:,category:,title:,add-to-history,add:,help,version," \
    -- "$@" || exit 77
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --dir        | -d ) __o[dir]="${2:-}" ; shift ;;
    --settings   | -s ) __o[settings]="${2:-}" ; shift ;;
    --print      | -p ) __o[print]="${2:-}" ; shift ;;
    --exec       | -x ) __o[exec]="${2:-}" ; shift ;;
    --category   | -c ) __o[category]="${2:-}" ; shift ;;
    --title      | -t ) __o[title]="${2:-}" ; shift ;;
    --add-to-history ) __o[add-to-history]=1 ;; 
    --add        | -a ) __o[add]="${2:-}" ; shift ;;
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


