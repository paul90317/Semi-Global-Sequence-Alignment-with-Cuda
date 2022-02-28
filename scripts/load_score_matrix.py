import json
from multiprocessing.sharedctypes import Value

score={
    "chars":["A","T","G","C"],
    "matrix":[
        [1,-1,-1,-1],
        [-1,1,-1,-1],
        [-1,-1,1,-1],
        [-1,-1,-1,1]
    ],
    "gap":-2,
    "extension":-1
}

with open("temp/score.txt","w") as f:
    n=len(score["chars"])
    f.write(str(n)+'\n')
    for c in score["chars"]:
        f.write(str(c)+' ')
    f.write('\n')
    for l in score["matrix"]:
        for i in l:
            f.write(str(i)+' ')
        f.write('\n')
    f.write(str(score["gap"])+'\n')
    f.write(str(score["extension"]))