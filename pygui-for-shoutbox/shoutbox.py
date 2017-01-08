import tkinter as tk
import tkinter.scrolledtext as tkst
from tkinter import font
import os
import time
class Application(tk.Frame):
	def __init__(self, master=None):
		super().__init__(master)
		self.pack()
		self.create_widgets()

	def create_widgets(self):
		self.shoutbox = tkst.ScrolledText(self, width=100)
		self.shoutbox.pack()
		self.shoutbox.tag_config("boldFont", font=('', 12, 'bold'))
		self.shoutbox.tag_config("normalFont",font=('', 12, 'normal'))
		self.currentShoutBoxUsers= tk.Text()
		self.currentShoutBoxChat = tk.Text()
		self.users=self.getCurrentBox("user")
		self.chat=self.getCurrentBox("chat")
		#self.currentShoutBoxUsers.insert(tk.INSERT, str(self.users), "boldFont")
		#self.currentShoutBoxChat.insert(tk.INSERT, str(self.chat), "normalFont")

		self.shoutinput = tk.Entry(width=89)
		self.shoutinput.pack()
		self.userinput = tk.StringVar()
		self.shoutinput["textvariable"] = self.userinput
		self.shoutinput.bind('<Key-Return>', self.print_contents)

		a=0
		for i in self.users.split('\n'):
			if i == "":
				continue
			self.shoutbox.insert(tk.INSERT, i + ": ", 'boldFont')
			try:
				self.shoutbox.insert(tk.INSERT, self.chat.splitlines()[a], 'normalFont')
			except:
				pass
			self.shoutbox.insert(tk.INSERT, "\n")
			a=a+1
		self.shoutbox.see(tk.END)
		self.oldChat = self.chat
		self.oldUsers = self.users
		self.printBox()
	def print_contents(self, event):
		print(self.userinput.get())

		command="bash  htll-functions.sh --function postToChat --message \"" + str(self.userinput.get()) + "\""
		print(command)
		os.system(command)
		self.shoutinput.delete('0','end')
	def printBox(self):
		self.newChat=self.getCurrentBox("chat")
		self.newUsers=self.getCurrentBox("user")
		if self.newUsers != self.oldUsers:
			strNewUsers=str(self.newUsers)
			strNewChat=str(self.newChat)

			strOldUsers=str(self.oldUsers)
			strOldChat=str(self.oldChat)

			strNewChatL=[]
			for i in strNewChat.split("\n"):
				strNewChatL.append(i)
			strNewChatL.reverse()
			lastLineInOldChat=strOldChat.splitlines()[-1]
			changesChat=[]
			for i in strNewChatL:
				if i == lastLineInOldChat:
					break
				changesChat.append(i)
				#print("adding " + i + " to changesChat")
			changesChat = format("\n".join(changesChat[1:]))

			numberOfChatChanges=len(changesChat.split('\n'))

			strNewUsersL=[]
			for i in strNewUsers.split("\n"):
				strNewUsersL.append(i)
			strNewUsersL.reverse()

			print(strNewUsersL)
			changesUsers=[]
			print(numberOfChatChanges)
			totalUsers=0
			for i in strNewUsersL:
				if totalUsers > numberOfChatChanges:
					break
				totalUsers=totalUsers+1
				changesUsers.append(i)

			print(changesUsers)
			#Convert changeUsers and changesChat back into strs
		#	print(changesUsers)
			changesUsers = format("\n".join(changesUsers[1:]))
			print(changesUsers)

			#changesChat=strNewChat.split(strOldChat.splitlines()[-1], 1)[1]
			#changesUsers=strNewUsers.split(strOldUsers.splitlines()[-1], 1)[1]
#			print(changesUsers)
#			print(changesChat)

			#self.shoutbox.insert(tk.INSERT, changes.rstrip())
			#self.shoutbox.see(tk.END)
			a=0
			for i in changesUsers.split('\n'):
				if i == "":
					continue
				self.shoutbox.insert(tk.INSERT, i + ": ", 'boldFont')
				try:
					self.shoutbox.insert(tk.INSERT, changesChat.splitlines()[a], 'normalFont')
				except:
					pass
				self.shoutbox.insert(tk.INSERT, "\n")
				a=a+1
		self.shoutbox.see(tk.END)
		self.oldUsers=self.newUsers
		self.oldChat=self.newChat
		self.after(2000, self.printBox)
	def getCurrentBox(self, getparam):
		self.currentBox= tk.StringVar()
		self.currentBox.set(os.popen("bash htll-functions.sh --function getShoutyUsingApi --get " + str(getparam)).read())
		return self.currentBox.get()

root = tk.Tk()
root.title("shitty htll shoutbox application")
app = Application(master=root)
app.mainloop()
