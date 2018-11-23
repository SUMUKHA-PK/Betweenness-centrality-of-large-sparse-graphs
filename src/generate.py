import numpy as np
import random

d=[370,370]
n = 1200 #Preset number of edges in graph
a=np.zeros(shape=(n),dtype=int)
c=np.zeros(shape=(n),dtype=int)
b=np.zeros(shape=(d[0]+1),dtype=int)

for i in range(len(a)):
    a[i]=i

for i in range(len(c)):
    c[i]=i

b[0]=0
x=n
i=len(b)-1
while(i>4):
    b[i]=x
    x-=1
    i-=1
    b[i]=x
    x-=2
    i-=1
    b[i]=x
    x-=3
    i-=1
    b[i]=x
    x-=4
    i-=1
    b[i]=x
    x-=5
    i-=1

with open('demo1.txt', 'w') as f:
    for item in a:
        f.write("%s " % item)
    f.write("\n")
    for item in b:
        f.write("%s " % item)
    f.write("\n")
    for item in c:
        f.write("%s " % item)
    f.write("\n")
    f.write("%s " % d[0])
    f.write("%s" % d[1])
