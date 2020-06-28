#!/bin/bash
today=`date +%Y%m%d`
path='/home/blackbox/data'
today_dir="${path}/${today}"

make_today_dir()
{
	if [[ ! -d "${today_dir}" ]]; then
		mkdir -p "${today_dir}"
	fi
}

check_pro()
{
	echo -e `date` >> ${today_dir}/process
	echo -e `supervisorctl status` >> ${today_dir}/process
}

make_today_dir
check_pro
