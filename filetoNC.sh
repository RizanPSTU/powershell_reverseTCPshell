file=$1
port=$2

function ncEcho {
	sleep 10.5
	echo "$1"
	sleep 1
	echo "exit"
}

filestr="$(base64 $file)"
output="rec-file $filestr"
ncEcho "$output" | tee /dev/tty | nc -l $port
