#!/usr/bin/env python                                               
#This script posts to the shoutbox
# ./post.py username password room(if you dont know what this is then use 1) message
import re                                                           
import sys                                                          
import json                                                         
import requests                                                     
import random                                                       
from time import sleep                                              
from bs4 import BeautifulSoup                                       

room = 1                                                            
(username, password) = sys.argv[1:3]                                                                                                      
if sys.argv[3]:
    room = sys.argv[3]
regex = re.compile(r'name="_xfToken" value="([^"]+)"')

session = requests.session()
res = session.post("https://hightechlowlife.eu/board/login/login", params={"login": username, "password": password})
res = session.get ("https://hightechlowlife.eu/board/forums")

token = regex.findall(res.text)[0]

params = {
    "sidebar": 0,
    "lastrefresh": 0,
    "fake": 0,
    "room": room,
    "_xfRequestUri": "/board/forums/",
    "_xfNoRedirect": 1,
    "_xfToken": token,
    "_xfResponseType": "json"
}

res = session.post("https://hightechlowlife.eu/board/taigachat/list.json", params=params)
result = json.loads(res.text)
params["lastrefresh"] = result["lastrefresh"]

res = session.post("https://hightechlowlife.eu/board/taigachat/list.json", params=params)
result = json.loads(res.text)
params["lastrefresh"] = result["lastrefresh"]
soup = BeautifulSoup( result["templateHtml"] )
res = session.post("https://hightechlowlife.eu/board/taigachat/post.json", params=dict(params, message=sys.argv[4], color='FFFFFF'))
