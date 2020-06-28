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

check_df()
{
	date >> "${today_dir}/df"
	df -h >> "${today_dir}/df"
}

make_today_dir
check_df
