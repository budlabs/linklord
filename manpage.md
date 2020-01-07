`linklord` - a markdown flavored bookmark manager

SYNOPSIS
--------
```text
linklord [--settings-dir|-s DIR] [--links-dir|-d DIR] [--print|-p FORMAT]|[--exec|-x FORMAT]
linklord --add|-a LINK [--settings-dir|-s DIR] [--links-dir|-d DIR] [--category|-c CATEGORY] [--title|-t TITLE] [--add-to-history]
linklord [--settings-dir|-s DIR] [--links-dir|-d DIR] MARKDOWN_FILE
linklord --help|-h
linklord --version|-v
```

OPTIONS
-------

`--settings-dir`|`-s` DIR  
Override the environment variable:
**LINKLORD_SETTINGS_DIR**

`--links-dir`|`-d` DIR  
Override the environment variable:
**LINKLORD_LINKS_DIR**

`--print`|`-p` FORMAT  
Print the FORMAT string to stdout when a link is
selected.  `%u` and `%t` in FORMAT will be
replaced with URL and TITLE of the selected link.

`--exec`|`-x` FORMAT  
the FORMAT string will get evaluated when a link
is selected.  `%u` and `%t` in FORMAT will be
replaced with URL and TITLE of the selected link.

`--add`|`-a` LINK  
Add URL to the *database*.

`--category`|`-c` CATEGORY  
If set the prompt for category when using the
`--add` option will get bypassed. The link will
get saved to CATEGORY, (the relative path to a
file in LINKLORD_DIR).

`--title`|`-t` TITLE  
If set the prompt for title when using the
`--add` option will get bypassed.  The value of
TITLE will be used as title for the link.

`--add-to-history`  
If set links will get added to the history file
when the `--add` option is used.


`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

## environment variables

#### LINKLORD_SETTINS_DIR

Path to where linklord store its configuration
and log files
(`settings`,`actions`,`.history-l`,`.history-a`,`history-c`,`.log`).
Defaults to `XDG_CONFIG_HOME/.config/linklord`,
and can be overridden with the command line option
`--settings-dir|-s`.

#### LINKLORD_LINKS_DIR

Where the links are stored, defaults to:
`LINKLORD_SETTINGS_DIR/links`, and can be
overridden with the command line option
`--links-dir|-d`.

## files


If **LINKLORD_SETTINGS_DIR** doesn't exist when
`linklord` is executed, the directory will get
created with a `settings` and `action` file with
the default values set for all global variables.

## global variables


Every time `linklord` is executed the
`LINKLORD_SETTINGS_DIR/settings` will get sourced
and any variables declared in the file will be
used as global variables in `linklord`.

**LINKLORD_SETTINGS**

``` bash
#!/bin/bash

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
```


### `_history_size`

How many selected links to remember, these will
be listed before other links, files and
directories.

### `_spliton`

String used to indicate where `linklord` has
appended links to a markdown document.

### `_char_blacklist`

The characters in this string is not allowed in
titles.

### `_prefix*`

Prefix for the different types used in the
browser menu. By default unicode characters from
the iconfont "Font Awesome" is used, but changing
these settings makes it easy to customize.

### `_menu_*`

The commands used to spawn the different menus.
Must be entered as arrays (within parenthesis).
Any menu program that accepts a list as input can
be used. Tested with `fzf` (terminal only),
`rofi`, `i3menu` and `dmenu`.

## the "database"


`linklord` searches for links in all files that
are not prefixed with a `.` in
**LINKLORD_LINKS_DIR**. The links are stored in
markdown format like this:  

**LINKLORD_DIR**/file1  
```
[title1]: URL-1
[title2]: URL-A
[title3]: URL-1
```


**LINKLORD_DIR**/subdir/file2
```
[title4]: URL-1
[title2]: URL-A
[title5]: URL-C
```


The title is linked to the URL, but not vice
verse. Multiple records can have the same URL but
different titles(**title1**,**title3** and
**title4**). Records where both the URL and the
title is the same can occur in multiple files
(**title2**). Think of the files as
**categories**. When a markdown file is searched
it only matches the titles and as soon as it finds
a match it insert the corresponding URL, this is
why one title can't match multiple URLs.  

By using the command line option `--add URL` with
`linklord` a verification of the title will be
performed before adding the link. If `--title
TITLE` and `--category CATEGORY` is not set, a
menu will prompt for that info.  

`linklord --add URL-D` would result in first a
prompt for the title:  
> title for URL-D:

lets say we enter "title1". Now a prompt for
**category** will get displayed together with a
list of all **categories** (*i.e files in
LINKLORD_LINKS_DIR*). We can select one of the
entries in the list or enter the name for a new
category. if we assume the file `budlabs` exist,
and we select that. We would first get an error
message since that already exist with a different
URL. A new prompt to re-enter the title, will be
shown lets enter "MyTitle".  The category will be
the same so no need to enter that twice. This
title is valid and the file
`LINKLORD_LINKS_DIR/budlabs` will now look like
this:

```
[github]: https://github.com/budlabs
[youtube]: https://youtube.com/c/dubbeltumme
[MyTitle]: URL-D
```


## the "browser"


If neither a markdown file or the `--add` option
is used when `linklord` is invoked it will instead
display a menu with the links in
**LINKLORD_LINKS_DIR**,  it will also list all
categories (files).  

If the following three files exist in
**LINKLORD_LINKS_DIR**:  
```
- `LINKLORD_DIR/`
    - `subdir/`
        - `file2`  
          [title4]: URL-1
          [title2]: URL-A
          [title5]: URL-C

    - `file1`
      [title1]: URL-1
      [title2]: URL-A
      [title3]: URL-1

    - 'budlabs'
      [github]: https://github.com/budlabs
      [youtube]: https://youtube.com/c/dubbeltumme
      [MyTitle]: URL-D
