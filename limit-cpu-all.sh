#!/bin/bash

arr=()
for OUTPUT in $(/usr/bin/ps -ax | grep cpulimit | grep -v grep | awk '{print $10}')
do
	arr+=($OUTPUT)
done

whoami=`/usr/bin/whoami`
for PID in $(/usr/bin/ps -aux | grep $whoami | grep -v cpulimit | grep -v "limit-cpu-all.sh" | grep -v grep | awk '{print $2}')
do
	cpuusage=`ps -p $PID -o %cpu | grep -v CPU`
	if [ "$cpuusage" == "" ]; then
		continue
	fi

	compare=`echo | awk "{ print (10 < $cpuusage)?1 : 0 }"`

	if [ $compare -eq 1 ]; then
		echo -n "$PID $cpuusage "
		isexisted="Belum"
		for LIMITEDPID in ${arr[@]}
		do
			if [ "$LIMITEDPID" == "$PID" ]; then
				isexisted="Sudah"
				break
			fi
		done
		echo $isexisted
		if [ "$isexisted" == "Belum" ]; then
			echo "lanjut"
			/usr/bin/cpulimit -b -l 17 -p $PID
		fi
	fi
done
