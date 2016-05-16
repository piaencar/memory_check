#!/bin/bash
TOTAL_MEMORY=$( free | grep Mem: | awk '{ print $2 }' )
#echo $TOTAL_MEMORY
USED_MEMORY=$( free | grep Mem: | awk '{ print $3 }' )
#echo $USED_MEMORY
percentage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
#echo $percentage

email=""
c=0
w=0

if [ $# -eq 0 ]; then
  echo "please supply the valid parameters (-e, -c, -w)"
  exit 0
fi

while getopts e:w:c: opt; do
	case "$opt" in
		e)
			email=$OPTARG
			#echo "-e used: $email"
			;;
		w)
			w=$OPTARG
			#echo "-w used: $w"
			;;
		c)
			c=$OPTARG
			#echo "-c used: $c"
			;;
		\?)
			echo "unrecognized option"
			exit 0
			;;
	esac
done
shift $((OPTIND-1))

if [ $w -ge $c ]
	then
		echo "Warning threshold must be less than critical threshold."
		exit 0
fi

if [ $percentage -ge $c ] 
	then
		#send top 10 processes with process ids that use a lot of memory to specified email address
		#subject: YYYYMMDD HH:MM memory check - critical
		DATE=`date +%Y%m%d`
		TIME=`date +"%H:%M"`
		processes=$(ps -eo pmem,pid,cmd | sort -k1 -nr | head -n 10)
		#this assumes that mail has been installed
		echo "$processes" | mail -s "$DATE $TIME memory check - critical" $email
		echo "$processes"
		echo "sent an email on $DATE at $TIME"
		exit 2
	elif [ $percentage -ge $w ]
		then
			echo "warning"
			exit 1
		else
			echo "safe"
			exit 0
	fi
fi