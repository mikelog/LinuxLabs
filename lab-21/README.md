# BIND. Split DNS

Сиходный стенд https://github.com/erlong15/vagrant-bind

Добавляем еще один сервер client2

Регистрируем в зоне dns.lab 
  
   имена
  
    web1 - смотрит на клиент1
  
    web2 смотрит на клиент2

Добавляем еще одну зону newdns.lab

  Регистрируем в ней запись
  
    www - смотрит на обоих клиентов

Настраиваем split-dns

    клиент1 - видит обе зоны, но в зоне dns.lab только web1
  
    клиент2 видит только dns.lab

Настраиваем selinux, чтобы все работало при 
```
sestatus
SELinux status:                 enabled
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
```
Для проверки стенда необходимо:
1. Скачать весь  каталог [lab-21](../lab-21)
2. Запустить vagrant up
На клиенте 1:
```
[vagrant@client1 ~]$ nslookup web2.dns.lab
Server:         192.168.50.10
Address:        192.168.50.10#53

** server can't find web2.dns.lab: NXDOMAIN

[vagrant@client1 ~]$ nslookup web1.dns.lab
Server:         192.168.50.10
Address:        192.168.50.10#53

Name:   web1.dns.lab
Address: 192.168.50.15

[vagrant@client1 ~]$ nslookup www.newdns.lab
Server:         192.168.50.10
Address:        192.168.50.10#53

Name:   www.newdns.lab
Address: 192.168.50.15
Name:   www.newdns.lab
Address: 192.168.50.25
```

На клиенте 2:
```
[vagrant@client2 ~]$ nslookup  web1.dns.lab
Server:         192.168.50.10
Address:        192.168.50.10#53

web1.dns.lab    canonical name = client1.dns.lab.
Name:   client1.dns.lab
Address: 192.168.50.15

[vagrant@client2 ~]$ nslookup  web2.dns.lab
Server:         192.168.50.10
Address:        192.168.50.10#53

web2.dns.lab    canonical name = client2.dns.lab.
Name:   client2.dns.lab
Address: 192.168.50.25

[vagrant@client2 ~]$ nslookup  www.newdns.lab
Server:         192.168.50.10
Address:        192.168.50.10#53

Name:   www.newdns.lab
Address: 192.168.50.25
Name:   www.newdns.lab
Address: 192.168.50.15
```

