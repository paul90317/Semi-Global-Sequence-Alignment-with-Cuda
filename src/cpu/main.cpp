#define CPU

#include <cstdlib>
#include <iostream>
#include <cstring>
#include "comm.cuh"
#include "afg_unit.h"

#define dimcf(st,i) ((st)+(i)*2)

int* load_file(int* size,const char* filename){
    FILE* file=fopen(filename,"r");
    if(file==NULL)return NULL;
    fseek(file,0,SEEK_END);
    *size=ftell(file);
    fseek(file,0,SEEK_SET);
    int* x_int=oalloc<int>(*size+1);
    x_int[0]=0;
    int j=0;
    char c;
    while(c=my_get_ch(file),c!=EOF){
        byte b=score::char2byte(c);
        if(b==(byte)-1){
            printf("Error: Char [%c] not found!!\n",c);
            exit(0);
        }
        x_int[j+1]=b;
        j++;
    }
    *size=j;
    fclose(file);
    return x_int;
}

int main(int argc,char** argv){
    int *x,*y;
    int xsize,ysize;
    std::cout<<"\n";
    if(argc!=4){
        std::cout<<"error: follow format: cpu.exe <x.txt> <y.txt> <score.txt>\n";
        exit(0);
    }
    if(!score::load(argv[3])){
        std::cout<<"error: can't load score matrix in "<<argv[3]<<"\n";
        exit(0);
    }else{
        std::cout<<"score matrix: "<<argv[3]<<"\n";
    }
    x=load_file(&xsize,argv[1]);
    y=load_file(&ysize,argv[2]);
    if(!x||!y){
        std::cout<<"error: can't open sequence file.\n";
        return 0;
    }
    std::cout<<"sequence X: "<<argv[1]<<"\n";
    std::cout<<" - size: "<<xsize<<"\n";
    std::cout<<"sequence Y: "<<argv[2]<<"\n";
    std::cout<<" - size: "<<ysize<<"\n";

    afg_unit* M=new afg_unit[2*(xsize+2)];
    M+=2;

    mytime::start();
    //初始化
    M[dimcf(0,0)].m=0;
    for(int i=1;i<=xsize;i++){
        M[dimcf(0,i)].x=M[dimcf(0,i-1)].to_x();
    }

    //運算
    for(int j=1;j<=ysize;j++){
        for(int i=0;i<=xsize;i++){
            M[dimcf(1,i)]=M[dimcf(0,i)];
        }
        for(int i=0;i<=xsize;i++){
            M[dimcf(0,i)].y=M[dimcf(1,i)].to_y();
            M[dimcf(0,i)].x=M[dimcf(0,i-1)].to_x();
            M[dimcf(0,i)].m=M[dimcf(1,i-1)].to_m(y[j],x[i]);
        }
    }
    
    mytime::end();
    std::cout<<"[OUTPUT]\n";
    datatype best=M[dimcf(0,xsize)].result();
    std::cout<<"best score: "<<best<<"\n";
}

