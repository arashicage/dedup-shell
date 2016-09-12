#! /bin/bash

IFS=$'\n'
arr=($(redis-cli -p 6379 -c scan 0 count 200))

x=1
while :
do
	# 处理key
	for i in $(seq 1 `expr ${#arr[@]} - 1` )
	do
	  fields=($(redis-cli -c hkeys ${arr[$i]} |grep ^h|sort))
	  
	  echo $x ${arr[$i]} ${fields[@]}
		
	  x=`expr $x + 1`
	  
	done	

	# 遍历完了
	if [ ${arr[0]} -eq 0 ]; then
	  	break
	else
		arr=($(redis-cli -p 6379 -c scan ${arr[0]} count 200))
	fi

done