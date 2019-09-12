#!/usr/bin/env bash
#DETERMINE CONSTANTS
pidfile=./nginxparser.pid
LAST_RUN_DATA=./prev_parse
LOG_FILE=""
EMAIL_TO=""
#log_parh searching
logfile_search(){
 logs_files_count=$(find / -name $LOG_FILE 2>&1 | grep -v "Permission denied\| No such file" -c)
 if [ $logs_files_count -eq "1" ];then
  echo  $(find / -name $LOG_FILE 2>&1 | grep -v "Permission denied\| No such file" )
 else 
  echo $logs_files_count
 fi
}

#check if allready runing
is_run()
{
 if ! test -f "$pidfile"; then
    touch $pidfile
    echo "$$" > "$pidfile"
    echo "0"
 else 
    echo "1"
 fi   
}

#maim funcrion
ParseLogFile()
{
#clear   
if [ ! -f $LAST_RUN_DATA ];then
 touch $LAST_RUN_DATA
 echo "0" > $LAST_RUN_DATA
fi
LAST_RUN=$(($(cat $LAST_RUN_DATA)+1))
LCYAN='\033[1;36m'     #  ${LCYAN}
NORMAL='\033[0m'		# ${NORMAL}


RESP_CODES='response.tmp'
RATES_REQUESTS='rates_requests.tmp'

  
  tail -n +$LAST_RUN $LOG_FILE_PATH | awk '($4$5)' > total.tmp
	
  awk '{print $9}' total.tmp | sort | uniq -c | sort -rn -o $RESP_CODES &
  awk '{ ind = match($6$7, /\?/)
         if (ind > 0)
           print substr($6$7, 0, ind)
         else
           print $6$7
       }' total.tmp | sort | uniq -c | sort -rn -o $RATES_REQUESTS
  
      echo -e "${LCYAN}Коды ответа сервера ${NORMAL}"
      awk '{print "\033[0;33m" $2, $1}' $RESP_CODES
  
      echo -e "${LCYAN}Топ запросов ${NORMAL}"
      awk 'FNR <= 5 {print "\033[0;33m" $1, $2}' $RATES_REQUESTS
	  
	  tput sgr0
	  wc -l $LOG_FILE_PATH | awk '{print $1}' > "$LAST_RUN_DATA"
	  
	  CBC=$(awk '{print "\043[0;33m" $2, $1}' $RESP_CODES)
	  RQ=$(awk 'FNR <= 5 {print "\033[0;33m" $1, $2}' $RATES_REQUESTS)
	  
	  
	  echo -e "Максимальное количество запросов в секунду:$MPS\n Коды ответа сервера:$CBC\n Топ запросов:$RBF\n" | mail -s "Nginx logs" $EMAIL_TO
}

#cleanup funcrion
cleanup()
{
run_pid=$(cat $pidfile)
#echo "trap hoocked pid $run_pid"
if [[ "$$" -eq "$run_pid" ]] && [[ "$run_pid" -ne "" ]]; then
 rm -f $pidfile
fi
}
trap cleanup 0


#body
is_runing=$(is_run)

if [[ $is_runing -eq "1" ]]; then 
 echo "allready runing. exit"
 exit
 else 
  if [ -n "$1" ]; then
    LOG_FILE=$1
    else 
        echo "LogFile name require. Specify it first. Exit"
        exit
  fi 
  if [ -n "$2" ]; then
    EMAIL_TO=$2
    else  
     echo "e-mail require. Specify it second. Exit"
     exit
  fi 
  if [ -n "$LOG_FILE" ] && [ -n "$EMAIL_TO" ];then
    echo "Searching file $LOG_FILE"
    LOG_FILE_PATH=$(logfile_search)
    if ! (echo "$LOG_FILE_PATH" | grep -E -q "^-?[0-9]+$"); then
        echo "LogFile $LOG_FILE found. Start parsing $LOG_FILE_PATH"
        ParseLogFile 
        else echo "No found $LOG_FILE"
    fi
   else
    echo "No log file name and e-mail_to specified. Exit"
    exit
   fi 
fi
trap cleanup EXIT
trap cleanup SIGINT

