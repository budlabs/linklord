#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
linklord - version: 2020.01.08.4
updated: 2020-01-08 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${LINKLORD_SETTINGS_DIR:=$XDG_CONFIG_HOME/linklord}"
: "${LINKLORD_LINKS_DIR:=$LINKLORD_SETTINGS_DIR/links}"


___printhelp(){
  
cat << 'EOB' >&2
linklord - a markdown flavored bookmark manager


SYNOPSIS
--------
linklord [--settings-dir|-s DIR] [--links-dir|-d DIR] [--print|-p FORMAT]|[--exec|-x FORMAT]
linklord --add|-a LINK [--settings-dir|-s DIR] [--links-dir|-d DIR] [--category|-c CATEGORY] [--title|-t TITLE] [--add-to-history]
linklord [--settings-dir|-s DIR] [--links-dir|-d DIR] MARKDOWN_FILE
linklord --help|-h
linklord --version|-v

OPTIONS
-------

--settings-dir|-s DIR  
Override the environment variable:
LINKLORD_SETTINGS_DIR


--links-dir|-d DIR  
Override the environment variable:
LINKLORD_LINKS_DIR


--print|-p FORMAT  
Print the FORMAT string to stdout when a link is
selected.  %u and %t in FORMAT will be replaced
with URL and TITLE of the selected link.


--exec|-x FORMAT  
the FORMAT string will get evaluated when a link
is selected.  %u and %t in FORMAT will be replaced
with URL and TITLE of the selected link.


--add|-a LINK  
Add URL to the database.


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
    --options "s:d:p:x:a:c:t:hv" \
    --longoptions "settings-dir:,links-dir:,print:,exec:,add:,category:,title:,add-to-history,help,version," \
    -- "$@" || exit 77
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --settings-dir | -s ) __o[settings-dir]="${2:-}" ; shift ;;
    --links-dir  | -d ) __o[links-dir]="${2:-}" ; shift ;;
    --print      | -p ) __o[print]="${2:-}" ; shift ;;
    --exec       | -x ) __o[exec]="${2:-}" ; shift ;;
    --add        | -a ) __o[add]="${2:-}" ; shift ;;
    --category   | -c ) __o[category]="${2:-}" ; shift ;;
    --title      | -t ) __o[title]="${2:-}" ; shift ;;
    --add-to-history ) __o[add-to-history]=1 ;; 
    --help       | -h ) ___printhelp && exit ;;
    --version    | -v ) ___printversion && exit ;;
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" 





