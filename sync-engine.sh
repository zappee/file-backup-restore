#!/bin/bash -e

# ##############################################################################
# The Remal File Backup Tool copies new/modifies files from the source
#  directory to the target directory usiny rsync.
#
# Release: 0.3.9
# Created by arnold.somogyi@gmail.com
#
# sync-engine.sh <source-directory> <target-directory> [delete-during|delete-before]
#
#    source-directory: folder where the files to be backed up resides
#
#    target-directory: the destination of the backups
#
#    mode (optional):
#       - 'keep'   (default) do not delete files from the target/backup directory
#
#       - 'delete-before'
#                  deleting before the transfer is helpful if the filesystem is
#                  tight for space
#
#       - 'delete-during'
#                  deletes files during the backup, not before, more temporary
#                  disk space is required on the backup disk
#
#
# understand the rsync output:
#
#    YXcstpoguax  path/to/file
#    |||||||||||
#    ||||||||||╰- x: The extended attribute information changed
#    |||||||||╰-- a: The ACL information changed
#    ||||||||╰--- u: The u slot is reserved for future use
#    |||||||╰---- g: Group is different
#    ||||||╰----- o: Owner is different
#    |||||╰------ p: Permission are different
#    ||||╰------- t: Modification time is different
#    |||╰-------- s: Size is different
#    ||╰--------- c: Different checksum (for regular files), or
#    ||              changed value (for symlinks, devices, and special files)
#    |╰---------- the file type:
#    |            f: for a file,
#    |            d: for a directory,
#    |            L: for a symlink,
#    |            D: for a device,
#    |            S: for a special file (e.g. named sockets and fifos)
#    ╰----------- the type of update being done::
#                <: file is being transferred to the remote host (sent)
#                >: file is being transferred to the local host (received)
#                c: local change/creation for the item, such as:
#                    - the creation of a directory
#                    - the changing of a symlink,
#                    - etc.
#                h: the item is a hard link to another item (requires
#                    --hard-links).
#                .: the item is not being updated (though it might have
#                    attributes that are being modified)
#                *: means that the rest of the itemized-output area contains
#                    a message (e.g. "deleting")
# ##############################################################################
SOURCE_DIR="${1:-na}"
TARGET_DIR="${2:-na}"
MODE="${3:-keep}"

COLOR_RED="\033[1m\e[38;5;015m\e[48;5;196m"
COLOR_YELLOW="\e[38;5;226m"
STYLE_BOLD="\033[1m"
STYLE_DEFAULT="\033[0m"

# ------------------------------------------------------------------------------
# Show the manual.
# ------------------------------------------------------------------------------
function show_help() {
  local script_file_name
  script_file_name="${0##*/}"

  printf "%bRemal Backup Tool.%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
  printf "   File backup tool that copies new/modifid files from the source directory to\n"
  printf "   the target directory using rsync.\n\n"

  printf "%bUsage:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "   %s <source-dir> <target-dir> [delete-before | delete-during]\n\n" "$script_file_name"
  printf "   %bsource-dir%b: folder where the files to be backed up resides\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "   %btarget-dir%b: the destination of the backups\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "   mode (optional):\n"
  printf "      %bkeep (default)%b: do not delete files from the target/backup directory\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "      %bdelete-before%b:  deleting before the transfer is helpful if the\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "                         filesystem is tight for space\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "      %bdelete-during%b:  deletes files during the backup, not before, more temporary\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "                         disk space is required on the backup disk\n" "$STYLE_BOLD" "$STYLE_DEFAULT"

  printf "%bExamples:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
  printf "   %s ~/workspace ~/temp/hdd-1/\n" "$script_file_name"
  printf "   %s ~/workspace ~/temp/hdd-1/ delete-before\n" "$script_file_name"
  printf "\n"
  printf "Contact: arnold.somogyi@gmail.com\n"
  printf "Copyright (c) 2020-2024 Remal Software and Arnold Somogyi All rights reserved\n"
  exit 0
}

