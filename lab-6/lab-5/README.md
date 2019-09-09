## Управление процессами 

Реализуем аналог **ps ax** на BASH из информации /proc
Для получения информации о  TTY, State процесса, TIME  и СOMMAND  будем использовать:
1. TTY, STATE, TIME - будем получать из /proc/PID/stat
    1.1. TTY - 7-ой по счету параметр от начала строки. 
    1.2. STATE - 3-ий по счету параметр от начала строки.
    1.3. TIME - параметра нет, но  можно посчитать на основе:
        utime и stime, если еще считать и время CPU потомков, то нужны cutime и cstime, это получаются параметры 14, 15, 16, 17
        Для перевода в human style, нам необходимо проссумировать эти значения и поделить на clock_ticks, зависит от настроек системы, получаем из getconf CLK_TCK. 
        Так же, учитывая, что awk дробит по ' ' или /t по умолчанию, то возникали сдвиги из-за  **comm**  параметра, который иногда содержит пробелы, было добавлено обходное проверечное условие, которое смещает на 1 позицию искомые значения, проверено на linux mint и Centos7
        
2. COMMAND - будем получать из /proc/PID/cmdline
3. Скачиваем my_ps.sh
4. Выполняем chmod +x my_ps.sh&&./my_ps.sh
5. Вывод, не такой шустрый как ps ax, пример:
```
       PID        TTY       STAT       TIME COMMAND
         1          0          S   00:00:35 /sbin/init
.....................ВЫРЕЗАНО........................
      2623          0          S   00:00:00 /usr/bin/ssh-agent
      2634          0          S   00:00:00 /usr/lib/gvfs/gvfsd
      2638          0          S   00:00:00 /opt/google/chrome/chrome
      2639          0          S   00:00:00 /usr/lib/gvfs/gvfsd-fuse
      2648          0          S   00:00:00 /usr/lib/at-spi2-core/at-spi-bus-launcher
      2653          0          S   00:00:00 /usr/bin/dbus-daemon
      2655          0          S   00:00:05 /usr/lib/at-spi2-core/at-spi2-registryd
      2666          0          S   00:00:05 /usr/lib/x86_64-linux-gnu/cinnamon-settings-daemon/csd-keyboard

```

