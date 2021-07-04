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
seg_nw="192.168.0" ## Network address.
ip_add_nas="" ## Nas ip address.
mounted_dir="share" ## Directory to be mounted on nas.
home_dir="/Users/Taiti" ## Home directory.
mount_dir="${home_dir}/mnt/nas_iodata_2" ## Mount directory on pc.
src_dir=$1 ## Backup source directory on pc.
dst_dir=${mount_dir} ## Destination directory to backup data on nas.
SHARE_LIST="./share_lists/$1" ## Get backup list path

### Find nas IP Address from network segment.
## Try all ip address in network segment.
for ip_address in `seq 200 254`;do
  ## Try ping, arp, grep command with mac address of nas by every ip, and get mac address, if ever.
  mac_add=$(ping -c 1 -W 0.5 ${seg_nw}.${ip_address} > /dev/null && arp ${seg_nw}.${ip_address} | cut -d " " -f 4 2>&1)
  ## Compare mac address with one of nas, get ip address of nas.
  if [ "${mac_add}" = "${nas_mac_address}" ]; then
    ip_add_nas="${seg_nw}.${ip_address}"
    break
  fi
done

## Sync directories
while read target_dir_path
do
  umount ${mount_dir}   ### unmount nas
  mount -t smbfs -w //${nas_user}:${nas_pw}@${ip_add_nas}/${mounted_dir} ${mount_dir}/ || exit 1   ### Mount to nas.
  rsync -ahvr ${home_dir}/${src_dir}/ ${dst_dir}/${src_dir}/ > ${SCRIPT_DIR}/log/rsync_${src_dir}.log &  ### Sync data.
done < $SHARE_LIST
