## Перевозим систему с однодисковой конфигурации на RAID1(mdadm). Бюджетно, несложно.

Имеем в наличии Centos 7x64 с одним диском, установленный по умолчанию.

```
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0    8G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    7G  0 part
  ├─centos-root 253:0    0  6.2G  0 lvm  /
  └─centos-swap 253:1    0  820M  0 lvm  [SWAP]
```
Задача:
* Перенести систему на софт рэйд1(mdadm)

Необходимо:
* yum install mdadm rsync smartmontools -y

Забегая чуть вперед скажу, что для переноса на md-raid1 текущей системы, есть два  сценария:
1. Попроще:
 * Так как автоматическая разбивка диска выделила на /boot 1Гиг, то у нас есть место для маневра, т.к. для light-weight сценария нам необходимо, чтобы второй раздел приемника был больше чем оригинальный, минимум на 6 мегабайт
 * Посложнее, например у нас нет возможности двигать разметку...

### Первый путь:
Здесь будет перечень команд, без особой лирики
1. Докидываем диск и делаем разметку:

 ``` fdisk /dev/sd(ваша букава)
 ```
 Необходимо создать 2 партиции:
  * 1 - 512 мегабайт, тип fd
  * 2 - все оставшееся место, тип fd
  Например:

```
  Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     1050623      524288   fd  Linux raid autodetect
/dev/sdb2         1050624    16777215     7863296   fd  Linux raid autodetect
```

2. Так как /boot у нас не в lvm, то можно сразу сделать так:

```
mdadm --zero-superblock /dev/sdb1 - на вский случай, вдруг он был в рейде
mdadm --zero-superblock /dev/sdb2 - аналогично
mdadm --create /dev/md0 --level=1 --raid-disks=2 missing /dev/sdb1 - создаем рейд для /boot
mdadm --create /dev/md1 --level=1 --raid-disks=2 missing /dev/sdb2 - создаем рейд для lvm, в котором все остальное
mdadm --detail --scan > /etc/mdadm.conf  - сейвим конф рейда, чтобы он не ломался после рестарта
mkfs.ext4 /dev/md0  -  создаем файловую систему для /boot
mkdir /mnt/boot/
mount /dev/md0 /mnt/boot
rsync --progress -av /boot/* /mnt/boot  - скопировали на приемник /boot
umount /dev/md0
umount /boot/ -f
mount /dev/md0 /boot/ - монтируем /boot приемника
fdisk /dev/sda - меняем у sda1 тип партии на fd
mkfs.ext4 /dev/sda1 - меняем xfs на ext4
mdadm -a /dev/md0 /dev/sda1 - закидываем  в рейд.
pvcreate /dev/md1 - создаем физический том для lvm
vgscan -  если не помним название группы томов
vgextend 'имя_группы_томов_из_команды_выше'-part2 /dev/md1
pvmove /dev/sda2  /dev/md1 -  перемещаем данные с однодиска на рейд
vgreduce centos_linuxlab2-part2 /dev/sda2 - убираем sda2 из группы томов LVM
fdisk /dev/sda -  для 2 раздела  меняем тип на fd
mdadm -a /dev/md1 /dev/sda2 - закидываем раздел в рейд
blkid | grep md - нам нужен UUID md0, для fstab
vi /etc/fstab -  заменяем UUID /boot'а на новый рейда md0
cat /etc/mdadm.conf  - нужны uuid рейдов
vim /etc/default/grub - и в строку GRUB_CMDLINE_LINUX после rd.lvm.lv=centos/root( в вашем случе рут может быть назван иначе) прописываем rd.md.uuid=uuid_md1 rd.md.uuid=uuid_md0 остальое оставляем как есть

dracut --regenerate-all -fv --mdadmconf --fstab --add=mdraid --add-driver="raid1 raid10 raid456"  - без этого у меня не хотело  работать

dracut  /boot/initramfs-$(uname -r).img $(uname -r) --force

grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-install /dev/sdb
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-install /dev/sda

Да, grub надо инсталить на оба диска, иначе если сдохнет А диск и вы не записали grub в Б диск, то будет упс...А после того как добавите новый диск вместо сбойного, на него тоже надо будет записать grub

/sbin/reboot

Ну а если что-то пошло не так, то rescue в помощь, поэтому совет, тренироваться на виртуалочках, например на vbox
```
Вот, в таком сценарии selinux отключать не надо.

### Второй сценарий
У вас нет возможности двигать разделы, ибо вас потом ждет, как пример:

