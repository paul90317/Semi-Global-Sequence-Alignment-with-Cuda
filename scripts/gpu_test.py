from sys import argv
import matrix_transformer
import os

from matrix_transformer import mkdir
from matrix_transformer import command_call

mkdir("temp")

matrix_transformer.transform("score.json","temp/score.txt")


def run_alm(pair,intv):
    cmd="./alignment.out \"tasks/{0}/x.txt\" \"tasks/{0}/y.txt\" temp/best.txt temp/score.txt \"tasks/{0}/out/alm/{1}.txt\""\
        .format(pair,intv)
    print(cmd)
    command_call(cmd)
        
for pair in os.listdir("tasks"):
    print(f'-----------{pair}------------')
    mkdir(f"tasks/{pair}/out")
    mkdir(f"tasks/{pair}/out/alm")
    cmd="./semi_interval.out \"tasks/{0}/x.txt\" \"tasks/{0}/y.txt\" \"tasks/{0}/out/best.txt\" temp/score.txt"\
        .format(pair)
    print(cmd)
    command_call(cmd)
    if len(argv)>=2 and argv[1]=="-a":
        with open(f"tasks/{pair}/out/best.txt","r") as f:
            intvs=f.readlines()
            for intv in intvs:
                print('---------------------------')
                with open("temp/best.txt","w") as fw:
                    fw.write(intv)
                run_alm(pair,intv.replace(' ','-').replace('\n',''))
