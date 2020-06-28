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

check_free()
{
	date >> "${today_dir}/free"
	free -m >> "${today_dir}/free"
}

make_today_dir
check_free
