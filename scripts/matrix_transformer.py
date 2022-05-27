import json
import os
from sys import argv
import subprocess

def command_call(command:str):
    result=subprocess.getoutput(command)
    print(result)

def mkdir(dir):
    if not os.path.isdir(dir):
        os.mkdir(dir)

def transform(fjson,ftxt):
    if os.path.isfile(fjson):
        with open(fjson,"r") as f:
            score=json.load(f)
    else:
        print(f"Error: can't load score matrix in {fjson}")
        exit(0)
    print(f"Transfrom {fjson} to {ftxt}.")
    with open(ftxt,"w") as f:
        chars=score['chars']
        rchars=[]
        for ch in chars:
            if type(ch)==str:
                rchars+=[ch]
            else:
                for i in range(ord(ch['l']),ord(ch['r'])+1):
                    rchars+=[chr(i)]

        n=len(rchars)
        f.write(str(n)+'\n')
        for c in rchars:
            f.write(str(c))
        f.write('\n')
        matrix=score['matrix']
        if type(matrix)==list:
            for l in matrix:
                for i in l:
                    f.write(str(i)+' ')
                f.write('\n')
        else:
            match=matrix['match']
            miss=matrix['miss']
            for i in range(n):
                for j in range(n):
                    if i==j:
                        f.write(str(match)+' ')
                    else:
                        f.write(str(miss)+' ')
                f.write('\n')
        f.write(str(score["gap"])+'\n')
        f.write(str(score["extension"]))


if __name__=='__main__':
    if len(argv)!=3:
        print("Error: follow format => python matrix_transformer.py [score.json] [score.txt]")
        exit(0)
    transform(argv[1],argv[2])



