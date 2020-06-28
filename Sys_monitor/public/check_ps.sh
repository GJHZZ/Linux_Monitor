#!/bin/bash
today=`date +%Y%m%d`
path='/home/blackbox/data'
today_dir="${path}/${today}"

make_today_dir()
{
	if [[ ! -d "${today_dir}" ]]; then
		mkdir -p "${today_dir}"
	fi
	# if [[ ! -d "${today_dir}/lsofall" ]]; then
	# 	mkdir -p "${today_dir}/lsofall"
	# fi
}

check_ps()
{
	date >> "${today_dir}/ps"
	ps -axu >> "${today_dir}/ps"

}

make_today_dir
check_ps
