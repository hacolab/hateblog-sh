#!/bin/sh -u

# [USAGE] $0 {ScriptPath} [UsagePrefix]
usage_exit() {
  CMD_NAME=$(basename $1)
  USAGE_PREFIX=${2:-'+'}
  sed -n "/^#${USAGE_PREFIX}/s/^#${USAGE_PREFIX}//p" "$1" \
  | sed "s/\$0/${CMD_NAME}/g" 1>&2
  exit 1
}

# [USAGE] $0 {ScriptPath} [HelpPrefix]
help_exit() {
  CMD_NAME=$(basename $1)
  HELP_PREFIX=${2:-'[-+]'}
  sed -n "/^#${HELP_PREFIX}/s/^#${HELP_PREFIX}//p" "$1" \
  | sed "s/\$0/${CMD_NAME}/g" 1>&2
  exit 0
}

# [USAGE] $0 {ScriptPath}
version_exit() {
  sed -n "/^# \[VERSION\]/s/^# \[VERSION\] *//p" "$1" 1>&2
  exit 0
}

# [USAGE] $0 {Msg} {ExitCode}
error_exit() {
    echo "$1" 1>&2
    exit $2
}

# [USAGE] $0 {VariableName}
print_var() {
  set +u
  eval "echo $1: \$$1"
  set -u
}

