#!/bin/bash
lastAsshole=""
shopt -s nocasematch
while :
do
        sleep 5
        number=$(( ( RANDOM % 1000 ) + 1 ))

        currentAsshole=$(python getShoutbox.py | cut -d":" -f3- | tr -d "'")
        googleIt=$(echo -e "$currentAsshole" | grep -i "how to\|how do" | tail -1)
        
        #Every once in a long while we will just scramble their words and reply.. cause why the fuck not
        if [ "$number" -gt 992 ]; then
                yodaIAm=$(echo -e "$currentAsshole" | tr " " "\n" | sort -R | tr "\n" " ")
                python post.py subv32 password 1 "$yodaIAm"
                continue
        fi
        

        ##Only sometimes will we tell them to fucking google it.. Slightly less than ~50% of the time
        if [ "$number" -lt 500 ]; then
                continue
        else
                if [[ "$googleIt" == *"how to"* ]] || [[ "$googleItAsshole" == *"how do"* ]]; then
                        #If the last message is the current message then we already told them to fucking google it
                        if [[ "$lastAsshole" == "$googleIt" ]]; then
                                continue
                        fi
                        #Remove text "how to" or "how do"
                        googleIt=$(echo -e "$googleIt" | sed s/'how to'// | sed s/'how do'//)
                        
                        #Replace spaces with pluses so it will make a valid google search link
                        googleStuff=$(echo -e "$googleIt" | tr " " "+")
                        
                        #Make search link
                        googleStuff="https://www.google.com/?gws_rd=ssl#q=$googleStuff"
                        python post.py subv32 password 1 "$googleStuff"
                        lastAsshole=$googleIt
                fi
        fi
done
