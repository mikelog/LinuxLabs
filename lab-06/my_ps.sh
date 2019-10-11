#!/usr/bin/env bash
clk_tck=$(getconf CLK_TCK)
printf "%10s %10s %10s %10s %s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"
for pid in $(ls -l /proc | awk '{print $9}' | grep -s "^[0-9]*[0-9]$"| sort -n );
do
 if test -f "/proc/$pid/stat"; then
    if [[ $(cat /proc/$pid/stat | awk '{print $3}' | grep "[IRSDZTW]" -c) -eq "0" ]]; then
        tty=$(cat /proc/$pid/stat | awk '{print $8}')
        stat=$(cat /proc/$pid/stat | awk '{print $4}')
        utime=$(cat /proc/$pid/stat | awk '{print $15}')
        stime=$(cat /proc/$pid/stat | awk '{print $16}') 
    else
        tty=$(cat /proc/$pid/stat | awk '{print $7}') 
        stat=$(cat /proc/$pid/stat | awk '{print $3}')
        utime=$(cat /proc/$pid/stat | awk '{print $14}')
        stime=$(cat /proc/$pid/stat | awk '{print $15}') 
    fi
 fi
 if test -f "/proc/$pid/cmdline"; then
    cmd=$(cat /proc/$pid/cmdline | tr '\0' ' ' | awk '{print $1}')
 fi

ttime=$((utime + stime))
time=$((ttime / clk_tck))
time=$(printf "%02d:%02d:%02d" $(($time/3600)) $(($time%3600/60)) $(($time%60)))
printf "%10s %10s %10s %10s %s\n" "$pid"  "$tty" "$stat" "$time" "$cmd" 
done
