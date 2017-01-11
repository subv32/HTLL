import requests
import json

class htll(object):
	def __init__(self, action, apiToken, *args, **kwargs):
		self.action = action
		self.apiToken = apiToken
		self.endpoint="https://hightechlowlife.eu/board/aigle/api/"
		try:
			self.message = kwargs.get('message', None)
		except NameError:
			pass
		if action=="post":
			response=self.postChat(self.message)
			print(response)
		if action=="get":
			self.printListOfList(self.getChat())

	def printListOfList(self, lists):
		a=0
		for i in lists[0]:
			print(lists[0][a] + ": " + lists[1][a])
			a=a+1

	#curl -s -d "token=$htllApiKey&msg=$chatMessage" $htllApiEndPointPost
	def postChat(self, message):
		payload={'token': self.apiToken, 'msg': self.message}
		response=requests.post(self.endpoint, data=payload)
		return response

	def getChat(self):
		getEndpoint=self.endpoint + "?token=" + self.apiToken
		getreq = requests.get(getEndpoint)
		getreq = getreq.json()
		users=[]
		chats=[]
		inBounds=True
		i=0
		try:
			while inBounds:
				user=getreq[i]['user']
				chat=getreq[i]['text']
				users.append(user)
				chats.append(chat)
				i=i+1
		except IndexError:
			inBounds=False
		return(users,chats)
	
	#if __name__ == "__main__":
token=''
#htll('get', token)
#htll('post', token, message="dix")
