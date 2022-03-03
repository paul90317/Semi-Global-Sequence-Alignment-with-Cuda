import matrix_transformer
import os

from matrix_transformer import mkdir

matrix_transformer.transform("score.json","temp/score.txt")

mkdir("temp")

for pair in os.listdir("tasks"):
    print(f'-----------{pair}------------')
    cmd=".\\cpu.exe \"tasks\\{0}\\x.txt\" \"tasks\\{0}\\y.txt\" temp\\score.txt"\
        .format(pair)
    print(cmd)
    os.system(cmd)