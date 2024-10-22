#!/bin/bash

start() {
	if [ -e ./.pid.txt ];
	then echo "Мониторинг уже запущен"
	else
		monitoring_process &
		pid=$!
		echo "Мониторинг хранилища запущен с PID: $pid"
		echo $pid > ./.pid.txt
	fi
}

stop() {
	if [ -e ./.pid.txt ];
	then
		pid=$(cat ./.pid.txt)
		if ps -p "$pid";
		then
			kill "$pid"
			rm ./.pid.txt
			echo "Мониторинг хранилища остановлен"
		else
			echo "Мониторинг хранилища не запущен"
		fi
	else
		echo "Мониторинг хранилища не запущен"
	fi
}

status() {
	if [ -e ./.pid.txt ];
	then
		pid=$(cat ./.pid.txt)
		if ps -p "$pid";
		then
			echo "Мониторинг хранилища запущен (PID = $pid)"
		else
			echo "Мониторинг хранилища не запущен"
		fi
	else
		echo "Мониторинг хранилища не запущен"
	fi
}

monitoring_process() {
	rm -fr monitoring_csv
	mkdir -p monitoring_csv
	echo "Time,Filesystem,Size,Used,Avail,Use%,Mounted on,Inodes" > "monitoring_csv/monitoring-`date +"%Y-%m-%d"`.csv"
	while true; do
		time=$(date +%Y-%m-%d\ %H:%M)
		df_h=$(df -h | tail -n +2)
		df_hi=$(df -hi | tail -n +2)
		paste <(echo "$df_h") <(echo "$df_hi") | awk -v time="$time" '{print time "," $0}' >> "monitoring_csv/monitoring-`date +"%Y-%m-%d"`.csv"        
		sleep 60
	done
}


case "$1" in
	START)
		start
		;;
	STOP)
		stop
		;;
	STATUS)
		status
		;;
	*)
		echo "Неверно передан аргумент (введите START, STOP или STATUS)"
esac
