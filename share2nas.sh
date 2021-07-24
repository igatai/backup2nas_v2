#!/bin/sh

### # # #  #  #  #    #    #    #        #                #                               #
###
###  Script to backup macbook files to NAS.
###
###  This script works at macbook with following flow.
###  1. It compares mac address found in a network segment with correct one to search NAS.
###  2. Let macbook mount to NAS.
###  3. Sync files to backup.
###
###  * Backup data : Family Photo.
###  * Backup destination : Directory to share with family on NAS.
###  * NAS Product information : HDL-AAX2 / io-data.
###
### # # #  #  #  #    #    #    #        #                #                               #

### Store a value in variable.
SCRIPT_DIR=$(cd $(dirname $0); pwd) ## Shell directory.
source ${SCRIPT_DIR}/secret.sh ## Set secret information from other file to environmental valiables.(nas_mac_address,nas_user,nas_password)
NW_SEG="192.168.0" ## Network address.
NAS_IP="" ## Nas ip address.
DIR_TARGET_ROOT=$1 ## Backup source directory on pc.
DIR_HOME="/Users/Taiti" ## Home directory.
DIR_MOUNT="mnt_nas_share" ## Mount directory on pc.
NAS_DIR_MOUNTED="share" ## Directory to be mounted on nas.
NAS_DIR_2ND=${DIR_TARGET_ROOT}
DIR_DST=${DIR_MOUNT} ## Destination directory to backup on nas.
DIR_TARGET_BRANCH="" ## Backup source subdirectory on pc.
SHARE_LIST="${DIR_HOME}/projects/backup2nas_v2/share_lists/${DIR_TARGET_ROOT}" ## Get backup list path

### Find nas IP Address from network segment.
## Try all ip address in network segment.
for ip_address in `seq 200 254`;do
  ## Try ping, arp, grep command with mac address of nas by every ip, and get mac address, if ever.
  mac_add=$(ping -c 1 -W 0.5 ${NW_SEG}.${ip_address} > /dev/null && arp ${NW_SEG}.${ip_address} | cut -d " " -f 4 2>&1)
  ## Compare mac address with one of nas, get ip address of nas.
  if [ "${mac_add}" = "${nas_mac_address}" ]; then
    NAS_IP="${NW_SEG}.${ip_address}"
    break
  fi
done

### monunt to target
mount_status=`mount -v | grep ${DIR_MOUNT} | wc -l | sed -e 's/ //g'`
if [ ${mount_status} -lt 1 ]; then
  mount -t smbfs -w //${nas_user}:${nas_password}@${NAS_IP}/${NAS_DIR_MOUNTED} ${DIR_HOME}/${DIR_MOUNT} || exit 1   ### Mount to nas.
  echo `mount -v`
fi

## Sync directories
while read DIR_TARGET_BRANCH
do
  mount_status=`mount -v | grep ${DIR_MOUNT} | wc -l | sed -e 's/ //g'`
  if [ ${mount_status} -ge 1 ]; then
    echo "rsync -ahvru ${DIR_HOME}/${DIR_TARGET_ROOT}/${DIR_TARGET_BRANCH} ${DIR_HOME}/${DIR_DST}/${DIR_TARGET_BRANCH} > ${SCRIPT_DIR}/log/rsync_${DIR_TARGET_ROOT}.log &"
    rsync -ahvru ${DIR_HOME}/${DIR_TARGET_ROOT}/${DIR_TARGET_BRANCH} ${DIR_HOME}/${DIR_DST}/ > ${SCRIPT_DIR}/log/rsync_${DIR_TARGET_ROOT}.log &  ### Sync data.
    wait $!
  fi
done < $SHARE_LIST
