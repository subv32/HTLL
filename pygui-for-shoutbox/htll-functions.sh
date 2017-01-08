#!/bin/bash
IFS=$'\n' 

checkIfInstalled() {
	command -v $1 >/dev/null 2>&1 || { echo "I require $1 but it's not installed.  Aborting." >&2; exit 1; }
}

checkRequirements() {
	checkIfInstalled jq
	checkIfInstalled curl
}


checkForConfigFile() {
	#This is likely the user's first time running this script.. lets see if they meet the requirements to run it
	checkRequirements

        config="htllfunctions-config.sh"

        if [ ! -f $config ]; then
		echo "Creating config file.. "

cat >$config <<EOL
#!/bin/bash

#Set your HTLL Username and Password here
username=''
password=''

#Set your API keys here

#giphyApiKey is only necessary for randomGif() and pullShoutBoxContinously()
giphyApiKey=''

#htllApiKey is necessary for getShoutyUsingApi() and pullShoutBoxContinously(). 
#getShouty() could be used instead of getShoutyUsingApi() with minor editing to pullShoutBoxContinously()
htllApiKey=''

#No need to change these
cookieFile='htll-cookie.txt'
xfTokenCache="xfToken.txt"

EOL
	sleep 2
	vi $config
	exit
	fi
}

setVariables() {
	checkForConfigFile
	source $config 
	loginUrl="https://hightechlowlife.eu/board/login/login"
	giphyApiSearchEndPoint="http://api.giphy.com/v1/gifs/search"
	shoutyUrl="https://hightechlowlife.eu/board/chat/"
	htllApiEndPoint="https://hightechlowlife.eu/board/aigle/api/?token=$htllApiKey"

}

randomGif() {
	#Instead of funny+cat we could do $randomShout 
	if [ -z "$search" ]; then
		search="$1"
	fi
	search=$(echo -e "$search" | tr ' ' '+' | sed 's/^+//')
	req=$( curl -s "$giphyApiSearchEndPoint?q=$search&api_key=$giphyApiKey")
	numberOfResultsReturned=$(echo -e "$req" | jq .data | grep '"id":' | wc -l)

	#Start at 0 not 1
	((numberOfResultsReturned--))

	#Get a number between 0 and 1 minus the number of results returned
	randomNumber=$(shuf -n1 -i0-$numberOfResultsReturned)


	echo -e "$req" | jq .data[$randomNumber].url 

}

checkIfCookieExists() {
	if [ ! -f $cookieFile ]; then
		htllLogin
	fi
}

htllMakeAuthReq() { 
	#Check if we need to get auth'd
	checkIfCookieExists
	#Load the cookie and make the request to the first arg past to this function
	req=$(curl -s -b $cookieFile $1)

}

htllLogin() { 
	#Login and get cookie silently
	loginReq=$(curl -s -c $cookieFile -d "login=$username&password=$password" $loginUrl)

}

