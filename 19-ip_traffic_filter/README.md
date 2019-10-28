## Iptables, port-forwarding, port-knocking
Исходные данные:
1. Выполнить настройку IPTABLES для дополнительной защиты порта ssh InetRouter от сканеров и прочих нехороших людей.
2. Пробросить порт 8080 с  хоста в гостевую ос centralServer можно с маскарадингом, а можно без

Чтобы проверить решение, необходимо:

1. Скачать все содержимое данного [каталога](./)
2. Выполнить vagrant up  в том каталоге, куда скачали Vagrantfile и каталог files в п.1.
3. После старта  создастся 4 инстанса. 
4. Попасть на ssh inetRouter  можно с centralRouter, для этого  выполняем
```
vagrant ssh cenralRouter
```
Далее выполняем скрипт
```
/usr/bin/knocking.sh 192.168.255.1 6622 1166 2266
``` 
После этого у нас будет 30 секунд чтобы попасть на целевую машину
```
ssh vagrant@192.168.255.1
```
Пароль vagrant

Проброс порта 8080 на centraServer выполнен без masquerade
С хоста выполняем 
```
curl http://127.0.0.1:8080
```