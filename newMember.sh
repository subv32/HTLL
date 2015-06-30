#!/bin/bash
#This script announces a new member..
newMember=""
firstRound=0
while :
do
        req=$(curl -s https://hightechlowlife.eu/board/forums/)
        member=$(echo -e "$req" | grep -E 'dd.*username.*dl' | cut -d">" -f3 | cut -d"<" -f1)
        if [[ firstRound -eq 0 ]]; then
                firstRound=1
                newMember=$member
                continue
        fi

        if [[ "$newMember" == "$member" ]]; then 
                sleep 100
                continue
        else
                newMember=$member
                memlink=$(echo -e "$req" |  grep -E 'dd.*username.*dl' | cut -d"/" -f2)
                memberMessage="Welcome to our new member! [url=https://hightechlowlife.eu/board/members/$memlink/]$newMember[/url]"
                python post.py subv32 password 1 "$memberMessage"
        fi
done

