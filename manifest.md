---
description: >
  a markdown flavored bookmarks manager
updated:       2020-01-07
version:       2020.01
author:        budRich
repo:          https://github.com/budlabs/linklord
created:       2019-12-27
type:          default
dependencies:  [bash, gawk]
see-also:      [bash(1), awk(1)]
environ:
    XDG_CONFIG_HOME: $HOME/.config
    LINKLORD_DIR: $XDG_CONFIG_HOME/linklord
    LINKLORD_SETTINGS: $LINKLORD_DIR/.settings
synopsis: |
    [--dir|-d DIR] [--settings|-s FILE] [--print|-p FORMAT]|[--exec|-x FORMAT]
    [--dir|-d DIR] [--settings|-s FILE] [--category|-c CATEGORY] [--title|-t TITLE] [--add-to-history] --add|-a LINK
    [--dir|-d DIR] [--settings|-s FILE] **MARKDOWN_FILE**
    --help|-h
    --version|-v
...











