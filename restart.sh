#!/bin/bash --

declare -a servers
declare -a pids

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

readarray dirs < $scriptdir/dirs.txt
avalondir=$([[ ${dirs[0]} =~ [[:space:]]*([^[:space:]]|[^[:space:]].*[^[:space:]])[[:space:]]* ]]; echo -n "${BASH_REMATCH[1]}")
implementationsdir=$([[ ${dirs[1]} =~ [[:space:]]*([^[:space:]]|[^[:space:]].*[^[:space:]])[[:space:]]* ]]; echo -n "${BASH_REMATCH[1]}")
keyfile=$([[ ${dirs[2]} =~ [[:space:]]*([^[:space:]]|[^[:space:]].*[^[:space:]])[[:space:]]* ]]; echo -n "${BASH_REMATCH[1]}")

if [[ $1 == 't2' ]]; then
	echo "Restarting config-t2 servers"
	readarray servers < $scriptdir/config-t2_servers.txt
else
	echo "Restarting config servers"
	readarray servers < $scriptdir/config_servers.txt
fi

for i in "${servers[@]}"
do
	trimmed=$([[ $i =~ [[:space:]]*([^[:space:]]|[^[:space:]].*[^[:space:]])[[:space:]]* ]]; echo -n "${BASH_REMATCH[1]}")
	if [[ ! -z $trimmed  ]]; then
		echo "Restarting server: $trimmed"
		ssh -i $keyfile -oStrictHostKeyChecking=no -p 2222 ec2-user@$trimmed "sudo /etc/init.d/node restart" &
		pids[${#pids[@]}]=$!
	fi
done

for i in "${pids[@]}"
do
	echo "Checking SSH Session: $i"
	while kill -0 $i &> /dev/null
	do
		sleep 0.1
	done
done

echo "All servers restarted"