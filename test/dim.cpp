
#include <iostream>
#include "test_time.h"
#include "utils.h"

#define COUNT 100000
#define TIME 10000
//#define dimcf(i,j) ((i)+(j)*COUNT) //far
#define dimcf(i,j) (3*(i)+(j)) //near

void cal(int* M,int count){
    for(int i=0;i<count;i++){
        M[dimcf(i,0)]=M[dimcf(i,1)]+M[dimcf(i,2)];
    }
}

int main(){
    int *M=(int*)malloc(sizeof(int)*COUNT*3);
    time_start();
    for(int i=0;i<TIME;i++){
        cal(M,COUNT);
    }
    time_end();
}