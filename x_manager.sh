#!/bin/bash
PATH=`pwd`

function main(){
    if [[ $1 == 'start' ]]; then
        if [[ `cat /etc/rc.d/rc.local |grep 'x_manager.sh' -c` < 1 ]]; then
            echo "${PATH}/x_manager.sh start" >> /etc/rc.d/rc.local
        fi
        monitor &
    fi

    if [[ $1 == 'stop' ]]; then
        ps aux |grep x_manager |awk '{print $2}' | xargs kill -9
        ps aux |grep x_monitor |awk '{print $2}' | xargs kill -9
        sed -i 's/.*x_manager.*//g' /etc/rc.d/rc.local
    fi

    if [[ $1 == 'show' ]]; then
        ${PATH}/x_reporter.sh 'show'
    fi
}

function monitor(){
    while [[ True ]]
    do
        now_day=`date +%Y-%m-%d`
        now_time=`date +%T`
        if [[ `ps aux |grep -v "grep" | grep 'x_monitor.sh' -v` < 1 ]]; then
            ${PATH}/x_monitor.sh
        fi
        sleep 30
        if [[ `echo ${now_time} | cut -d ':' -f 1` == 8 ]]; then
            ${PATH}/x_reporter.sh 'report'
        fi
    done
}

main $1