DIR="$(dirname "$(readlink -f "$0")")"

if [ -z "$STY" ]; then
printf "Bot started in background\n"
screen -S reward_updater -X quit > /dev/null
exec screen -dm -S reward_updater /bin/bash $0
fi


while [ 1 ]
do

curl --silent https://whattomine.com/coins/151.json | jq .block_reward > $DIR/../global_vars/.current_reward
sleep 120

done
