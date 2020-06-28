#!/bin/bash
path='/home/blackbox'
crontab_file(){
	rm -rf /home/blackbox
	ln -s /home/TSS_stability /home/blackbox
        rm -f /etc/cron.d/TSS_stability_monitor
        cat public/public_crontab > /etc/cron.d/TSS_stability_monitor
	/etc/init.d/cron ${1}
}

crontab_file ${1}
