#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

REWARD="$(curl --silent https://whattomine.com/coins/151.json | jq .block_reward)"

printf $REWARD
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
/set desiredReward - set desired reward
/set min - set minimum desired reward
"

while [ 1 ]
do




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
	("/reward") result="$REWARD";;
	(*) result="Unknown command!" ;;
esac

if [[ "$result" ]]; then
#printf "Result:\n$result"
sendtext "$result"
sendtext "proba" "-409969369"
fi

printf "\n\n"
fi


sleep 1

done
