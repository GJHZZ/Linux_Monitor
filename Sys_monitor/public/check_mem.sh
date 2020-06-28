#!/bin/bash
today=`date +%Y%m%d`
path='/home/blackbox/data'
today_dir="${path}/${today}"

make_today_dir()
{
	if [[ ! -d "${today_dir}" ]]; then
		mkdir -p "${today_dir}"
	fi
	if [[ ! -d "${today_dir}/mem" ]]; then
		mkdir -p "${today_dir}/mem"
	fi
}

check_mem()
{
	app_list=`supervisorctl status |awk '{print $1}'`
	for app_name in ${app_list}
	do
		app_file="${today_dir}/mem/${app_name}"
		app_status=`supervisorctl status|grep ${app_name} |awk '{print $2}'`
		if [[ "${app_status}" == "RUNNING" ]]; then
			app_pid=`supervisorctl status |grep ${app_name} |awk '{print $4}' |cut -d ',' -f 1`
			mem=`pmap -x ${app_pid} |grep total|awk '{print $4}'`
			allmem=`pmap -x ${app_pid} |grep total|awk '{print $3}'`
			echo "`date +%y-%m-%d-%H:%M:%S` ${app_name} 	mem: ${allmem} KB     ${mem}  KB " >> ${app_file}
		else
			echo "`date +%y-%m-%d-%H:%M:%S` ${app_name}		NOT RUNNING" >> ${app_file}
		fi
	done
}

make_today_dir
check_mem
