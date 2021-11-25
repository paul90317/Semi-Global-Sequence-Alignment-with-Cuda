#include <cstdlib>
#include <iostream>
#include <cstring>
#include "afg_unit.h"

#define BUF_SIZE 100000000

using namespace std;

int main(int argc,char** argv){
    FILE* file;
    char *x=new char[BUF_SIZE];
    char *y=new char[BUF_SIZE];
    char *oldy;
    afg_unit *M,*M1;
    int xsize,buf_mover,best;

    if(argc!=3){
        cout<<"Follow format: command [x.txt] [y.txt]\n";
        return 0;
    }

    y+=BUF_SIZE/2;// y is really a buffer
    file=fopen(argv[1],"r");
    fgets(x,BUF_SIZE,file);
    fclose(file);
    xsize=strlen(x);
    oldy=y-xsize;
    M=new afg_unit[xsize+1];
    M1=new afg_unit[xsize+1];

    //初始化
    M1[0].m=0;
    M1[1].x=afg_unit::g;
    M[0].y=0;
    for(int i=2;i<=xsize;i++){
        M1[i].x=M1[i-1].to_x();
    };

    //分段讀取並運算 y buffer
    buf_mover=0;
    file=fopen(argv[2],"r");
    best=NEG_INF;
    while(fgets (y , xsize+1 , file)){
        //可平行化運算
        while (buf_mover<xsize)
        {
            for(int i=1;i<=xsize;i++){
                M[i].m=M1[i-1].to_m(x[i-1]==y[buf_mover]);
                M[i].x=M[i-1].to_x();
                M[i].y=M1[i].to_y();
            }
            
            best=max2(best,M[xsize].result());
            
            for(int i=1;i<=xsize;i++){
                M1[i]=M[i];
            }
            buf_mover++;
        }

        //更新 buffer
        memcpy(oldy,y,xsize); // don't copy '\0'
        memset(y,0,xsize);// 讓多餘字元變 0
        buf_mover=0;
    }
    cout<<best<<"\n";
}

