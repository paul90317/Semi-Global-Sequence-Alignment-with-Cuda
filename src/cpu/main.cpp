#include <cstdlib>
#include <iostream>
#include <cstring>
#include "afg_unit.h"
#include "test_time.h"

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
    while(c=getc(file),c!=EOF){
        if((c>'z'||c<'a')&&(c<'A'||c>'Z')&&(c<'0'||c>'9'))continue;
        x_int[j+1]=mapping_Char(c);
        j++;
    }
    *size=j;
    fclose(file);
    return x_int;
}

int main(int argc,char** argv){
    int *x,*y;
    int xsize,ysize;
    x=load_file(&xsize,filename_x);
    y=load_file(&ysize,filename_y);
    if(!x||!y){
        std::cout<<"can't open file.\n";
        return 0;
    }
    afg_unit* M=new afg_unit[2*(xsize+2)];
    M+=2;

    time_start();
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
    
    time_end();
    datatype best=M[dimcf(0,xsize)].result();
    std::cout<<"Best global alignment score: "<<best<<"\n";
}

