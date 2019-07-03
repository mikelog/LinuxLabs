#!/bin/sh

PATH="/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin"                                                                                            
isRuning()
{
    if pidof -x $(basename $0) > /dev/null; then
        for p in $(pidof -x $(basename $0)); do
            echo $(pidof -x $(basename $0))
            echo $p
            if [ $p -ne $$ ]; then
                echo "Script $0 is already running: exiting"
                return 1
            else return 0
            fi
        done
    fi
}
isRun=0
i=0
echo $(basename $0) 
echo $(pidof -x $(basename $0))
while [ $isRun -eq 0 ]
do
 isRun=$((isRuning))
 i=$((i+1))
 echo $i
done
#isRuning