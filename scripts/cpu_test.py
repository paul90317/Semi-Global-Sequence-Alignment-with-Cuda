import load_score_matrix
import os
        
for pair in os.listdir("tasks"):
    print(f'-----------{pair}------------')
    cmd=".\\cpu.exe \"tasks\\{0}\\x.txt\" \"tasks\\{0}\\y.txt\" temp\\score.txt"\
        .format(pair)
    print(cmd)
    os.system(cmd)
