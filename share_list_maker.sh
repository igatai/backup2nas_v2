#!/bin/sh

### # # #  #  #  #    #    #    #        #                #                               #
###
### This script makes share target directry path list.
###
### This script works with following flow.
### 1. Get target directory names from a file named as BACKUP_TARGET_DIR_LIST.
### 2. From the upper directory name described in BACKUP_TARGET_LIST, write the path of the subdirectory in the upper directory to each file named with the upper directory name.
###
### Preparation
### 1. Set directoroy name to backup in a file named as BACKUP_TARGET_DIR_LIST at directry which this script is.
### 2. Make directory named as backup_lists at directry which this script is.
### # # #  #  #  #    #    #    #        #                #                               #

# Set parameters
HOME_DIR="/Users/Taiti"
SHARE_LISTS="share_lists"

# Delete old lists
while read DIR_NAME
do
  rm ./$SHARE_LISTS/$DIR_NAME
done < SHARE_TARGET_DIR_LIST

# Make lists
while read DIR_NAME
do
  # If listed object is a directory, first section of output text by command`ls -l` is 'd'.
  for dir in `ls -l $HOME_DIR/$DIR_NAME | awk '$1 ~ /d/ {print $9 }'`
  do
    echo $dir >> ./$SHARE_LISTS/$DIR_NAME
  done
done < SHARE_TARGET_DIR_LIST
