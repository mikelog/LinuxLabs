# VPN, тунели

1. Синтетические тесты dev tun|tap

  1.1. TUN

    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.01  sec   180 MBytes  37.7 Mbits/sec  229             sender
    [  4]   0.00-40.01  sec   179 MBytes  37.6 Mbits/sec                  receiver
    
  1.2. TAP

    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.00  sec   182 MBytes  38.1 Mbits/sec  105             sender
    [  4]   0.00-40.00  sec   181 MBytes  38.0 Mbits/sec                  receiver
    
  В общем, в сферической сети, в вакууме, dev TAP показывает пропускную способосность повыше
  
  Справка из доки:
    
    TAP benefits:
      behaves like a real network adapter (except it is a virtual network adapter)
      can transport any network protocols (IPv4, IPv6, Netalk, IPX, etc, etc)
      Works in layer 2, meaning Ethernet frames are passed over the VPN tunnel
      Can be used in bridges

    TAP drawbacks:
      causes much more broadcast overhead on the VPN tunnel
      adds the overhead of Ethernet headers on all packets transported over the VPN tunnel
      scales poorly

    TUN benefits:
      A lower traffic overhead, transports only traffic which is destined for the VPN client
      Transports only layer 3 IP packets

    TUN drawbacks:
      Broadcast traffic is not normally transported
      Can only transport IPv4 (OpenVPN 2.3 adds IPv6)
      Cannot be used in bridges
    
  Так сказать исходя и +/- и задачи юзаем или TAP или TUN
  Ну и вот кейс из реальных условий:
    
    I chose "tap" when setting up a VPN for a friend who owned a small business because his office uses a tangle of Windows machines, commercial printers, and a Samba file server. Some of them use pure TCP/IP, some seem to only use NetBIOS (and thus need Ethernet broadcast packets) to communicate, and some I'm not even sure of.

    If I had chosen "tun", I would probably have faced lots of broken services — lots of things that worked while you are in the office physically, but then would break when you went off-site and your laptop couldn't "see" the devices on the Ethernet subnet anymore.

    But by choosing "tap", I tell the VPN to make remote machines feel exactly like they're on the LAN, with broadcast Ethernet packets and raw Ethernet protocols available for communicating with printers and file servers and for powering their Network Neighborhood display. It works great, and I never get reports of things that don't work offsite!
    
2. Как проверить стенд:

  2.1. Скачать каталог  [lab-22](./lab-22)

  2.2. Перейти в каталог lab-22 и запустить vagrant up

  2.3. Заходим на виртуальную машину client:
     
    vagrant ssh client
    
  В консоли:
    
    ip -c a
    tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.10.10.6 peer 10.10.10.5/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::7ce1:bec1:fe39:70b5/64 scope link flags 800
       valid_lft forever preferred_lft forever
    
    
    [vagrant@client ~]$ ping 10.10.10.1
    PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
    64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=1.17 ms
    64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=2.39 ms
    




