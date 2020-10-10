#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/setup.conf
source $DIR/sendtext.func


if [ -z "$STY" ]; then
printf "Bot started in background\n"

screen -S reward_updater -X quit > /dev/null
exec screen -dm -S reward_updater /bin/bash $0
fi


while [ 1 ]
do


curl --silent https://whattomine.com/coins/151.json | jq .block_reward > $DIR/../global_vars/.current_reward

CURRENT_REWARD=`cat $DIR/../global_vars/.current_reward`
AUTO_SWITCH=`cat $DIR/../global_vars/.pool_auto_switch`
DESIRED_REWARD=`cat $DIR/../global_vars/.desired_reward`
DESIRED_POOL=`cat $DIR/../global_vars/.desired_pool`
CURRENT_POOL=`cat $DIR/../global_vars/.current_pool`



if [ $CURRENT_REWARD > $DESIRED_REWARD ]; then

    sendtext "Current Reward is greater than the Desired Reward! Probably you would like to switch the pool?"

    if [ $AUTO_SWITCH == "ON" ] && [ $CURRENT_POOL != $DESIRED_POOL ]; then

        # sendtext "/switch all ethpool $DESIRED_POOL" $second_group_id
        # sendtext "Desired reward is met. Attempt was made to switch the pool!" $second_group_id

        # change the current pool to match the desired pool
        # echo $DESIRED_POOL > $DIR/../global_vars/.current_pool

    fi
fi



sleep 600

done
