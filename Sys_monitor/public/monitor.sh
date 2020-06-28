#!/bin/bash
path='/home/blackbox/data'
NEW_FILE="${path}/monitor.new"
OLD_FILE="${path}/monitor.old"
Version_name="tss-1.0.0"

check_mem()
{
    app_list=`supervisorctl status |awk '{print $1}'`
    for app_name in ${app_list}
    do
        app_status=`supervisorctl status|grep ${app_name} |awk '{print $2}'`
        if [[ "${app_status}" == "RUNNING" ]]; then
            app_pid=`supervisorctl status |grep ${app_name} |awk '{print $4}' |cut -d ',' -f 1`
            mem=`pmap -x ${app_pid} |grep total|awk '{print $4}'`
            echo "${app_name}   ${mem}"
        else
            echo "${app_name}   NORUN"
        fi
    done
}

check_time(){
    app_list=`supervisorctl status |awk '{print $1}'`
    for app_name in ${app_list}
    do
        app_status=`supervisorctl status|grep ${app_name} |awk '{print $2}'`
        if [[ "${app_status}" == "RUNNING" ]]; then
            app_pid=`supervisorctl status |grep ${app_name} |awk '{print $4}' |cut -d ',' -f 1`
            app_time=`ps -eo pid,etime | grep ${app_pid} | awk '{print $2}'`
            echo "${app_name}   ${app_time}"
        else
            echo "${app_name}   NORUN"
        fi
    done
}

check_lsof(){
    app_list=`supervisorctl status |awk '{print $1}'`
    for app_name in ${app_list}
    do
        app_status=`supervisorctl status|grep ${app_name} |awk '{print $2}'`
        if [[ "${app_status}" == "RUNNING" ]]; then
            app_pid=`supervisorctl status |grep ${app_name} |awk '{print $4}' |cut -d ',' -f 1`
            app_lsof=`lsof -p ${app_pid} | grep -c ""`
            echo "${app_name}   ${app_lsof}"
        else
            echo "${app_name}   NORUN"
        fi
    done
}

check_log()
{
    check_mem > ${path}/memnew
    check_time > ${path}/timenew
    check_lsof > ${path}/lsofnew
    df -h > ${path}/dfnew
    free -m > ${path}/freenew
}

compare_log()
{
    file1="${path}/${1}new"
    file2="${path}/${1}old"
    file3="${path}/${1}temp"
    file4="${path}/${1}end"
    if [ $1 == "df" ];then
        sed -i 's/on//g' $file1
        awk '{$1="";$2="";$6="";$7="";print $0}' $file2 >$file3
        sed -i '1s/\<\([A-Z]\)/Y-\1/g' $file3
        paste -d "\t" $file1 $file3| column -t >> $NEW_FILE
    elif [ $1 == "free" ];then
        cat $file1 >> $NEW_FILE
        echo '-------------------yesterday----------------------------------------------' >> $NEW_FILE
        cat $file2 >> $NEW_FILE
    else
        awk '{$1="";print $0}' $file2 >$file3
        paste -d "\t" $file1 $file3 > $file2
        if [ $1 != "time" ];then
            awk 'NR==FNR {if($2>$3){$4="***"};print}' $file2 |column -t >> $NEW_FILE
        else
            awk 'NR==FNR {if((length($2)<=length($3))&&($2<$3)) {$4="***"};print}' $file2 |column -t >> $NEW_FILE
        fi
    fi
    
    rm -f $file3
	
}

record_log()
{
    if [[ ! -f $OLD_FILE ]] ; then 
        echo '===================process status=====================================================' > $NEW_FILE
        ps aux | grep -e " Z" -e " D" >> $NEW_FILE
        echo '-------------------process memory,KB,today yesterday----------------------------------' >> $NEW_FILE
        cat ${path}/memnew >> $NEW_FILE
    	echo '-------------------process time,today yesterday---------------------------------------' >> $NEW_FILE
        cat ${path}/timenew >> $NEW_FILE
        echo '-------------------process lsof,today yesterday---------------------------------------' >> $NEW_FILE
        cat ${path}/lsofnew >> $NEW_FILE
        echo '-------------------disk statistic,today yesterday-------------------------------------' >> $NEW_FILE
        cat ${path}/dfnew >> $NEW_FILE
        echo '-------------------system memory,today yesterday--------------------------------------' >> $NEW_FILE
        cat ${path}/freenew >> $NEW_FILE
        echo '===================END!===============================================================' >> $NEW_FILE 
    else
        echo '===================process status=====================================================' > $NEW_FILE
        ps aux | grep -e " Z" -e " D" >> $NEW_FILE
        echo -e '\n-------------------process memory,KB,today yesterday----------------------------------' >> $NEW_FILE
        compare_log mem
        echo -e '\n-------------------time,today yesterday-----------------------------------------------' >> $NEW_FILE
        compare_log time
        echo -e '\n-------------------lsof,today yesterday-----------------------------------------------' >> $NEW_FILE
        compare_log lsof
        echo -e '\n-------------------disk,today yesterday-----------------------------------------------' >> $NEW_FILE
        compare_log df
        echo -e '\n\n+++++++++++++++++++system memory++++++++++++++++++++++++++++++++++++++++++++++++++++++' >> $NEW_FILE
        echo '-------------------today------------------------------------------------' >> $NEW_FILE
        compare_log free
        echo '===================END!===============================================================' >> $NEW_FILE 
    fi
	
    content=`cat ${NEW_FILE}` 
    mv $NEW_FILE $OLD_FILE
    str="mem time lsof df free"
    for i in $str
    do
        mv ${path}/${i}new ${path}/${i}old 
    done

    dirname="${path}/$Version_name"
    if [ ! -d $dirname ];then
        mkdir -p $dirname
    fi
    time=`date +%Y%m%d`
    cp $OLD_FILE ${dirname}/monitor-$time
}


check_log
record_log
