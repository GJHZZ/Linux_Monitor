#!/bin/bash
path='/home/blackbox/data'

delolddate(){
  year=`date +%Y`
  cd /home/blackbox
  `find ${path}/ -mtime +1 -type d -name "*$year*" -exec rm -rf {} \;`
}
delolddate
