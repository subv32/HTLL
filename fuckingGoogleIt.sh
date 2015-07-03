#!/bin/bash
lastShout=""
randomFire=0
shopt -s nocasematch
while :
do
        sleep 5
        number=$(( ( RANDOM % 1000 ) + 1 ))

        currentShout=$(python getShoutbox.py | cut -d":" -f3- | tr -d "'")

        googleIt=$(echo -e "$currentShout" | grep -i "how to\|how do" | tail -1)

        #If the last message is the current message then we already told them to fucki$
        if [[ "$lastShout" == "$currentShout" ]] || [[ $randomFire -eq 1 ]]; then
                continue
        fi

        lastShout=$currentShout 
        #Every once in a long while we will just scramble their words and reply.. cause why the fuck not
        if [ "$number" -gt 990 ]; then
                randomSortedShout=$(echo -e "$currentShout" | tail -1 | tr " " "\n" | sort -R | tr "\n" " ")
                python post.py subv32 password 1 "$randomSortedShout"
                randomFire=1
                continue
        fi

        randomFire=0
     

        ##Only sometimes will we tell them to fucking google it.. Slightly less than ~50% of the time
        if [ "$number" -lt 500 ]; then
                continue
        else
                if [[ "$googleIt" == *"how to"* ]] || [[ "$googleIt" == *"how do"* ]]; then
                        googleIt=$(echo -e "$googleIt" | sed s/'how to'// | sed s/'how do'//)
                        googleStuff=$(echo -e "$googleIt" | tr " " "+")
                        googleStuff="https://www.google.com/?gws_rd=ssl#q=$googleStuff"
                        python post.py subv32 password 1 "$googleStuff"
                fi
        fi
done
