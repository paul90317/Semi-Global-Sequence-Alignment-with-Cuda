import os
import shutil

if os.path.isdir("temp"):
    shutil.rmtree("temp")
os.mkdir("temp")

for pair in os.listdir("tasks"):
    if os.path.isdir(f"tasks/{pair}/out"):
        shutil.rmtree(f"tasks/{pair}/out")