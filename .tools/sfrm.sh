#!/bin/bash
DATE_TIME_PATH=/trash/$(date +%y%m%d)/$(date +%H%M) 
SFRM_PATH=$(cd $(dirname $1);pwd)

if [[  -d /trash/$(date +%y%m%d) ]]; then
	if [[ ! -d /trash/$(date +%y%m%d)/$(date +%H%M) ]]; then
		mkdir  /trash/$(date +%y%m%d)/$(date +%H%M)
	fi
else
	mkdir -p /trash/$(date +%y%m%d)/$(date +%H%M)
fi
cp -r $SFRM_PATH $DATE_TIME_PATH
rm -rf $SFRM_PATH/* 
