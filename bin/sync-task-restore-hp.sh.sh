#!/bin/bash -e

# ##############################################################################
# Restore my files from backup using the Remal File Backup Tool.
# ##############################################################################
SOURCE_HOME=/home/$USER/Temp/hdd-1
TARGET_HOME=/home/$USER/Workspace

# ------------------------------------------------------------------------------
# Show info about the current backup task.
#
#    param-1: job ID
#    param-2: source home directory
#    param-3: source subdirectory
#    param-4: job type
# ------------------------------------------------------------------------------
function show_job_info() {
  color_yellow="\e[38;5;226m"
  style_bold="\033[1m"
  style_default="\033[0m"
  printf "\n"
  printf "%b********************************************************************************%b\n" "$color_yellow$style_bold" "$style_default"
  printf "%b** %s  %s/%s --> %s%b\n" "$color_yellow$style_bold" "$1" "$2" "$3" "$4" "$style_default"
  printf "%b********************************************************************************%b\n" "$color_yellow$style_bold" "$style_default"
}

# ------------------------------------------------------------------------------
# Back up the given directory.
#
#    param-1: job ID
#    param-2: source subdirectory
#    param-3: job type
# ------------------------------------------------------------------------------
function do_backup() {
  show_job_info "$1" "$SOURCE_HOME" "$2" "$3"
  ./sync-engine.sh "$SOURCE_HOME/$2/" "$TARGET_HOME/$2/" "$3"
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
do_backup " 1/9" private delete-during
do_backup " 2/9" programming delete-during
do_backup " 3/9" e-book delete-during
do_backup " 4/9" graphics delete-during
do_backup " 5/9" learning delete-during
#do_backup " 6/9" music delete-during
do_backup "7/9" photo-album delete-during
#do_backup "8/9" software keep
#do_backup "9/9" videos keep
printf -- "-- END --\n"
