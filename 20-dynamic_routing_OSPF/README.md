# Динамическая маршрутизация, OSPF, Quagga
OSPF
- Поднять три виртуалки
- Объединить их разными vlan
1. Поднять OSPF между машинами на базе Quagga
2. Изобразить ассиметричный роутинг
3. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным

До выставления "стоимости" маршрута, таблицы маршрутизации выглядели следующим образом:
1. inetRouter1
    ![inetRouter1](./imgs/inetRouter1.png)
2. inetRouter2
    ![inetRouter1](./imgs/inetRouter2.png)
3. inetRouter3
    ![inetRouter1](./imgs/inetRouter3.png)


Была реализована следующая схема:
1. для синхронной машрутизации стоимость линка между Router1 и Router3 повышена до 200, линки:
    
    1.1. inetRouter1-2, inetRouter3-2, inetRouter1-3.

2. для асинхронной маршрутизации, стоимость линка между Router1 и Router3 повышена до 200 только  от Router3 в сторону Router1, линки:

    1.2. inetRouter11-21, inetRouter31-21, inetRouter11-31.


    ![ospf](./imgs/ospf.png)

Таблицы маршрутизации стали  такими:
1. inetRouter1
   ```
   default via 10.0.2.2 dev eth0 proto dhcp metric 100 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
    192.168.200.0/29 dev eth3 proto kernel scope link src 192.168.200.1 metric 103 
    192.168.210.0/29 dev eth4 proto kernel scope link src 192.168.210.1 metric 104 
    192.168.220.0/29 proto zebra metric 40 
	nexthop via 192.168.251.2 dev eth2 weight 1 
	nexthop via 192.168.210.2 dev eth4 weight 1 
    192.168.250.0/29 dev eth1 proto kernel scope link src 192.168.250.1 metric 101 
    192.168.251.0/29 dev eth2 proto kernel scope link src 192.168.251.1 metric 102 
    192.168.252.0/29 proto zebra metric 40 
	nexthop via 192.168.251.2 dev eth2 weight 1 
	nexthop via 192.168.210.2 dev eth4 weight 1 
    ```
2. inetRouter2
   ```
   default via 10.0.2.2 dev eth0 proto dhcp metric 100 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
    192.168.200.0/29 proto zebra metric 40 
	nexthop via 192.168.252.1 dev eth2 weight 1 
	nexthop via 192.168.220.1 dev eth4 weight 1 
    192.168.210.0/29 dev eth3 proto kernel scope link src 192.168.210.2 metric 103 
    192.168.220.0/29 dev eth4 proto kernel scope link src 192.168.220.2 metric 104 
    192.168.250.0/29 proto zebra metric 220 
	nexthop via 192.168.251.1 dev eth1 weight 1 
	nexthop via 192.168.210.1 dev eth3 weight 1 
	nexthop via 192.168.252.1 dev eth2 weight 1 
	nexthop via 192.168.220.1 dev eth4 weight 1 
    192.168.251.0/29 dev eth1 proto kernel scope link src 192.168.251.2 metric 101 
    192.168.252.0/29 dev eth2 proto kernel scope link src 192.168.252.2 metric 102
   ```
3. inetRouter3
   ```
   10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
    192.168.200.0/29 dev eth4 proto kernel scope link src 192.168.200.2 metric 104 
    192.168.210.0/29 proto zebra metric 40 
	nexthop via 192.168.252.2 dev eth1 weight 1 
	nexthop via 192.168.220.2 dev eth3 weight 1 
	nexthop via 192.168.200.1 dev eth4 weight 1 
    192.168.220.0/29 dev eth3 proto kernel scope link src 192.168.220.1 metric 103 
    192.168.250.0/29 dev eth2 proto kernel scope link src 192.168.250.2 metric 102 
    192.168.251.0/29 proto zebra metric 40 
	nexthop via 192.168.252.2 dev eth1 weight 1 
	nexthop via 192.168.220.2 dev eth3 weight 1 
	nexthop via 192.168.200.1 dev eth4 weight 1 
    192.168.252.0/29 dev eth1 proto kernel scope link src 192.168.252.1 metric 101
   ```