getXfToken() {

#Get the xFToken from cache or set it initially
	if [ ! -f $xfTokenCache ]; then
		checkIfCookieExists
		xfToken=$(curl -s -b $cookieFile https://hightechlowlife.eu/board/chat/)
		#Get the line that contains the xfToken
		xfToken=$(echo -e "$xfToken" | grep xfToken)
		#Grab just value="xfToken"
		xfToken=$(echo -e "$xfToken" | grep -ioP "value=\".*?\"")
		#Grab only the first line (there are multiple instances of XfToken)
		xfToken=$(echo -e "$xfToken" | head -1)
		#Clean up the rest 
		xfToken=$(echo -e "$xfToken" | cut -d'"' -f2)
		echo -e "$xfToken" > $xfTokenCache
	else
		xfToken=$(cat $xfTokenCache)
	fi
}

postToChat() {
#Will post the first paramter given to this function to the shoutbox
	getXfToken

	if [ -z "$toPost" ]; then
		toPost="$1"
	fi
	echo "Posting $toPost"
	room=0
	chatPostEndPoint="https://hightechlowlife.eu/board/index.php?chat/submit"
	postData="message=$toPost&room_id=$room&_xfToken=$xfToken"
	curl -s -b $cookieFile -X POST -d "$postData" $chatPostEndPoint

}

getMessages() {
#OLD WAY OF GETTING MESSAGES
#THIS IS LESS EFFICIENT THAN getShoutyUsingApi
	#locating messages
	message=$(echo -e "$req" | grep "siropuChatMessage\">.*</span" | grep -ioP '">.*</span>')

	#Remove some of the info messages
	message=$(echo -e "$message" | grep -v "</a> is our newest member. Welcome!</span>")

	#Remove more of the info messages
	message=$(echo -e "$message" | grep -v "</a> has started a new thread called &quot;<a href=")

	#Stepping to the message
	message=$(echo -e "$message" | cut -d">" -f2- | sed -E 's/<span .*?">//')

	#Get rid of span tags
	message=$(echo -e "$message" | sed 's/<\/span>//g' | sed s'/<span>//g')

	#Convert html apostraphe
	message=$(echo -e "$message" | sed "s/&#039;/'/g")

	#Convert html qoute
	message=$(echo -e "$message" | sed 's/&quot;/"/g')

	#Remove html around links	
	message=$(echo -e "$message" | sed -E 's/<a href=.*?">//' | sed -E 's/<\/a>//')

	#Convert html greater than sign
	message=$(echo -e "$message" | sed 's/&gt;/>/g')
}

getUsernames() { 
#OLD WAY OF GETTING MESSAGES
#THIS IS LESS EFFICIENT THAN getShoutyUsingApi

	usernames=$(echo -e "$req" | grep -v "siropuChatBot" | grep -ioP "data-author=\".*?\">" | cut -d'"' -f2)
}

getShouty() {
#OLD WAY OF GETTING MESSAGES
#THIS IS LESS EFFICIENT THAN getShoutyUsingApi

	#Get current shoutbox
	htllMakeAuthReq $shoutyUrl

	#parse for messages
	getMessages

	#parse for usernames
	getUsernames


	line=1
	
	#print shouty
	for i in $(echo -e "$message"); do
		currentUser=$(echo -e "$usernames" | sed "$line"'!d')
		echo "$currentUser: $i"
		((line++))
	done
}

getShoutyUsingApi() {
	if [ -z "$contentToReturn" ]; then
		contentToReturn=$1
	fi
	#get message and parse the json
        if [ "$contentToReturn" == "all" ]; then
		message=$(curl -s $htllApiEndPoint | jq -r '"\(.user): \(.text)"')
	else
		message=$(curl -s $htllApiEndPoint | jq -r '"\(.user) \(.text)"')
	fi

	#Remove html tags
	message=$(echo -e "$message" | sed -E "s/\[COLOR=#......]|\[USER=(.|..|...|....)\]|\[\/COLOR\]|\[\/URL\]|\[URL\]|\[\/USER\]//g")
	#Reverse the order so it looks more like the shoutbox
	message=$(echo -e "$message" | tac)

	if [ "$contentToReturn" == "user" ]; then
		echo -e "$message" | awk {'print $1'}
	elif [ "$contentToReturn" == "chat" ]; then
		echo -e "$message" | cut -d' ' -f2-
        elif [ "$contentToReturn" == "all" ]; then
		echo -e "$message"
	else
		echo "Invalid paramter used"
	fi
}

pullShoutBoxContinously() {
	checkIfCookieExists

	while :; do

		latestShouty=$(getShoutyUsingApi all)

		if [ -z "$oldShouty" ]; then
			echo -e "$latestShouty"
		fi

		if [ "$latestShouty" != "$oldShouty" ]; then
			if [ -n "$oldShouty" ]; then
				lastLineOfOldShouty=$(echo -e "$oldShouty" | tail -1)

				locationOfLastLineinNewShouty=$(echo -e "$latestShouty" | grep -n "$lastLineOfOldShouty" | cut -f1 -d:)
				newShouts=$(echo -e "$latestShouty" | sed '1,'"$locationOfLastLineinNewShouty"'d')
		#		echo -e "$newShouts"

				for i in $(echo -e "$newShouts"); do 
					echo "$i"
					if [ 3 -gt $(shuf -n1 -i1-10) ]; then
						if [[ "$i" != *"GIPHY"* ]]; then
							searchFriendly=$(echo "$i" | cut -d ":" -f2)
							echo $searchFriendly
							gifURL=$(randomGif $searchFriendly)
							gifURL=$(echo -e "$gifURL" | tr -d '"')
							echo "GIPHY: $gifURL" 
							postToChat "GIPHY: $searchFriendly - $gifURL"
						fi
					fi
				done
			fi
		fi
		sleep 2
		oldShouty="$latestShouty"
	done
}


debugArgs() {
	echo "funct: $funct"
	echo "chatMessage: $chatMessage"
	echo "helpme: $helpme"
	echo "getReturnValue: $getReturnValue"
}

availableFunctions() {
	cat $0 | grep -ioP "^.*?() {$" | sed 's/{//'
}


helpThem() {
cat <<help
bash $0 [options]

-h, --help see this screen
-f,  --function the function to use
	to see more info try running -f availableFunctions
	example usage: --function availableFunctions
-m --message the chat message to send. Should be used with --function postToChat
	example usage:  --function postToChat --message "example chat message"
-g, --get determines the content that getShoutyUsingApi() returns
	Valid options:  --get user returns only usernames 
			--get chat returns only the chat
			--get all returns usernames and chat 
	example usage: --function getShoutyUsingApi --get all
-s, --search the gif keyword to search for when used for randomGif()
	example usage: --function randomGif --search "Funny Cats"

If no options provided then pullShoutBoxContinously() will be executed

Examples:
bash $0 --function postToChat --message "this will end up in the htll shoutbox"
bash $0 --function randomGif --search "funny cats"
bash $0 --function getShoutyUsingApi --get all

help
}

argParse() {
#This function is always the first function to execute
setVariables
	if [ -z "$1" ]; then
		pullShoutBoxContinously
	fi

	if [[ "$1" == *"-h"* ]]; then 
		helpThem
		exit
	fi


	while [[ $# -gt 1 ]]
	do
		key="$1"
		case $key in
			-f|--function)
				funct="$2"
				shift # past argument
			;;
			-m|--message)
				chatMessage="$2"
				shift # past argument
			;;
			-g|--get)
				getReturnValue="$2"
				shift
			;;
			-s|--search)
				search="$2"
				shift
			;;
			*)
			# unknown option
			;;
		esac
		shift # past argument or value
	done

	if [ -n "$chatMessage" ]; then
		toPost=$chatMessage
	fi

	if [ -n "$getReturnValue" ]; then
		contentToReturn=$getReturnValue
	fi

	if [ -n "$funct" ]; then
		functionReturn=$($funct)
		echo -e "$functionReturn"
	fi

}

argParse $@

