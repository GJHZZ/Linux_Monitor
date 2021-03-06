#!/bin/bash
today=`date +%Y%m%d`
path='/home/blackbox/data'
today_dir="${path}/${today}"

make_today_dir()
{
	if [[ ! -d "${today_dir}" ]]; then
		mkdir -p "${today_dir}"
	fi
	if [[ ! -d "${today_dir}/lsofall" ]]; then
		mkdir -p "${today_dir}/lsofall"
	fi
}

check_lsof()
{
	app_list=`supervisorctl status |awk '{print $1}'`
	for app_name in ${app_list}
	do
		app_file="${today_dir}/lsofall/${app_name}"
		app_status=`supervisorctl status |grep ${app_name} |awk '{print $2}'`
		if [[ "${app_status}" == "RUNNING" ]]; then
			app_pid=`supervisorctl status |grep ${app_name} |awk '{print $4}' |cut -d ',' -f 1`
			app_lsof=`lsof -p ${app_pid} | grep -c ""`
			echo "`date +%y-%m-%d-%H:%M:%S` ${app_name}		PID:${app_pid}  	lsof: ${app_lsof}" >> ${app_file}
		else
			echo "`date +%y-%m-%d-%H:%M:%S` ${app_name}		NOT RUNNING" >> ${app_file}
		fi
	done
}

make_today_dir
check_lsof
