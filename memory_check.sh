#!/bin/bash
TOTAL_MEMORY=$( free | grep Mem: | awk '{ print $2 }' )
echo $TOTAL_MEMORY
USED_MEMORY=$( free | grep Mem: | awk '{ print $3 }' )
echo $USED_MEMORY
percentage=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }')
#percentage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
echo $percentage

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
			echo "-e used: $email"
			;;
		w)
			w=$OPTARG
			echo "-w used: $w"
			;;
		c)
			c=$OPTARG
			echo "-c used: $c"
			;;
		\?)
			echo "unrecognized option"
			exit 0
			;;
	esac
done
shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

if [ $w -ge $c ]
	then
		echo "Warning threshold must be less than critical threshold."
		exit 0
fi

#2: used memory is greater than or equal to critical threshold
#1: used memory is greater than or equal to warning threshold but less than than critical threshold
#0: used memory is less than warning threshold

if [ $percentage -ge $c ] 
	then
		#send top 10 processes with process ids that use a lot of memory to specified email address
		#subject: YYYYMMDD HH:MM memory check - critical
		DATE=`date +%Y-%m-%d`
		TIME=`date +"%H:%M"`
		mail -s "$DATE $TIME memory check - critical" $email
		echo "$DATE $TIME"
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