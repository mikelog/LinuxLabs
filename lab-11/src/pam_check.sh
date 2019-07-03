#!/usr/bin/env bash
isHolyDay=$(curl  --max-time 10 --connect-timeout 5 https://isdayoff.ru/"$(date +%Y%m%d)"?ru=CC | grep "$(date +%d.%m)" /etc/holydays_table -c )
dayOfWeek=$(date +%u)
isAdmin=$(groups "$PAM_USER" | grep admin -c)
if [[ $isAdmin -eq "1" ]];then
 echo "$(date +%Y-%m-%d) $(groups "$PAM_USER")" >> ~/pam_exec.log
 echo "$(date +%Y-%m-%d) isHolyDay=$isHolyDay dayOfWeek=$dayOfWeek isAdmin=$isAdmin" >> ~/pam_exec.log
 exit 0
elif [[ $isHolyDay -eq "1" ]] || [[ $dayOfWeek -gt "5" ]];then
 echo "$(date +%Y-%m-%d) $(groups "$PAM_USER")" >> ~/pam_exec.log
 echo "$(date +%Y-%m-%d) isHolyDay=$isHolyDay dayOfWeek=$dayOfWeek isAdmin=$isAdmin" >> ~/pam_exec.log
 exit 1
elif [[ $isHolyDay -eq "0" ]] && [[ $dayOfWeek -lt "6" ]];then
 echo "$(date +%Y-%m-%d) $(groups "$PAM_USER")" >> ~/pam_exec.log
 echo "$(date +%Y-%m-%d) isHolyDay=$isHolyDay dayOfWeek=$dayOfWeek isAdmin=$isAdmin" >> ~/pam_exec.log
 exit 0
else
 exit 1
fi