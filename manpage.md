`linklord` - a markdown flavored bookmarks manager

SYNOPSIS
--------
```text
linklord [--dir|-d LINKLORD_DIR] [--print|-p FORMAT]|[--clipboard|-s FORMAT]|[--exec|-x FORMAT]
linklord [--dir|-d LINKLORD_DIR] [--category|-c CATEGORY] [--title|-t TITLE]|[--filter|-f TITLE] --add LINK
linklord [--dir|-d LINKLORD_DIR] MARKDOWN_FILE
linklord --help|-h
linklord --version|-v
```

DESCRIPTION
-----------
INCHAIN


OPTIONS
-------

`--dir`|`-d` MARKDOWN_FILE  

`--print`|`-p` FORMAT  

`--clipboard`|`-s` FORMAT  

`--exec`|`-x` FORMAT  

`--category`|`-c` CATEGORY  

`--title`|`-t` TITLE  

`--filter`|`-f` TITLE  

`--add` LINK  

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

When a markdown file (*the extension is either
**md** or **markdown***) is passed as an argument
to `linklord`, that markdown file will get
searched for declared but not referenced markdown
links. If those references is found in the file
based database they will get appended to the
markdown file.  

**LINKLORD_DIR/budlabs**  
```
[github]: https://github.com/budlabs
[youtube]: https://youtube.com/c/dubbeltumme
```


**article.md**  
``` markdown
# example file

Voluptate et voluptate [link1](https://example.com)cupidatat 
dolore non incididunt eu veniam consequat enim ut eiusmod 
minim ut ut quis in sit ut [MyTitle] pariatur excepteur aute dolore 
nostrud deserunt commodo excepteur dolore reprehenderit.  

veniam enim id ut commodo laborum do ea eiusmod dolor  aliquip
voluptate do [link3][youtube] dolore culpa commodo velit elit  
nisi in dolore [link4](https://github.com/budlabs) laborum 
cillum do et qui aute officia veniam cupidatat [link5] id.

[link5]: https://example.com
```


The command: `linklord article.md` would print
the following message:  
>     NO URL: MyTitle  
>     ADDED: youtube

Notice that only two links are tested, all other
links are either referenced directly (**link1**
and **link4**) or indirectly (**link5**). Notice
that the reference for **link3** has its own
reference (**youtube**). There is no record of
**MyTitle** in the database but one for youtube.
**article.md** will get updated to this:  

**article.md**  
``` markdown
# example file

Voluptate et voluptate [link1](https://example.com)cupidatat 
dolore non incididunt eu veniam consequat enim ut eiusmod 
minim ut ut quis in sit ut [MyTitle] pariatur excepteur aute dolore 
nostrud deserunt commodo excepteur dolore reprehenderit.  

veniam enim id ut commodo laborum do ea eiusmod dolor  aliquip
voluptate do [link3][youtube] dolore culpa commodo velit elit  
nisi in dolore [link4](https://github.com/budlabs) laborum 
cillum do et qui aute officia veniam cupidatat [link5] id.

[link5]: https://example.com

[linklord was here]: #
[youtube]: https://youtube.com/c/dubbeltumme
```


The reference `[linklord was here]` is inserted
for indicating what has been automatically
appended, everything below this line will get
overwritten by linklord every time this document
is processed. The string **linklord was here**,
can be changed by setting the `_spliton` variable
in **LINKLORD_DIR**/.settings .

## the "database"


`linklord` searches for links in all files that
are not prefixed with a `.` in **LINKLORD_DIR**
(*defaults to `XDG_CONFIG_HOME/linklord`, but can
be set with environment variable or the
commandline option `-d DIR`*). The links should be
stored in markdown format like this:  

**LINKLORD_DIR/file1**
```
[title1]: URL-1
[title2]: URL-A
[title3]: URL-1
```


**LINKLORD_DIR/subdir/file2**
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
menu (`rofi`) will prompt for that info. An
alternative to `--title` is `--filter STRING`,
which will prompt for a title, but with STRING
already in the entrybox.  

`linklord add URL-D` would result in first a
prompt for the title:  
> title for URL-D:

lets say we enter "title1", since that already
exist with a different URL, we will get an error
message and a new prompt to re-enter the title,
lets enter "MyTitle". Now a prompt for
**category** will get displayed together with a
list of all **categories** (*i.e files in
LINKLORD_DIR*), we can now either select one of
the entries in the list or enter the name for a
new category, if we assume the file `budlabs`
(from the first example with the markdown file)
exist, we can select that, which would result in:  

**LINKLORD_DIR/budlabs**  
```
[github]: https://github.com/budlabs
[youtube]: https://youtube.com/c/dubbeltumme
[MyTitle]: URL-D
```


Since *MyTitle* is in the example markdown file,
it would get appended together with *youtube* to
the end of the file if we would execute `linklord
article.md` again.

## the "browser"


If neither a markdown file or the `--add` option
is used when `linklord` is invoked it will instead
display a menu with the links in **LINKLORD_DIR**,
it will also list all categories (files). If the
three files mentioned in this document so far
exists in **LINKLORD_DIR**, the list would look
something like this:  

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
will get displayed. Actions are defined in
**LINKLORD_DIR**/.actions . Each action consists
of two parts: The action and a formatstring:

**LINKLORD_DIR**/.actions  
```
print %u
clipboard %u
clipboard [%t]
exec browser %u
clipboard %t
```


There are three different actions:  
* **print**: prints the format string to stdout
* **clipboard**: puts formatstring in the clipboard and primary selection (requires xclip)
* **exec**: evaluates the format string.


The formatstring has two special symbols that
will get expanded when the action is executed:
* **%u** - expands to the selected links URL
* **%t** - expands to the selected links title


The command line options:  
`--exec FORMATSTRING` OR  
`--clipboard FORMATSTRING` OR  
`--print FORMATSTRING`  
can be used to bypass the action menu.

After the action is executed, the selected link
will also get added to the history
(**BASHBUD_DIR/**.history), the links in the
history will get added to the top of the list next
time `linklord` is executed for browsing.


EXAMPLES
--------
`linklord --help` display help  
`linklord --version` display version  
`man linklord` show man page  

ENVIRONMENT
-----------

`XDG_CONFIG_HOME`  

defaults to: $HOME/.config

`LINKLORD_DIR`  

defaults to: $HOME/tmp/links

`LINKLORD_SETTINGS`  

defaults to: $LINKLORD_DIR/.settings

DEPENDENCIES
------------
`bash`
`gawk`
`xclip`
`dunstify`



