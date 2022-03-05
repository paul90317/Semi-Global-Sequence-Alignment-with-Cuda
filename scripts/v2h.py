from sys import argv
if __name__=='__main__':
    if len(argv)!=2:
        print('Error: follow format => python v2h.py [alignment.txt]')
        exit(0)
    bufx=''
    bufy=''
    l=0
    with open(argv[1]) as f:
        while True:
            line=f.readline()
            if len(line)==0:
                break
            bufx+=line[0]
            bufy+=line[2]
            l+=1
            if l==50:
                print(bufx)
                print(bufy)
                print()
                l=0
                bufx=''
                bufy=''
    print(bufx)
    print(bufy)
            