Для проверки стенда:

1. Скачать [Vagrantfile](./Vagrantfile), [ansible.cfg](./ansible.cfg), каталоги [files](./files), [playbooks](./playbooks), [roles](./roles).
Файл ansible.cfg и  каталоги files, playbook, roles со всем содержимым должны быть расположены рядом с Vagranfile
2. Выполнить vagrant up  в том каталоге, куда скачали Vagrantfile в п.1.
3. После сборки стенда, можно зайти на inetRouter3 и сделать tracepath до host-ов в сети между inetRouter1  и inetRouter3, машрут пойдет по  дешевому длинному пути.
    ```
    [vagrant@inetRouter3 ~]$ tracepath 192.168.251.1
    1?: [LOCALHOST]                                         pmtu 1500
    1:  192.168.252.2                                         1.271ms
    1:  192.168.252.2                                         0.795ms
    2:  192.168.251.1                                         0.868ms reached
     Resume: pmtu 1500 hops 2 back 2
    ```

    И обратно:

    ```
    [vagrant@inetRouter1 ~]$ tracepath -n 192.168.252.1
    1?: [LOCALHOST]                                         pmtu 1500
    1:  192.168.251.2                                         0.752ms
    1:  192.168.251.2                                         0.567ms
    2:  192.168.252.1                                         0.704ms reached
     Resume: pmtu 1500 hops 2 back 2
    ```
    Дамп трафика, откуда трафик отправили, туда и получили:

    ```
    [root@inetRouter1 vagrant]# tcpdump -ni eth2 icmp
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on eth2, link-type EN10MB (Ethernet), capture size 262144 bytes
    IP 192.168.251.1 > 192.168.252.1: ICMP echo request, id 8542, seq 1, length 64
    IP 192.168.252.1 > 192.168.251.1: ICMP echo reply, id 8542, seq 1, length 64
    IP 192.168.251.1 > 192.168.252.1: ICMP echo request, id 8542, seq 2, length 64
    IP 192.168.252.1 > 192.168.251.1: ICMP echo reply, id 8542, seq 2, length 64
    ```
    Асинхронная машрутизация, трафик отпраляем с одного ETH, получаем на другой ETH, хотя по трейсу и не скажешь, но и чтобы трейс отраотал, надо выставить **net.ipv4.conf.all.rp_filter=0**:

    ```
    [vagrant@inetRouter1 ~]$ tracepath -n 192.168.220.1
    1?: [LOCALHOST]                                         pmtu 1500
    1:  192.168.210.2                                         0.797ms 
    1:  192.168.210.2                                         0.819ms 
    2:  192.168.220.1                                         0.843ms reached
    ```
    И дамп трафика:

    ```
    [root@inetRouter1 vagrant]# tcpdump -ni eth2 icmp
    listening on eth2
    IP 192.168.251.1 > 192.168.252.1: ICMP echo request, id 8542, seq 1, length 64
    IP 192.168.252.1 > 192.168.251.1: ICMP echo reply, id 8542, seq 1, length 64
    IP 192.168.251.1 > 192.168.252.1: ICMP echo request, id 8542, seq 2, length 64
    IP 192.168.252.1 > 192.168.251.1: ICMP echo reply, id 8542, seq 2, length 64
    ```
    
    ```  
    [root@inetRouter1 vagrant]# tcpdump -ni eth4 icmp
    listening on eth4
    IP 192.168.210.1 > 192.168.220.1: ICMP echo request, id 8544, seq 1, length 64
    IP 192.168.210.1 > 192.168.220.1: ICMP echo request, id 8544, seq 2, length 64
    IP 192.168.210.1 > 192.168.220.1: ICMP echo request, id 8544, seq 3, length 64
    ```

