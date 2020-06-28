#!/bin/bash
PATH=`pwd`
CHECK_STEP=5

function get_time(){
    now_date=`date +%Y-%m-%d`
    now_time=`date +%T`
    now_year=`echo ${now_date} | cut -d '-' -f 1`
    now_month=`echo ${now_date} | cut -d '-' -f 2`
    now_day=`echo ${now_date} | cut -d '-' -f 3`
    now_hour=`echo ${now_time} | cut -d ':' -f 1`
    now_min=`echo ${now_time} | cut -d ':' -f 2`
    now_sed=`echo ${now_time} | cut -d ':' -f 3`
}

function runner(){
    ${PATH}/runner/check_${1}.sh &
    get_time
    sed -i "s/^run_${1}.*/run_${1} `date +%T`/g" ${PATH}/config
}

function check_run(){
    for i in `cat config |awk '{print $1}' | grep 'step' | cut -d '_' -f 2`
    do
        get_time
        check_time=`cat ${PATH}/config | grep "step_${i}" | awk '{print $2}'`
        check_hour=`echo ${check_time} | cut -d ':' -f 1`
        check_min=`echo ${check_time} | cut -d ':' -f 2`
        check_sed=`echo ${check_time} | cut -d ':' -f 3`

        run_time=`cat ${PATH}/config |grep "run_${i}" | awk '{print $2}'`
        run_hour=`echo ${run_time} | cut -d ':' -f 1`
        run_min=`echo ${run_time} | cut -d ':' -f 2`
        run_sed=`echo ${run_time} | cut -d ':' -f 3`

        if [[ ${check_hour} != 0 ]]; then
            if [[ $((now_hour-run_hour)) > $((check_hour-1)) ]]; then
                runner ${i}
            fi
        fi

        if [[ ${check_min} != 0 ]]; then
            if [[ $((now_min-run_min)) > $((check_min-1)) ]]; then
                runner ${i}
            fi
        fi

        if [[ ${check_sed} != 0 ]]; then
            if [[ $((now_sed-run_sed)) > $((check_sed-1)) ]]; then
                runner ${i}
            fi
        fi
    done
}

function main(){
    while [[ Ture ]]
    do
        sleep ${CHECK_STEP}
        check_run
        if [[ `ps aux | grep -v "grep" | grep -c "x_manager"` < 1 ]]; then
            ${PATH}/x_manager.sh
        fi
    done
}

main &