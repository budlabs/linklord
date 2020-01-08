---
description: >
  a markdown flavored bookmark manager
updated:       2020-01-08
version:       2020.01.08.0
author:        budRich
repo:          https://github.com/budlabs/linklord
created:       2019-12-27
type:          default
dependencies:  [bash, gawk, sed]
see-also:      [dmenu(1),fzf(1),rofi(1)]
environ:
    XDG_CONFIG_HOME: $HOME/.config
    LINKLORD_SETTINGS_DIR: $XDG_CONFIG_HOME/linklord
    LINKLORD_LINKS_DIR: $LINKLORD_SETTINGS_DIR/links
synopsis: |
    [--settings-dir|-s DIR] [--links-dir|-d DIR] [--print|-p FORMAT]|[--exec|-x FORMAT]
    --add|-a LINK [--settings-dir|-s DIR] [--links-dir|-d DIR] [--category|-c CATEGORY] [--title|-t TITLE] [--add-to-history]
    [--settings-dir|-s DIR] [--links-dir|-d DIR] **MARKDOWN_FILE**
    --help|-h
    --version|-v
...











