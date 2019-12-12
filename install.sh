#!/bin/sh

# Function
_prompt_yesno() {
  EXIT_STATUS=1
  USER_CHOICE=
  while [ -z "$USER_CHOICE" ]; do
    printf "%s" "$1(y/n)> " 1>&2
    read USER_CHOICE
    case $USER_CHOICE in
      [yY]* ) EXIT_STATUS=0  ;;
      [nN]* ) EXIT_STATUS=1  ;;
      *     ) USER_CHOICE="" ;;
    esac
  done
  return $EXIT_STATUS
}

echo "Hi, this is hateblog-sh install script."

# Start confirm
_prompt_yesno "Do you want to install hateblog-sh on your system?"
[ $? -ne 0 ] && exit 0

# Append excute authority
chmod +x hblg
chmod +x subcmd/*
chmod +x shlib/*
chmod +x applib/*

# Make symbolic link
_prompt_yesno "Do you want to make link to hblg from other directory?"
[ $? -ne 0 ] && exit 0

printf "%s" "Link directory path> "
read INSTALL_PATH

CURRENT_DIR=$(pwd)
cd "$INSTALL_PATH" 2>/dev/null
if [ $? -eq 0 ]; then
  ln -sf "${CURRENT_DIR}/hblg" "${INSTALL_PATH}/hblg"
  if [ $? -eq 0 ]; then
    echo "... Linked to '${INSTALL_PATH}/hblg'!"
    echo "Let's config blog by 'hblg cn'"
  fi
else
  echo "'${INSTALL_PATH}' is not directory or not exist or not permit!"
  exit 0
fi

