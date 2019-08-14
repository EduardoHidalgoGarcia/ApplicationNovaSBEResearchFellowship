import urllib
from textblob import TextBlob
import numpy as np

def getstopwords():
    file = urllib.request.urlopen("https://raw.githubusercontent.com/stanfordnlp/CoreNLP/master/data/edu/stanford/nlp/patterns/surface/stopwords.txt").readlines()
    doclist = [ str(line) for line in file ]
    docstr = '' . join(doclist)
    docstr = docstr.lower()
    docstr = docstr.replace("mrs.", "mrs")
    docstr = docstr.replace("mr.", "mr")
    docstr = docstr.replace("dr.", "dr")
    docstr = docstr.replace("ms.", "ms")
    docstr = docstr.replace("'b'", " ")
    docstr = docstr.replace("\\r", " ")
    docstr = docstr.replace("\\n", " ")
    docstr = docstr.replace('\\\'b', " ")
    docstr = docstr.replace('"', '')
    docstr = docstr.replace("'b", '')
    docstr = docstr.replace("b's ", 'sdsddsdsds')
    docstr = docstr.replace("b'", '')
    docstr = docstr.replace("sdsddsdsds", "b's ")
    docstr = docstr.replace("  ", ' ')
    docstr = docstr.replace("  ", ' ')
    docstr = docstr.replace("  ", ' ')
    docstr = docstr.replace("  ", ' ')
    docstr = docstr.replace(";", '')
    docstr = docstr.replace(",", '')
    docstr = docstr.replace('/s', ' ')
    docstr = docstr.replace('/', ' ')
    docstr = docstr.replace('?', ' ')
    docstr = docstr.replace(')', ' ')
    docstr = docstr.replace('(', ' ')
    docstr = docstr.replace(':', ' ')
    docstr = docstr.replace('--', ' ')
    docstr = docstr.replace('-', ' ')
    return docstr.split(' ')


def nextbigchunk(liston, i, adverbs=False):
    nextchunk=""
    io=i
    while nextchunk=="":
        count=0
        for s in liston:
            if s[0:i]=="".join([" " for j in range(i)]) and (len(s)==i or s[i]!=" ") and s[len(s)-1]!=":":
                count=count+1
                if adverbs==True:
                    if i==len(s) or s[i]!="(":
                        count=count-1
        if count>40:
            nextchunk="".join([" " for j in range(i)])
            flag=0
            sh=0
            j=0
            while flag==0:
                if liston[j][0:i]=="".join([" " for j in range(i)]) and (len(liston[j])==i or liston[j][i]!=" "):
                    sh=sh+1
                    print(liston[j])
                if sh>5:
                    flag=1
                j=j+1
        i=i-1
        if i==0:
            nextchunk="X"
            i=io
        
    return i, nextchunk

def thereslower(p):
    rep=False
    for ch in iter(p):
        if ch.islower():
            rep=True
    return rep

def alllower(p):
    rep=True
    for ch in iter(p):
        if ch.isupper():
            rep=False
    return rep

def getdialogue(magnolia, char1, char2, scenes):
    dialogues=[]
    for s in magnolia.iterrows():
        scn=s[1]['scene']
        if char1 in scenes[scn] and char2 in scenes[scn] and (s[1]['char']==char1 or s[1]['char']==char2):
            dialogues.append(s[1]['dialogue'])
    return dialogues

def maverage(lista,dd,  num):
    lista2=[]
    avg=np.mean(lista)
    for s in lista:
        avg=avg*num+s*(1-num)
        lista2.append(avg)
    return lista2

def smoothing(lista, num):
    lista2=[]
    avg=0
    for s in range(10,len(lista)):
        i=0
        avg=0
        while i<num:
            avg=avg+lista[s-i]/num
            i=i+1
        lista2.append(avg)
    return lista2

def getsentiment(dd):
    polarities=[]
    subjectivities=[]
    for d in dd:
        opinion = TextBlob(d)
        polarities.append(opinion.sentiment[0])
        subjectivities.append(opinion.sentiment[1])
    return polarities, subjectivities