```
pvmove /dev/mapper/from /dev/mapper/sata1 /dev/mapper/sata2
  Insufficient free space: 524286 extents needed, but only 357699 available
  Unable to allocate mirror extents for pvmove0.
  Failed to convert pvmove LV to mirrored
  ```

Или же root без LVM

###### Итак, погнали:
1. Надо вырубить selinux, иначе потом не зайдете в систему.
2. yum install mdadm rsync smartmontools -y
3. sfdisk -d /dev/sda | sfdisk --force /dev/sdb
4. fdisk /dev/sdb
t
1
fd
t
2
fd
5. mdadm --zero-superblock /dev/sdb1
6. mdadm --zero-superblock /dev/sdb2
7. mdadm --create /dev/md0 --level=1 --raid-disks=2 missing /dev/sdb1
8. mdadm --create /dev/md1 --level=1 --raid-disks=2 missing /dev/sdb2
9. mdadm --detail --scan > /etc/mdadm.conf
10. mkfs.ext4 /dev/md0
11. mkdir /mnt/boot/
12. mount /dev/md0 /mnt/boot
13. rsync --progress -av /boot/* /mnt/boot
14. umount /dev/md0
15. umount /boot/ -f
16. ls -l /boot/
17. mount /dev/md0 /boot/
18. fdisk /dev/sda1
t
1
fd
w
19. mdadm -a /dev/md0 /dev/sda1
20. pvcreate /dev/md1
21. vgcreate vg0 /dev/md1
22. lvcreate -L 820M vg0 -n lv_swap
23. lvcreate -l100%FREE vg0 -n lv_root
24. mkswap /dev/mapper/vg0-lv_swap
25. mkfs.xfs /dev/mapper/vg0-lv_root
26. blkid | grep md0
```
/dev/md0: UUID="59459372-b0e8-4616-bd5d-061a6df26c63" TYPE="ext4"
```
27. ls -l /dev/mapper | grep vg0

```
lrwxrwxrwx. 1 root root       7 May 27 02:24 vg0-lv_root -> ../dm-3
lrwxrwxrwx. 1 root root       7 May 27 02:23 vg0-lv_swap -> ../dm-2

```
28. vi /etc/fstab
```
/dev/mapper/vg0-lv_root /                       xfs     defaults        0 0
UUID=59459372-b0e8-4616-bd5d-061a6df26c63  /boot                   ext4     defaults        0 0
/dev/mapper/vg0-lv_swap swap
```
29. cat /etc/mdadm.conf

```
ARRAY /dev/md0 metadata=1.2 name=localhost.localdomain:0 UUID=c77b19e2:d7a4d24c:7a437714:90c40766
ARRAY /dev/md1 metadata=1.2 name=localhost.localdomain:1 UUID=9baf375f:f7b5fa5a:79d8890e:10f3f691
```
30. vi /etc/default/grub
изменить
```
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
```
на, где сначала uuid рута, а потом /boot, разделы lvm  привести в соответствие со своими
```
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=vg0/lv_root rd.md.uuid=9baf375f:f7b5fa5a:79d8890e:10f3f691 rd.md.uuid=c77b19e2:d7a4d24c:7a437714:90c40766 rd.lvm.lv=vg0/lv_swap rhgb quiet"
```
31. Далее синкаем новый рут и чрутимся в него, чтобы проверить все ли на месте:
```
rsync -axu / /mnt/
mount -o bind /dev/ /mnt/dev/
mount -o bind /sys/ /mnt/sys
mount -o bind /proc /mnt/proc
mount -o bind /run /mnt/run  
chroot /mnt/
```
32. Пересобираем initramfs
```
dracut --regenerate-all -fv --mdadmconf --fstab --add=mdraid --add-driver="raid1 raid10 raid456"
dracut  /boot/initramfs-$(uname -r).img $(uname -r) --force
```
33. Собираем и инсталлим груб:
```
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-install /dev/sdb
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-install /dev/sda
```
34. /sbin/reboot
35. после ребута
```
vgremove  centos /dev/sda2
pvremove /dev/sda2
mdadm  /dev/md0 --fail /dev/sda1
mdadm  /dev/md0 --remove /dev/sda1
fdisk /dev/sda
t
2
fd
w
mdadm  /dev/md0  -a /dev/sda1
mdadm  /dev/md1  -a /dev/sda2

И главное, перепроверять на 100500 все конфиги, одна опечатка ведет в rescue mode =)
