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

check_cpu()
{
	date >> "${today_dir}/cpu"
	top -b -d 1 -n1 >> "${today_dir}/cpu"
	echo -e "\n\n" >> "${today_dir}/cpu"
}

make_today_dir
check_cpu
