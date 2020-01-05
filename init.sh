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


for ___f in "${___dir}/lib"/*; do
  source "$___f"
done

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





