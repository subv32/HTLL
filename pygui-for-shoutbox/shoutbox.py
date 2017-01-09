import tkinter as tk
import tkinter.scrolledtext as tkst
from tkinter import font
import os
import time
import re
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
		self.oldBox = self.getCurrentBox("all")
		self.printBox()

	def print_contents(self, event):

		command="bash htll-login.sh --function postToChatApi --message \"" + str(self.userinput.get()) + "\""
		#print(command)
		os.system(command)
		self.shoutinput.delete('0','end')
	def printBox(self):
		self.newBox=self.getCurrentBox("all")
		if self.newBox != self.oldBox:
			strNewChat=str(self.newBox)
			strOldChat=str(self.oldBox)

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
#			print(changesChat)
#			numberOfChatChanges=len(changesChat.split('\n'))

			username=re.sub("[^[[A-Z]\|[a-z]]\d]", "", re.search("^[^:]*", changesChat).group(0))
			message=re.search(":.*$", changesChat).group(0)

			self.shoutbox.insert(tk.INSERT, username, 'boldFont')
			self.shoutbox.insert(tk.INSERT, message, 'normalFont')
			self.shoutbox.insert(tk.INSERT, "\n")
			#	a=a+1
		self.shoutbox.see(tk.END)
		self.oldBox=self.newBox
		self.after(2000, self.printBox)
		#self.printBox
	def getCurrentBox(self, getparam):
		self.currentBox= tk.StringVar()
		self.currentBox.set(os.popen("bash htll-login.sh --function getShoutyUsingApi --get " + str(getparam)).read())
		return self.currentBox.get()

root = tk.Tk()
root.title("shitty htll shoutbox application")
app = Application(master=root)
app.mainloop()
