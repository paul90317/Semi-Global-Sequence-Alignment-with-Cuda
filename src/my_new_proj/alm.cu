#include <cstdlib>
#include <iostream>
#include <cstring>
#include "afg_controller.cu"

#define THREAD_SIZE 1024

using namespace std;

__global__ void f(afg_unit** g,int sz){
    afg_unit* tmp=*g;
    printf("bbb\n");
    for(int i=0;i<sz;i++){
        printf("%d %d %d\n",tmp[i].m.score,tmp[i].x.score,tmp[i].y.score);
    }
}
__global__ void g(){
    printf("ccc\n");
    /*for(int i=0;i<sz;i++){
        printf("%d %d %d\n",tmp[i].m.score,tmp[i].x.score,tmp[i].y.score);
    }*/
}
int main(int argc,char** argv){
    
    char*x="123";
    char*y="12345";
    afg_controller ac=afg_controller(x,y,3,5,0);
    printf("aaa\n");
    f<<<1,1>>>(ac.GM,(ac.xsize+2)*3);
    g<<<1,1>>>();
    
}

