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


for ___f in "${___dir}/lib"/*; do
  source "$___f"
done

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





