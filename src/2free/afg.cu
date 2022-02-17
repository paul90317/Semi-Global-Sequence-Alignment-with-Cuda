#include <cstdlib>
#include <iostream>
#include <cstring>

#include "utils.cuh"
#include "afg_unit.cuh"
#include "config.cuh"
#include "layout.cuh"
#define Y_NOT_END(idy,xsize,ysize) (((idy)-(xsize)-1)<=(ysize))

__global__ void calculate_yfreeStart(afg_unit* M,int* x,int* y,int index_y,res_unit* gbest,int xsize,int ysize) {
    int tid=TID;
    int xid=tid+1;
    int yid=index_y-xid-1;
    if(xid<1||yid<0||xid>xsize||yid>ysize)return;
    M[dimcf(0,xid)].x=M[dimcf(1,xid-1)].to_x();
    M[dimcf(0,xid)].y=M[dimcf(1,xid)].to_y();
    M[dimcf(0,xid)].m=M[dimcf(2,xid-1)].to_m(x[xid],y[yid]);
    if(xid==1){
        M[dimcf(0,xid)].x.ystart=yid+1;
        M[dimcf(0,xid)].m.ystart=yid;
    }
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END||Y_FREE_END&&X_FREE_END){
        M[dimcf(0,xid)].result().xend=xid;
        M[dimcf(0,xid)].result().yend=yid;
        *gbest=max2(*gbest,M[dimcf(0,xid)].result());
    }
}
__global__ void calculate_xyfreeStart(afg_unit* M,int* x,int* y,int index_y,res_unit* gbest,int xsize,int ysize) {
    int xid=TID;
    int yid=index_y-xid-1;
    if(xid<0||yid<0||xid>xsize||yid>ysize)return;
    res_unit zero(0,xid+1,xid,yid+1,yid,false);
    M[dimcf(0,xid)].x=max2(M[dimcf(1,xid-1)].to_x(),zero);
    M[dimcf(0,xid)].y=max2(M[dimcf(1,xid)].to_y(),zero);
    M[dimcf(0,xid)].m=max2(M[dimcf(2,xid-1)].to_m(x[xid],y[yid]),zero);
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END||Y_FREE_END&&X_FREE_END){
        M[dimcf(0,xid)].result().xend=xid;
        M[dimcf(0,xid)].result().yend=yid;
        *gbest=max2(*gbest,M[dimcf(0,xid)].result());
    }
}
__global__ void calculate_fixedStart(afg_unit* M,int* x,int* y,int index_y,res_unit* gbest,int xsize,int ysize) {
    int xid=TID;
    int yid=index_y-xid-1;
    if(xid<0||yid<0||xid>xsize||yid>ysize)return;
    M[dimcf(0,xid)].x=M[dimcf(1,xid-1)].to_x();
    M[dimcf(0,xid)].y=M[dimcf(1,xid)].to_y();
    M[dimcf(0,xid)].m=M[dimcf(2,xid-1)].to_m(x[xid],y[yid]);
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END||Y_FREE_END&&X_FREE_END){
        M[dimcf(0,xid)].result().xend=xid;
        M[dimcf(0,xid)].result().yend=yid;
        *gbest=max2(*gbest,M[dimcf(0,xid)].result());
    }
}
__global__ void calculate_xfreeStart(afg_unit* M,int* x,int* y,int index_y,res_unit* gbest,int xsize,int ysize) {
    int xid=TID;
    int yid=index_y-xid-1;
    if(xid<0||yid<0||xid>xsize||yid>ysize)return;
    M[dimcf(0,xid)].x=M[dimcf(1,xid-1)].to_x();
    M[dimcf(0,xid)].y=M[dimcf(1,xid)].to_y();
    M[dimcf(0,xid)].m=M[dimcf(2,xid-1)].to_m(x[xid],y[yid]);
    if(yid==0){
        M[dimcf(0,xid)].m=0;
    }
    if(yid==1){
        M[dimcf(0,xid)].m.xstart=xid;
        M[dimcf(0,xid)].y.xstart=xid+1;
    }
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END||Y_FREE_END&&X_FREE_END){
        M[dimcf(0,xid)].result().xend=xid;
        M[dimcf(0,xid)].result().yend=yid;
        *gbest=max2(*gbest,M[dimcf(0,xid)].result());
    }
}

int main(int argc,char** argv){
    int *gx_int,*gy_int;
    afg_unit *M,*GM;
    int xsize,ysize;
    int nthread,nblock;
    
    //common
    gscore_matrix_load();

    //讀取
    if(!load_file(&gx_int,&xsize,filename_x)){
        printf("讀不到 x 序列");
        exit(0);
    };
    if(!load_file(&gy_int,&ysize,filename_y)){
        printf("讀不到 y 序列");
        exit(0);
    }

    //宣告最佳解
    res_unit best,last;
    res_unit* gbest;
    cudaMalloc(&gbest,sizeof(res_unit));
    cudaMemcpy(gbest,&best,sizeof(res_unit),cudaMemcpyHostToDevice);
    printf("*Remind: the interval start from 1, not 0\n");

    //挖記憶體
    M=new afg_unit[(xsize+2)*3];
    M+=3;
    cudaMalloc(&GM, 3*(xsize+2)*sizeof(afg_unit));
    GM+=3;

    //分支
    switch(X_FREE_START+Y_FREE_START*2){
    case 0:
    case 1:
    case 3:
        M[dimcf(1,0)].m=0;
        cudaMemcpy(GM-3, M-3, 3*(xsize+2)*sizeof(afg_unit), cudaMemcpyHostToDevice);
        thread_assign(xsize+1,&nblock,&nthread);
        for(int idy=2;Y_NOT_END(idy,xsize,ysize);idy++){
            switch(X_FREE_START+Y_FREE_START*2){
            case 0:calculate_fixedStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,gbest,xsize,ysize);
                break;
            case 1:calculate_xfreeStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,gbest,xsize,ysize);
                break;
            case 3:calculate_xyfreeStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,gbest,xsize,ysize);
                break;
            }
            dim_move(GM,xsize+1);
        }
        break;
    case 2:
        M[dimcf(0,0)].m=0;
        M[dimcf(1,0)].m=0;
        M[dimcf(2,0)].m=0;
        cudaMemcpy(GM-3, M-3, 3*(xsize+2)*sizeof(afg_unit), cudaMemcpyHostToDevice);
        thread_assign(xsize,&nblock,&nthread);
        for(int idy=2;Y_NOT_END(idy,xsize,ysize);idy++){
            calculate_yfreeStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,gbest,xsize,ysize);
            dim_move(GM+3,xsize);
        }
        break;
    }
    //印出結果
    cudaMemcpy(&best,gbest,sizeof(res_unit),cudaMemcpyDeviceToHost);//best score
    cudaMemcpy(&last,GM+dimcf(0,xsize),sizeof(res_unit),cudaMemcpyDeviceToHost);//last
    last.xend=xsize;
    last.yend=ysize;
    best=max2(best,last);
    show_best_and_output_file(best,xsize,ysize);
        
}

