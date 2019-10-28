#!/bin/bash


install_mdadm() {
     sudo yum -y install mdadm
}


configure_raid5_with_spare() {
     mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sd[b-e] --spare-devices=1 /dev/sdf
}

check_raid() {
     cat /proc/mdstat
}

save_raid() {
     sudo bash
     mkdir -p /etc/mdadm 
     echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
     mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
}

create_fs() {
     mkfs.xfs /dev/md0
     mkdir -p /mnt/raid
     chmod 777 /mnt/raid
     bash -c "echo /dev/md0 /mnt/raid xfs  rw,user,exec 0 0 >> /etc/fstab"
     bash -c "echo chmod 777 /mnt/raid >> /etc/rc.local"
     mount /mnt/raid
     chmod 777 /mnt/raid
}

erase_superblock() {
 mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
}



main() {
  install_mdadm
  erase_superblock
  configure_raid5_with_spare
  save_raid
  create_fs
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
