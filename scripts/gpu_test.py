import matrix_transformer
import os

from matrix_transformer import mkdir

matrix_transformer.transform("score.json","temp/score.txt")

mkdir("temp")

def run_alm(pair,intv):
    cmd=".\\alignment.exe \"tasks\\{0}\\x.txt\" \"tasks\\{0}\\y.txt\" temp\\best.txt temp\\score.txt \"tasks\\{0}\\out\\alm\\{1}.txt\""\
        .format(pair,intv)
    print(cmd)
    os.system(cmd)
        
for pair in os.listdir("tasks"):
    print(f'-----------{pair}------------')
    mkdir(f"tasks/{pair}/out")
    mkdir(f"tasks/{pair}/out/alm")
    cmd=".\\semi_interval.exe \"tasks\\{0}\\x.txt\" \"tasks\\{0}\\y.txt\" tasks\\{0}\\out\\best.txt temp\\score.txt"\
        .format(pair)
    print(cmd)
    os.system(cmd)
    with open(f"tasks/{pair}/out/best.txt","r") as f:
        intvs=f.readlines()
        for intv in intvs:
            print('---------------------------')
            with open("temp/best.txt","w") as fw:
                fw.write(intv)
            run_alm(pair,intv.replace(' ','-').replace('\n',''))
