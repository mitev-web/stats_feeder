#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"


#Default data
AUTO_SWITCH="OFF"
DESIRED_REWARD=4
DESIRED_POOL="0x75adc2df801b6b9d9f5cfc57a9de46da435d204f"


source $DIR/setup.conf

sendtext() {


	if [[ "$2" ]]; then
		curl -X POST https://api.telegram.org/bot$api_key/sendMessage -d chat_id=$2 -d text="$1" >/dev/null 2>&1 ;
		else
		curl -X POST https://api.telegram.org/bot$api_key/sendMessage -d chat_id=$chat_id -d text="$1" >/dev/null 2>&1 ;
	fi

}


if [ -z "$STY" ]; then
printf "Bot started in background\n"
screen -S stats_bot -X quit > /dev/null
exec screen -dm -S stats_bot /bin/bash $0
fi


help_section="
/help - Prints this text
/reward - Check current ETH Block Reward
/auto_switch - Switch automatically the pool when desired reward is met
/set-desired-reward - set desired reward
/set-desired-pool - set desired reward
"

while [ 1 ]
do

REWARD=`cat $DIR/../global_vars/.current_reward`
printf $REWARD




curr_message=`curl --silent -s "https://api.telegram.org/bot$api_key/getUpdates?timeout=600&offset=$update_id"`
last_upd_id=`printf "$curr_message" |  jq '.result | .[] | .update_id' | tail -1`

if [[ $update_id -le $last_upd_id ]]; then
update_id=$((last_upd_id+1))

curr_message_text=`printf "$curr_message" | jq -r '.result | .[].message.text' | tail -1`

if [[ "$curr_message_text" ]]; then
printf "Message received: $curr_message_text\n"
# clear last message
curl -s "https://api.telegram.org/bot$api_key/getUpdates?offset=$update_id"  >/dev/null 2>&1
fi

command=`echo $curr_message_text | grep -o '\/.*' | awk {'print $1'} | sed "s|@$username||g"`
arg=`echo $curr_message_text | awk {'print $2" "$3" "$4'}`

case "$command" in
	("") ;;
	("/test") result="test PASS!" ;;
	("/help") result="$help_section" ;;
	("/set-desired-reward") DESIRED_REWARD=$arg ;;
	("/reward") result="$REWARD";;
	(*) result="Unknown command!" ;;
esac

if [[ "$result" ]]; then
#printf "Result:\n$result"
sendtext "$result"

sendtext "Desired reward is $DESIRED_REWARD"
sendtext "Desired pool is $DESIRED_POOL"
sendtext "Autoswitch is set to $AUTO_SWITCH"


fi

printf "\n\n"
fi


sleep 5

done
