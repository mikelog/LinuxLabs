## Начнем-с, а не собрать ли нам ядро?
Имеем в наличии

cat /etc/redhat-release

 ``` CentOS Linux release 7.6.1810 (Core) ```

uname -sr

``` Linux 3.10.0-957.10.1.el7.x86_64 ```

Нам понадобится:

* wget
* gcc
* vim, но  можно и обойтись vi  или nano, тут кому как привычнее.
Сначала лучше обновиться, а то вдруг все уже интересующие вкусности нового ядра с обновками придут.

yum update -y

Либо просто идем на https://www.kernel.org/ и тянем интересующее нас ядро.
Я выбрал последнее из longterm
Я сохраняю все сорсы в /usr/src, мне так удобнее, поэтому
cd /usr/src
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.36.tar.xz
Распаковываем архив
unzx -v linux-4.19.36.tar.xz
или
xz -d -v linux-4.19.36.tar.xz

Проверяем исходники ядра
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.36.tar.sign
gpg --verify linux-4.19.36.tar.sign
и если получаем
```gpg: Signature made Sat 20 Apr 2019 10:16:42 AM MSK using RSA key ID 6092693E
gpg: Can't check signature: No public key```

то имеем секс =)
Ладно мчим дальше, берем key ID
gpg --recv-keys 6092693E
и если с выходом в нет у вас все ок, то
```gpg: keyring `/root/.gnupg/secring.gpg' created
gpg: requesting key 6092693E from hkp server keys.gnupg.net
gpg: /root/.gnupg/trustdb.gpg: trustdb created
gpg: key 6092693E: public key "Greg Kroah-Hartman (Linux kernel stable release signing key) <greg@kroah.com>" imported
gpg: key 6092693E: public key "Totally Legit Signing Key <mallory@example.org>" imported
gpg: key 6092693E: public key "Greg Kroah-Hartman <gregkh@linuxfoundation.org>" imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 3
gpg:               imported: 3  (RSA: 3)
```
 и опять верификация
gpg --verify linux-4.19.36.tar.sign
и если вам выдало похожее без всяких Error или Bad Signature
```gpg: Signature made Sat 20 Apr 2019 10:16:42 AM MSK using RSA key ID 6092693E
gpg: Good signature from "Greg Kroah-Hartman <gregkh@linuxfoundation.org>"
gpg:                 aka "Greg Kroah-Hartman <gregkh@kernel.org>"
gpg:                 aka "Greg Kroah-Hartman (Linux kernel stable release signing key) <greg@kroah.com>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E
```
идем дальше
tar xvf linux-4.19.36.tar.sign
cd linux-4.19.36
cp -v /boot/config-$(uname -r) .config
Вывод команды:
```‘/boot/config-3.10.0-957.5.1.el7.x86_64’ -> ‘.config’```

Ставим  пакет для разработки
yum groupinstall "Development Tools" -y
И дополнительные пакеты:
yum install ncurses-devel bison flex elfutils-libelf-devel openssl-devel

И переходим к самому таинству, а именно:
 make menuconfig
 и настраиваем конфиг в текстовом гуе.
В принципе, если вы знаете точные названия параметров, то можно обойтись и vim .config

После того, как изменили конфиг и сохранили его.
make
Чтобы ускорить можно в несколько потоков это сделать
make -j 4
или в зависимости от количества ядер CPU
make -j $(nproc)
у меня не хватило места, я потушишил машину, расширил диск и далее:
в моем случае случаее всего две партиции и поэтому
fdisk -l /dev/sda
d 2 - удаляем вторую партицию
n p - добавляем ее  и по дефолту дальше все
t 8e  делаем ее Linux LVM
w - записываем
в ребут, после ребута
pvresize
pvdisplay

должны увидеть
``` Free PE               2048```
Далее в моем случае
lvextend -l +2048 /dev/centos/root
и так как я профавлил на установке и у меня xfs то
 xfs_growfs /dev/centos/root

и

```df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root   15G  6.1G  8.2G  43% /
```
И далее:
```make modules_install ```
```grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-4.19.36
Found initrd image: /boot/initramfs-4.19.36.img
Found linux image: /boot/vmlinuz-4.19.36.old
Found initrd image: /boot/initramfs-4.19.36.img
Found linux image: /boot/vmlinuz-3.10.0-957.10.1.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-957.10.1.el7.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-957.5.1.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-957.5.1.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-d9f5cf103bf448d3b3ff84ba8b528f9e
Found initrd image: /boot/initramfs-0-rescue-d9f5cf103bf448d3b3ff84ba8b528f9e.img
```
```grubby --set-default /boot/vmlinuz-4.19.36```


И проверим какое ядро по дефолту в буте:
```# grubby --default-kernel
/boot/vmlinuz-4.19.36
```
```/sbin/reboot```
и надеюсь у вас все удачно как у меня =)
```[mikelog@localhost ~]$ uname -r
4.19.36```