# ------------------------------------------------------------------------------
# Show user's input.
#
#    param-1: source-directory
#    param-2: target-directory
#    param-3: mode can be 'before' or 'during'
#    param-4: command
# ------------------------------------------------------------------------------
function show_params() {
  local source_dir target_dir mode command
  source_dir="$1"
  target_dir="$2"
  mode="$3"
  command="$4"

  printf "\n"
  printf "Source:%b %s%b\n" "$STYLE_BOLD" "$source_dir" "$STYLE_DEFAULT"
  printf "Target:%b %s%b\n" "$STYLE_BOLD" "$target_dir" "$STYLE_DEFAULT"
  printf "Mode:%b   %s%b\n" "$STYLE_BOLD" "$mode" "$STYLE_DEFAULT"
  printf "\n%s%b\n\n" "$command" "$STYLE_DEFAULT"
}

# ------------------------------------------------------------------------------
# Run the file copy.
#
#    param-1: source-directory
#    param-2: target-directory
#    param-3: mode can be 'before' or 'during'
# ------------------------------------------------------------------------------
function do_backup() {
  local source_dir target_dir mode
  source_dir="$1"
  target_dir="$2"
  mode="$3"

  local endpoints dry_run command
  endpoints="$source_dir $target_dir"
  dry_run="--itemize-changes --dry-run"
  command="rsync --archive --progress --mkpath --stats --human-readable"

  if [ "$mode" == "delete-during" ]; then
    command="${command} --delete-during"
  elif [ "$mode" == "delete-before" ]; then
    command="${command} --delete-before"
  fi

  show_params "$source_dir" "$target_dir" "$mode" "$command $dry_run $endpoints"
  while true; do
    read -p "$(echo -e $COLOR_RED"Comparing the SUORCE and TARGET directories and show the diccerence. Continue? [y/n]"$STYLE_DEFAULT" ")" yn
    case $yn in
        [Yy]* ) eval "$command $dry_run $endpoints"; break;;
        [Nn]* ) exit;;
        * ) printf "Please answer yes or no.\n";;
    esac
  done

  show_params "$source_dir" "$target_dir" "$mode" "$command $endpoints"
  while true; do
    printf "%bDo you want to copy files from SOURCE to TARGET?%b\n" "$COLOR_RED" "$STYLE_DEFAULT"
    printf "%bFiles on TARGET media will be overwritten!%b\n" "$COLOR_RED" "$STYLE_DEFAULT"
    read -p "$(echo -e $COLOR_RED"Continue [y/n]"$STYLE_DEFAULT" ")" yn
    case $yn in
        [Yy]* ) eval "$command $endpoints"; break;;
        [Nn]* ) exit;;
        * ) printf "Please answer yes or no.\n";;
    esac
  done
}

# ------------------------------------------------------------------------------
# Validate script arguments.
#
#    param-1: source-directory
#    param-2: target-directory
#    param-3: mode can be 'before' or 'during'
# ------------------------------------------------------------------------------
function validate_user_input() {
  local not_defined source_dir target_dir mode
  not_defined="na"
  source_dir="$1"
  target_dir="$2"
  mode="$3"

  if [ "$source_dir" == "$not_defined" ] || [ "$target_dir" == "$not_defined" ]; then
    show_help
  fi

  if [ ! -d "$source_dir" ]; then
    show_help
  fi


  if [ "$mode" != "delete-before" ] && [ "$mode" != "delete-during" ] && [ "$mode" != "keep" ]; then
    show_help
  fi

  if ! [ -x "$(command -v rsync)" ]; then
    printf "Error: rsync is not installed.\n"
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
validate_user_input "$SOURCE_DIR" "$TARGET_DIR" "$MODE"
do_backup "$SOURCE_DIR" "$TARGET_DIR" "$MODE"
