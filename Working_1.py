from bs4 import BeautifulSoup
import requests 
import csv
import re
import argparse

def getViewCount(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find_all("div", {"class": "watch-view-count"})
    
    for item in g_data:
            views_str = item.contents[0]
     
    views = int(views_str.replace(",", ""))  
    return views

def getLikes(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find_all("button", {"class": "yt-uix-button","title" : "I like this"})
    
    for item in g_data:
            cont = item.contents[0]
    for item in cont:
            likes_str= cont.contents[0]
      
    likes = int(likes_str.replace(",", ""))  
    return likes
    
def getDislikes(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find_all("button", {"class": "yt-uix-button","title" : "I dislike this"})
    
    for item in g_data:
            cont = item.contents[0]
    for item in cont:
            dislikes_str= cont.contents[0]
      
    dislikes = int(dislikes_str.replace(",", ""))  
    return dislikes

def getTitle(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find_all("span", {"id": "eow-title","class" : "watch-title"})
    
    for item in g_data:
           title= item.contents[0].strip()
    
    return title


def getPubDate(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find_all("strong", {"class" : "watch-time-text"})
    
    for item in g_data:
           date_dirt = item.contents[0]
    date_clean = date_dirt.replace("Published on ", "")
    return date_clean
    
def getDesBox(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find_all("p", {"id" : "eow-description"})
    
    for item in g_data:
           des =  item.text
    return des


##work on GetTags
def getTags(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find("meta", {"name":"keywords"})
    wee = g_data.contents[1]
    wee2= wee.find("meta", {"property":"og:video:tag"})
    string = str(wee2.contents[1])
    list2 = string.split("<")
    list3=[]
    for lis in list2:
        if lis == 'meta content="player" name="twitter:card">\n':
            break
        list3.append(lis)
    list3 = list3[1:len(list3)-1]
    for i in range(0,len(list3)):
        list3[i]=list3[i].replace("meta content=\"", "")
        list3[i]=list3[i].replace("\" property=\"og:video:tag\">\n", "")
    
    return list3
    
def getNumSubs(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find("span", {"class":"yt-subscription-button-subscriber-count-branded-horizontal"})           
    return g_data.text.replace(",","")


def getLength(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.find("meta", {"itemprop":"duration"})   
    string = str(g_data)
    x = string.find("S") #finds first instance of S which is the last letter of a ISO Duration String, ex. PT9M0S
    isoduration =  string[15:x+1]
    PT = isoduration.find("T")
    M = isoduration.find("M")
    minutes = isoduration[PT+1:M]
    seconds = isoduration[M+1:len(isoduration)-1]
    return (int(minutes) * 60) + int(seconds)


def getAuthor(link):
    r = requests.get(link)
    soup = BeautifulSoup(r.content)
    g_data = soup.select("#watch7-user-header .spf-link")
    string_g_data = str(g_data)
    indices = [m.start() for m in re.finditer('>', string_g_data)]
    if len(indices) <= 2:
        return ""
    start = indices[len(indices)-2]
    return string_g_data[start+1:len(string_g_data)-5]

"""   
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest ="input")
    parser.add_argument('-o', dest = "output")
    args = parser.parse_args()
    links = []

    print args.input
"""    
links = []
inputfile = "/Users/lavanyasunder1/node_sample.csv"
outputfile = "/Users/lavanyasunder1/node_sample_data.csv"
with open(inputfile, 'rb') as csvfile:
#with open(args.input, 'rb') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    for row in spamreader:
        newstring = str(row)
        newstring = newstring.replace("['","")
        newstring = newstring.replace("']","")
        links.append(newstring)
    
#print args.output         

with open(outputfile, 'w+') as csvfile:
#with open(args.output, 'w+') as csvfile:
    fieldnames = ['link','views', 'title', 'likes', 'dislikes', 'pubdate', 'desbox', 'subs', 'length','tags','author']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    print links
    for i in links:
        try:
            writer.writerow({'link':i, 'views': getViewCount("https://www.youtube.com/watch?v=%s" %(i)),'title': getTitle("https://www.youtube.com/watch?v=%s" %(i)).encode("utf-8"),'likes': getLikes("https://www.youtube.com/watch?v=%s" %(i)),'dislikes': getDislikes("https://www.youtube.com/watch?v=%s" %(i)),'pubdate': getPubDate("https://www.youtube.com/watch?v=%s" %(i)), 'desbox': getDesBox("https://www.youtube.com/watch?v=%s" %(i)).encode("utf-8"), 'subs': getNumSubs("https://www.youtube.com/watch?v=%s" %(i)), 'length': getLength("https://www.youtube.com/watch?v=%s" %(i)), 'tags': getTags("https://www.youtube.com/watch?v=%s" %(i)), 'author':getAuthor("https://www.youtube.com/watch?v=%s" %(i))})
        except Exception,e:
            print str(e)



