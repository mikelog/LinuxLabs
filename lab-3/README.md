## Резайсинг /, когда он в LVM, переименование VG, эксперименты с BTRFS
Необходимо уменьшить / системы, все бы ничего, но / в XFS, а ее так просто не ужать как ext4 или btrfs...
1. создаем временную группу томов
```
vgcreate vg01 /dev/sdb1
```
2. создаем разделы 
```
lvcreate -L 1.5G -n lv_swap vg01
lvcreate -l100%FREE -n lv_root
```
3. создаем FS
```
mkswap /dev/vg01/lv_swap
mkfs.ext4 /dev/vg01/lv_root
```
4. переносим /
```
umount /mnt/*
mount /dev/vg01/lv_root /mnt
rsync -axu --exclude '/mnt/*' --exclude '/vagrant' / /mnt # ну или какие другие каталоги, котоыре не нужны для переноса
mount /dev/sda2 /mnt/boot # монтируем бут в новый рут
mount -o bind /dev/ /mnt/dev
mount -o bind /sys /mnt/sys
mount -o bind /proc /mnt/proc
mount -o bind /run /mnt/run
chroot /mnt
```
правим fstab
 заменяем старый рут, свап на новые, не забываем поправить FS, если у вас на новом разделе отличная от старого.
 Правим /etc/default/grub меняем старые знаения VG и LV на новые.
```
dracut  /boot/initramfs-$(uname -r).img $(uname -r) --force
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-install /dev/sda
```
отключаем selinux
```
vi /etc/selinux/config
```
```
SELINUX=disabled
```
Выходим из chroot
и /sbin/reboot
5. После перезагрузки
```
vgremove имя_старой_vg_группы
pvremove /dev/sd[буква диска старого pv]
```
6. задаем размер раздела на старом диске для новой группы, чтобы переехать с временного диска
```
fdisk /dev/sd[буква]
d
№номер раздела в котором была раньше VG с lvm
n
p
next_number
default
+(размер равный тому, который у временного рута)G
t
8e
w
vgextend vg01 /dev/sd[буква_цифра_раздела]
pvmove /dev/sdb1 /dev/sd[буква_цифра_раздела]
vgreduce vg01 /dev/sdb1
pvremove /dev/sdb1
```


## BTRFS

```
yum install btrfs
```
создаем mkfs.btrfs /dev/sd[буква]
создается  том в сингл режиме с дупликацией метафайлов.
если это не надо можно создать без дупликации и выиграть чуток места
```
mkfs.btrfs -m single -d single /dev/sda8 -f
```
создаем рейд1
```
mkfs.btrfs /dev/sdc /dev/sdd
```
посмотреть информацию
```
btrfs filesystem show
```
в каком рейде/не рейде 
```
btrfs filesystem df /точка_монтирования
```
добавить дисков в рейд
```
btrfs device add /dev/sdd /dev/sde /точка_монтирования, если диски были под ФС то -f
```
чтобы диски были задействованы
```
btrfs balance start /точка_монтирования,  лучше не делать в рабочее время
```
но можно сразу запулить их в рейд, например данные в рейд10, метаданный в рейд1
```
btrfs balance start -dconvert=raid10 -mconvert=raid1 /точка_монтирования
```
естественно должны соблюдаться минимальные условия для сборки того или иного рейда.
с 2017 года  raid5,6 на btrfs DEPRICATED, только raid0,1,10 allow
ресайзится тоже все круто и на лету
```
btrfs filesystem resize +|-size /точка_монтирования
```
если рейд, то можно отдельно каждый диск порезать, единственное, что выравние будет по минимальному диску.

снапшоты...интересный зверь, может я и неправильно понял как они работают, но, например, хотим мы экспериментов с каталогом каким-то, например /opt
создаем снапшот
```
btrfs subvolume shapshot /opt /opt_backup
```
то есть откуда и куда, прикол в том, что снапшот можно сделать только в дереве источника, нельзя снапшот утащить в другое место.
далее чтобы не запороть оригинал
```
btrfs subvolume list -p /opt
ID 269 gen 113 parent 5 top level 5 path opt_backup
```
получаем ИД, в нашем случае это ИД снапшота
далее
```
btrfs subvolume set-default 269 /opt
umount /opt
mount -a
```
экспериментируем как хотим, все файлы запороли? не беда, вернемся на верхний уровень
```
btrfs subvolume set-default 0 /opt
umount /opt
mount -a
```
хотя можно просто снапншотнуть поделать что-то и потом каждый файлик из бекапа перетащить, лично я других методов работы  восстановления данных не нашел.
[Ссылка на лог файл script](./lab3.log), почему то не полный файл...
[Ссылка на history](./history_commands.log)


