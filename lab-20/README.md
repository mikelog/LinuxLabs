# Динамическая маршрутизация, OSPF, Quagga
OSPF
- Поднять три виртуалки
- Объединить их разными vlan
1. Поднять OSPF между машинами на базе Quagga
2. Изобразить ассиметричный роутинг
3. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным

До выставления "стоимости" маршрута, таблицы маршрутизации выглядели следующим образом:
1. inetRouter1
    ![inetRouter1](./imgs/inetRouter1.jpg)
2. inetRouter2
    ![inetRouter1](./imgs/inetRouter2.jpg)
3. inetRouter3
    ![inetRouter1](./imgs/inetRouter3.jpg)


Была реализована следующая схема:
![Схема](./imgs/ospf.png)

Таблицы маршрутизации стали  такими:
1. inetRouter1
   ![inetRouter1](./imgs/inetRouter1-1.jpg)
2. inetRouter2
   ![inetRouter1](./imgs/inetRouter2-1.jpg)
3. inetRouter3
   ![inetRouter1](./imgs/inetRouter3-1.jpg)


