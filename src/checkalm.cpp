#include <cstdlib>
#include <iostream>
#include <cstring>

using namespace std;

int main(int argc,char* argv[]){
    char buf[10];
    FILE* fp;
    int sc=0,status=0;
    if(argc!=2){
        printf("please follow format: [alm.txt]\n");
        return 0;
    }
    fp=fopen(argv[1],"r");
    while(fgets(buf,10,fp)){
        if(buf[0]==buf[2]){
            status=0;
            sc++;
        }else if(buf[0]=='-'){
            if(status==1){
                sc-=1;
            }else{
                sc-=2;
            }
            status=1;
        }else if(buf[2]=='-'){
            if(status==2){
                sc-=1;
            }else{
                sc-=2;
            }
            status=2;
        }else{
            sc--;
            status=0;
        }
    }
    printf("%d\n",sc);
}