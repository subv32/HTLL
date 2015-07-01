#!/bin/bash
lastAsshole=""
shopt -s nocasematch
while :
do
        currentAsshole=$(python getShoutbox.py | cut -d":" -f3- | tr -d "'")
        currentAsshole=$(echo -e "$currentAsshole" | grep -i "how to\|how do" | tail -1)
        if [[ "$lastAsshole" == "$currentAsshole" ]]; then
                continue
        fi

        if [[ "$currentAsshole" == *"how to"* ]] || [[ "$currentAsshole" == *"how do"* ]]; then
                googleStuff=$(echo -e "$currentAsshole" | tr " " "+")
                googleStuff="https://www.google.com/?gws_rd=ssl#q=$googleStuff"
                python post.py subv32 password 1 "$googleStuff"
                lastAsshole=$currentAsshole
        fi
        sleep 5
done

