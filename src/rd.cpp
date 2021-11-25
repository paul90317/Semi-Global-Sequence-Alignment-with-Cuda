#include <cstdlib>
#include <iostream>
#include <fstream>

using namespace std;

int r=0;
int myrand(){
    static int times=100000;
    if(times==100000){
        srand(r);
        r++;
        times=0;
    }else{
        times++;
    }
    return rand();
}

int main(int argc,char** argv){
    fstream fout;
    int t,count;
    char nbs[4]={'A','T','C','G'};
    if(argc!=5&&argc!=3){
        cout<<"Follow format: command [x.txt] [count] [y.txt] [count]\n";
        return 0;
    }
    count=strtol(argv[2],NULL,10);
    fout.open(argv[1],ios::out);
    for(int i=0;i<count;i++){
        t=myrand()%4;
        fout<<nbs[t];
    }
    fout.close();
    if(argc==3){
        return 0;
    }
    count=strtol(argv[4],NULL,10);
    fout.open(argv[3],ios::out);
    for(int i=0;i<count;i++){
        t=myrand()%4;
        fout<<nbs[t];
    }
    fout.close();
}