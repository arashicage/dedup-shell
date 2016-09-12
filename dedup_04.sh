#! /bin/bash

if [ $# -eq 0 ]; then
	echo "usage: "
	echo "	./dedup port"
	echo "ex:	./dedup 6379"
	exit
fi

IFS=$'\n'
arr=($(redis-cli -p $1 -c scan 0 match 04:* count 10000))

# echo $1
# echo ${arr[@]}
echo ${#arr[@]}

if [ ${#arr[@]} -le 0 ]; then
	echo ">>> connection fail, exit."
	exit
fi

while :
do
	# echo "next scan:" ${arr[0]}
	# echo "how many:" `expr ${#arr[@]} - 1`
	# 处理key

	# 如果arr 含有key
	if [ ${#arr[@]} -ge 2 ]; then
		for i in $(seq 1 `expr ${#arr[@]} - 1` )
		do
			echo ">>> processing key [" ${arr[$i]} "]"
			old_fields=($(redis-cli -c hkeys ${arr[$i]} |grep ^h|grep -v ^h0|sort))
			new_fields=($(redis-cli -c hkeys ${arr[$i]} |grep ^h|grep ^h0|sort))
		  
			echo ">>> old fields: [" ${old_fields[@]} "]"
			echo ">>> new fields: [" ${new_fields[@]} "]"
		  
			for field in ${old_fields[@]}
			do
		  	
			  	field_with_prefix_zero="h"$(echo ${field:1} |awk '{printf("%04d\n",$0)}')
			  	echo "... processing field [" $field "]with the opposite new field as [" $field_with_prefix_zero "]"
				if [[ "${new_fields[@]}" =~ $field_with_prefix_zero ]]; then
					echo "... new field exits, removing the old field [" $field "]"
					redis-cli -p $1 -c hdel ${arr[$i]} $field > /dev/null
				# else
					# echo "new field is not exits, nothing to do"
				fi
			done
		done	
	fi

	# 遍历完了
	if [ ${arr[0]} -eq 0 ]; then
	  	echo ">>> [ scan finished ]"
	  	break
	else
		arr=($(redis-cli -p $1 -c scan ${arr[0]} match 04:* count 10000))
	fi

done