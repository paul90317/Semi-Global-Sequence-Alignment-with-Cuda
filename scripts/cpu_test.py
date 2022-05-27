import matrix_transformer
import os

from matrix_transformer import mkdir
from matrix_transformer import command_call

matrix_transformer.transform("score.json","./temp/score.txt")

mkdir("./temp")

for pair in os.listdir("tasks"):
    print(f'-----------{pair}------------')
    cmd="./cpu.out \"tasks/{0}/x.txt\" \"tasks/{0}/y.txt\" temp/score.txt"\
        .format(pair)
    print(cmd)
    command_call(cmd)