```


the list would look something like this:  

```
L github
L youtube
L MyTitle
L title1
L title2
L title3
F budlabs
F file1
D subdir

```


(`L` == link, `F` == file, `D` == directory)  

notice that no links from **subdir/file2** is
included and that the directory name (**subdir**)
is. If a file is selected, a new list with only
the links in that file will get listed. If a
directory is selected all files, links and
directories within the selected directory will get
listed.

### actions


If a link is selected a new menu with actions
will get displayed. Actions are defined in the
file `LINKLORD_SETTINGS_DIR/actions` .  Or with
the commandline options `--print FORMAT` or
`--exec FORMAT`. When the commandline options are
used the action menu will not be displayed. Each
action consists of two parts: The action and a
FORMAT:

`LINKLORD_SETTINGS_DIR/actions`  
```
print %t - %u
exec browser %u
```


* **print**: prints FORMAT to `stdout`
* **exec**: evaluates FORMAT.


FORMAT has two special symbols that will get
expanded when the action is executed:
* **%u** - expands to the selected links URL

* **%t** - expands to the selected links title  

After the action is executed, the selected link
will also get added to the history
(`LINKLORD_SETTINGS_DIR/.history-f`), the links in
the history will get added to the top of the list
next time `linklord` is executed for browsing.

When a markdown file (*a file with either **md**
or **markdown***) is passed as an argument to
`linklord`, that markdown file will get searched
for declared but not referenced markdown links. If
those references is found in the file based
database they will get appended to the markdown
file.  

**LINKLORD_LINKS_DIR**/budlabs  
```
[github]: https://github.com/budlabs
[youtube]: https://youtube.com/c/dubbeltumme
```


**article.md**  
``` markdown
# example direct reference
This first link will get ignored, 
it already has direct url reference: [link1](https://example.com)

# missing reference
But this one: [MyTitle] doesn't so linklord will search for an url
matching "MyTitle".

# not missing reference
[link5] is already referenced in the file, 
it will be ignored by linklord.

[link5]: https://example.com

# referencing reference
[link3][youtube] "link3" has the reference "youtube", 
so it will get ignored, but youtube it self lacks a 
reference so that will get searched for.
```


The command: `linklord article.md` would print
the following message:  
>     NO URL: MyTitle  
>     ADDED: youtube

**article.md** will get updated to this:  

**article.md**  
``` markdown
# example direct reference
This first link will get ignored, 
it already has direct url reference: [link1](https://example.com)

# missing reference
But this one: [MyTitle] doesn't so linklord will search for an url
matching "MyTitle".

# not missing reference
[link5] is already referenced in the file, 
it will be ignored by linklord.

[link5]: https://example.com

# referencing reference
[link3][youtube] "link3" has the reference "youtube", 
so it will get ignored, but youtube it self lacks a 
reference so that will get searched for.

[linklord was here]: #
[youtube]: https://youtube.com/c/dubbeltumme
```


The reference `[linklord was here]` is inserted
for indicating what has been automatically
appended, everything below this line will get
overwritten by **linklord** every time this
document is processed. The string **linklord was
here**, can be changed by setting the `_spliton`
variable in `LINKLORD_SETTINGS_DIR/settings`


ENVIRONMENT
-----------

`XDG_CONFIG_HOME`  

defaults to: $HOME/.config

`LINKLORD_SETTINGS_DIR`  

defaults to: $XDG_CONFIG_HOME/linklord

`LINKLORD_LINKS_DIR`  

defaults to: $LINKLORD_SETTINGS_DIR/links

DEPENDENCIES
------------
`bash`
`gawk`
`sed`



