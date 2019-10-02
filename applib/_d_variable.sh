#!/bin/sh -eu
#+[USAGE]
#+  . $0
APP_NAME=hateblog

#==================================================
# Base directory
#==================================================
export HATEBLOG_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/${APP_NAME}"
export HATEBLOG_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/${APP_NAME}"
export HATEBLOG_TMP_DIR="/tmp/${APP_NAME}"

[ ! -d "$HATEBLOG_CONFIG_DIR" ] && mkdir -p "$HATEBLOG_CONFIG_DIR"
[ ! -d "$HATEBLOG_DATA_DIR" ] && mkdir -p "$HATEBLOG_DATA_DIR"
[ ! -d "$HATEBLOG_TMP_DIR" ] && mkdir -p "$HATEBLOG_TMP_DIR"

#==================================================
# Config variable
#==================================================
export HATEBLOG_COMMON_CONFIG_FILE="${HATEBLOG_CONFIG_DIR}/config"
if [ ! -f "$HATEBLOG_COMMON_CONFIG_FILE" ]; then
  _m_new_common_config_file "$HATEBLOG_COMMON_CONFIG_FILE"
fi
CONFIG_FILE="$HATEBLOG_COMMON_CONFIG_FILE"

if [ "$SUB_CMD" = "config" ]; then
  # If config command, don't need config file
  export HATEBLOG_CONFIG_FILE=
else
  # Load default BlogID
  if [ -z "$BLOG_ID" ]; then
    BLOG_ID=$(_get_value DEFAULT_BLOG_ID < "$CONFIG_FILE")
  fi
  BLOG_CONFIG_FILE="${HATEBLOG_CONFIG_DIR}/${BLOG_ID}/config"

  # Auth file exist?
  if [ ! -e "$BLOG_CONFIG_FILE" ]; then
    _print_error "'${BLOG_CONFIG_FILE}' is not found!!"
    return 1
  fi

  # Load BlogID is null?
  BLOG_ID=$(_get_value BLOG_ID < "$BLOG_CONFIG_FILE")
  HATENA_ID=$(_get_value HATENA_ID < "$BLOG_CONFIG_FILE")
  API_KEY=$(_get_value API_KEY < "$BLOG_CONFIG_FILE")
  [ -z "$BLOG_ID" ] && _print_error "'BLOG_ID' is null!" && return 1
  [ -z "$HATENA_ID" ] && _print_error "'HATENA_ID' is null!" && return 1
  [ -z "$API_KEY" ] && _print_error "'API_KEY' is null!" && return 1

  # Make directories
  export HATEBLOG_LIST_FILE="${HATEBLOG_DATA_DIR}/${BLOG_ID}/list"
  export HATEBLOG_ENTRY_DIR="${HATEBLOG_DATA_DIR}/${BLOG_ID}/entry"
  export HATEBLOG_DRAFT_DIR="${HATEBLOG_DATA_DIR}/${BLOG_ID}/draft"
  export HATEBLOG_TRASH_DIR="${HATEBLOG_DATA_DIR}/${BLOG_ID}/trash"
  export HATEBLOG_CONFIG_FILE="${BLOG_CONFIG_FILE}"
  export HATEBLOG_TEMPLATE_DIR="${HATEBLOG_CONFIG_DIR}/${BLOG_ID}/template"

  [ ! -d "$(dirname $HATEBLOG_CONFIG_FILE)" ] && mkdir -p "$(dirname $HATEBLOG_CONFIG_FILE)"
  [ ! -d "$HATEBLOG_TEMPLATE_DIR" ] && mkdir -p "$HATEBLOG_TEMPLATE_DIR"
  [ ! -d "$HATEBLOG_ENTRY_DIR" ] && mkdir -p "$HATEBLOG_ENTRY_DIR"
  [ ! -d "$HATEBLOG_DRAFT_DIR" ] && mkdir -p "$HATEBLOG_DRAFT_DIR"
  [ ! -d "$HATEBLOG_TRASH_DIR" ] && mkdir -p "$HATEBLOG_TRASH_DIR"
fi

#==================================================
# Customizable variable
#==================================================
# Editor
EDITOR="${EDITOR:-vi}"
export HATEBLOG_EDITOR=$(_get_value EDITOR "$EDITOR" < "$CONFIG_FILE")

# Diff viewer
export HATEBLOG_DIFF_VIEWER=$(_get_value DIFF_VIEWER "diff -u" < "$CONFIG_FILE")

# Backup mode
if [ "$SUB_CMD" != "config" ]; then
  export HATEBLOG_AUTO_BACKUP=$(_get_value AUTO_BACKUP "OFF" < "$BLOG_CONFIG_FILE")
fi

# Selector
export HATEBLOG_FILE_SELECTOR=$(_get_value FILE_SELECTOR "fzf --preview='head -n 60 {}'" < "$CONFIG_FILE")
export HATEBLOG_LINE_SELECTOR=$(_get_value LINE_SELECTOR "fzf --no-sort" < "$CONFIG_FILE")
export HATEBLOG_CONFIG_SELECTOR=$(_get_value CONFIG_SELECTOR "${HATEBLOG_FILE_SELECTOR}" < "$CONFIG_FILE")
export HATEBLOG_TEMPLATE_SELECTOR=$(_get_value TEMPLATE_SELECTOR "$HATEBLOG_FILE_SELECTOR" < "$CONFIG_FILE")
export HATEBLOG_DRAFT_SELECTOR=$(_get_value DRAFT_SELECTOR "$HATEBLOG_FILE_SELECTOR" < "$CONFIG_FILE")
export HATEBLOG_TRASH_SELECTOR=$(_get_value TRASH_SELECTOR "$HATEBLOG_FILE_SELECTOR" < "$CONFIG_FILE")

#print_var "HATEBLOG_CONFIG_DIR"
#print_var "HATEBLOG_DATA_DIR"
#print_var "HATEBLOG_TMP_DIR"
#print_var "BLOG_ID"
#print_var "HATENA_ID"
#print_var "API_KEY"
#print_var "HATEBLOG_COMMON_CONFIG_FILE"
#print_var "HATEBLOG_CONFIG_FILE"
#print_var "HATEBLOG_LIST_FILE"
#print_var "HATEBLOG_DRAFT_DIR"
#print_var "HATEBLOG_ENTRY_DIR"
#print_var "HATEBLOG_TRASH_DIR"
#print_var "HATEBLOG_TEMPLATE_DIR"
#print_var "HATEBLOG_EDITOR"
#print_var "HATEBLOG_DIFF_VIEWER"
#print_var "HATEBLOG_AUTO_BACKUP"
#print_var "HATEBLOG_FILE_SELECTOR"
#print_var "HATEBLOG_LINE_SELECTOR"
#print_var "HATEBLOG_CONFIG_SELECTOR"
#print_var "HATEBLOG_TEMPLATE_SELECTOR"
#print_var "HATEBLOG_DRAFT_SELECTOR"
#print_var "HATEBLOG_TRASH_SELECTOR"
#exit

