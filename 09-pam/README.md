## Настраиваем PAM для  управления входом в систему по рабочим дням
1. Для запуска проекта вам надо скачать каталог ./src и Vagrantfile
2. Когда каталог src скачан и лежит рядом с Vagrantfile, то выполняем vagrant up
3. В каталоге src лежит [файл](./src/holydays_table)  на случай определения дней, когда пользователю не из группы admin запрещается работать за ПК локально и по ssh, при добавлении или изменении списка этих дней, формат необходимо соблюдать такой, какой был изначально.
4. На случай, если вы решите редактировать *.sh  скрипты под Windows, например в VSCode, [полезная информация](https://ztirom.at/2016/01/resolving-binbashm-bad-interpreter-when-writing-a-shellscript-on-windows-with-vs-code-and-run-it-on-linux/)
Да, в Windows  и  Linux различные символы конца строки.
5. При разворачивании стенда создается пользователь testuser, который должен сменить пароль (0000 - четырe ноля) при первом входе.
4. Так же попутно устаналивается docker и пользователю testuser даются права на зпуск и оставку докер демона и работу с самим докер через sudo