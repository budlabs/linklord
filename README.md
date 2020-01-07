# linklord - a markdown flavored bookmarks manager 

linklord was created out of the frustration of finding
myself constantly digging up urls when writing markdown
articles. I wrote **linklord** to automate that process. A
side effect was that it also is a quite nice way to manage,
and organize bookmarks in general.  

See the [wiki][linklord wiki] for more info and examples of
use cases.  

## installation

If you are using **Arch linux**, you can install the
linklord package from [AUR][linklord AUR].  

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

OPTIONS
-------

```text
linklord [--dir|-d DIR] [--settings|-s FILE] [--print|-p FORMAT]|[--exec|-x FORMAT]
linklord [--dir|-d DIR] [--settings|-s FILE] [--category|-c CATEGORY] [--title|-t TITLE] [--add-to-history] --add|-a LINK
linklord [--dir|-d DIR] [--settings|-s FILE] MARKDOWN_FILE
linklord --help|-h
linklord --version|-v
```


`--dir`|`-d` DIR  
Override the environment variable: **LINKLORD_DIR**

`--settings`|`-s` FILE  
Override the environment variable: **LINKLORD_SETTINGS**

`--print`|`-p` FORMAT  
Print the FORMAT string to stdout when a link is selected. 
`%u` and `%t` in FORMAT will be replaced with URL and TITLE
of the selected link.

`--exec`|`-x` FORMAT  
the FORMAT string will get evaluated when a link is
selected.  `%u` and `%t` in FORMAT will be replaced with URL
and TITLE of the selected link.

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


`--add`|`-a` LINK  
Add URL to the *database*.

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

EXAMPLES
--------

`linklord --help` display help  
`linklord --version` display version  
`man linklord` show man page  

## known issues

No known issues

[linklord was here]: #
[linklord wiki]: https://github.com/budlabs/linklord/wiki