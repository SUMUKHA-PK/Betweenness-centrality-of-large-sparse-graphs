import numpy as np
import random

d=[10000000,10000000]
n = 5*10000000 #Preset number of edges in graph
a=np.zeros(shape=(n),dtype=object)
c=np.zeros(shape=(n),dtype=object)
b=np.zeros(shape=(d[0]+1),dtype=object)

for i in range(len(a)):
    a[i]=1

for i in range(len(c)):
    c[i]=random.randint(0,1000)%d[0]

x=0
y=n//d[0]

for i in range(1,len(b)):
    b[i]=b[i-1]+y

b[len(b)-1]=b[len(b)-2]+n-(n//d[0])*(d[0]-1)    

with open('power7.csr', 'w') as f:
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
