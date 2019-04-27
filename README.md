# LinuxLabs
## Начнем-с
Имеем в наличии

cat /etc/redhat-release

 ``` CentOS Linux release 7.6.1810 (Core) ```

uname -sr

``` Linux 3.10.0-957.10.1.el7.x86_64 ```

Нам понадобится:

..*wget
..*gcc
..*vim, но  можно и обойтись vi  или nano, тут кому как привычнее.
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

