import load_score_matrix
import os

def run_alm(pair,intv):
    cmd=".\\out\\alignment.exe \"tasks\\{0}\\x.txt\" \"tasks\\{0}\\y.txt\" temp\\best.txt temp\\score.txt \"tasks\\{0}\\out\\alm\\{1}.txt\""\
        .format(pair,intv)
    print(cmd)
    os.system(cmd)

def mkdir(dir):
    if not os.path.isdir(dir):
        os.mkdir(dir)
        
for pair in os.listdir("tasks"):
    print(f'-----------{pair}------------')
    mkdir(f"tasks/{pair}/out")
    mkdir(f"tasks/{pair}/out/alm")
    cmd=".\\out\\semi_interval.exe \"tasks\\{0}\\x.txt\" \"tasks\\{0}\\y.txt\" tasks\\{0}\\out\\best.txt temp\\score.txt"\
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
