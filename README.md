# linklord - a markdown flavored bookmark manager 

linklord was created out of the frustration of finding
myself constantly digging up urls when writing markdown
articles. I wrote **linklord** to automate that process. A
side effect was that it also is a quite nice way to manage,
and organize bookmarks in general.  

See the [wiki][linklord wiki] for more info and examples of
use cases.  

## installation

If you are using **Arch linux**, you can install the
linklord package from [AUR][linklord aur].  

Or follow the instructions below to install from source:  

(*configure the installation destination in the Makefile if
needed*)

``` text
$ git clone https://github.com/budlabs/linklord.git
$ cd linklord
# make install
$ linklord --version

linklord - version: 2020.01
updated: 2020-01-03 by budRich
```


The only file you really need is `linklord.bash` , you can
also just add that to your **$PATH**.

## OPTIONS

```text
linklord [--settings-dir|-s DIR] [--links-dir|-d DIR] [--print|-p FORMAT]|[--exec|-x FORMAT]
linklord --add|-a LINK [--settings-dir|-s DIR] [--links-dir|-d DIR] [--category|-c CATEGORY] [--title|-t TITLE] [--add-to-history]
linklord [--settings-dir|-s DIR] [--links-dir|-d DIR] MARKDOWN_FILE
linklord --help|-h
linklord --version|-v
```


`--settings-dir`|`-s` DIR  
Override the environment variable:
**LINKLORD_SETTINGS_DIR**

`--links-dir`|`-d` DIR  
Override the environment variable: **LINKLORD_LINKS_DIR**

`--print`|`-p` FORMAT  
Print the FORMAT string to stdout when a link is selected. 
`%u` and `%t` in FORMAT will be replaced with URL and TITLE
of the selected link.

`--exec`|`-x` FORMAT  
the FORMAT string will get evaluated when a link is
selected.  `%u` and `%t` in FORMAT will be replaced with URL
and TITLE of the selected link.

`--add`|`-a` LINK  
Add URL to the *database*.

`--category`|`-c` CATEGORY  
If set the prompt for category when using the `--add`
option will get bypassed. The link will get saved to
CATEGORY, (the relative path to a file in LINKLORD_DIR).

`--title`|`-t` TITLE  
If set the prompt for title when using the `--add` option
will get bypassed.  The value of TITLE will be used as title
for the link.

`--add-to-history`  
If set links will get added to the history file when the
`--add` option is used.


`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

## updates

#### 2020.01.08.20

When searching and appending links. Awk now breaks when
`_spliton` string is found.

#### 2020.01.08.19


some minor bugfixes and documentatoin errors. FIXED: when a
title didn't pass verification, the wrong command was used
to prompt for a new menu. CHANGED: selected actions are not
stored in a history file, instead the action file itself is
updated. CHANGED: _history_limit can now be zero, which
means no limit.

#### 2020.01.07.01


Initial release.


## known issues

Perfect software, no known issues

[linklord was here]: #
[linklord wiki]: https://github.com/budlabs/linklord/wiki
[linklord aur]: https://aur.archlinux.org/packages/linklord