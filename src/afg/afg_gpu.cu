#include <cstdlib>
#include <iostream>
#include <cstring>
#include "afg_unit_gpu.h"

#define BUF_SIZE_Y 10000
#define THREAD_SIZE 1024

using namespace std;

__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,char* x,char* y,int buf_mover,int index_y,int* maxs,int* init_idy,int* last_idy) {
    int t=threadIdx.x+blockDim.x*blockIdx.x;
    M[t+1].x=M1[t].gto_x();
    M[t+1].y=M1[t+1].gto_y();
    M[t+1].m=M2[t].gto_m(x[t]==y[buf_mover-t]);
    M[t+1].xstart=M1[t].start_x(index_y-t,t);
    M[t+1].ystart=M1[t+1].start_y();
    M[t+1].mstart=M2[t].start_m(index_y-t,t);
    init_idy[t+1]=M[t+1].bests_idy(maxs[t+1],init_idy[t+1]);
    last_idy[t+1]=M[t+1].bests_lastidy(maxs[t+1],last_idy[t+1],index_y-t);
    maxs[t+1]=max2(maxs[t+1],M[t+1].gresult());
    return;
}

__global__ void gmemset(int* m,int val) {
    int t=threadIdx.x+blockDim.x*blockIdx.x;
    m[t+1]=val;
}

int main(int argc,char** argv){
    FILE* file;
    char *x,*y,*gx,*gy,*oldgy,*nextgy;
    afg_unit *M,*M1,*M2,*GM,*GM1,*GM2;
    int xsize,buf_mover,tmp,nthread,nblock,nsize,index_y,*gmaxs,*init_idy,*last_idy,ysize;

    if(argc!=3){
        cout<<"Follow format: command [x.txt] [y.txt]\n";
        return 0;
    }

    //讀取 x
    file=fopen(argv[1],"r");
    fseek(file,0,SEEK_END);
    xsize=ftell(file);
    fseek(file,0,SEEK_SET);
    x=new char[xsize+1];
    fgets(x,xsize+1,file);
    fclose(file);

    //初始化 cuda 參數
    nthread=min(xsize,THREAD_SIZE);
    nblock=xsize/THREAD_SIZE;
    if(xsize%THREAD_SIZE)nblock++;
    nsize=nblock*nthread;

    //動態規劃 M
    M=new afg_unit[nsize+1];
    M1=new afg_unit[nsize+1];
    M2=new afg_unit[nsize+1];

    //讀取 y buffer
    y=new char[BUF_SIZE_Y+1];
    file=fopen(argv[2],"r");
    fseek(file,0,SEEK_END);
    ysize=ftell(file);
    fseek(file,0,SEEK_SET);
    fgets (y , BUF_SIZE_Y+1 , file);// 讀 BUF_SIZE_Y 個

    //初始化 M
    buf_mover=0;
    index_y=1;

    M1[0].y=0;
    M2[0].y=0;

    M2[1].x=SCORE_G;
    M1[2].x=SCORE_G+SCORE_E;

    M1[1].m=afg_unit::equal(x[0]==y[buf_mover++]);
    M1[1].y=M2[1].to_y();
    M1[1].x=M2[0].to_x();

    M1[1].mstart=0;
    M1[1].xstart=0;
    M1[1].ystart=0;

    //GPU COPY
    cudaMalloc(&GM, (nsize+1)*sizeof(afg_unit));
    cudaMalloc(&GM1, (nsize+1)*sizeof(afg_unit));
    cudaMalloc(&GM2, (nsize+1)*sizeof(afg_unit));
    
    cudaMemcpy(GM, M, (nsize+1)*sizeof(afg_unit), cudaMemcpyHostToDevice);
    cudaMemcpy(GM1, M1, (nsize+1)*sizeof(afg_unit), cudaMemcpyHostToDevice);
    cudaMemcpy(GM2, M2, (nsize+1)*sizeof(afg_unit), cudaMemcpyHostToDevice);

    cudaMalloc(&gx, nsize*sizeof(char));
    cudaMemset(gx, 0, nsize*sizeof(char));
    cudaMemcpy(gx, x, xsize*sizeof(char), cudaMemcpyHostToDevice);

    cudaMalloc(&gy, (BUF_SIZE_Y+nsize+xsize-1)*sizeof(char));
    cudaMemset(gy, 0, (BUF_SIZE_Y+nsize+xsize-1)*sizeof(char));
    oldgy=gy;
    nextgy=gy+BUF_SIZE_Y;
    gy=gy+nsize;
    cudaMemcpy(gy, y, BUF_SIZE_Y*sizeof(char), cudaMemcpyHostToDevice);//???

    cudaMalloc(&gmaxs, (nsize+1)*sizeof(int));
    tmp=NEG_INF;
    cudaMemcpy(gmaxs+xsize,&tmp,sizeof(int),cudaMemcpyHostToDevice);

    cudaMalloc(&init_idy, (nsize+1)*sizeof(int));
    cudaMalloc(&last_idy, (nsize+1)*sizeof(int));

    //分段讀取並運算
    while(true){
        //可平行化運算
        while(buf_mover<BUF_SIZE_Y&&index_y<ysize){
            calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx,gy,buf_mover,index_y,gmaxs,init_idy,last_idy);
            cudaMemcpy(GM2+1, GM1+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
            cudaMemcpy(GM1+1, GM+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
            buf_mover++;
            index_y++;
        }
        
        //讀取 buffer
        if(fgets (y , BUF_SIZE_Y+1 , file)==NULL)break;
        //左移並寫入 buffer
        cudaMemcpy(oldgy, nextgy, nsize*sizeof(char),cudaMemcpyDeviceToDevice);
        buf_mover=0;
        cudaMemcpy(gy, y, BUF_SIZE_Y*sizeof(char),cudaMemcpyHostToDevice);
    };

    fclose(file);
    
    while (index_y<ysize+xsize-1)
    {
        calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx,gy,buf_mover,index_y,gmaxs,init_idy,last_idy);
        cudaMemcpy(GM2+1, GM1+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
        cudaMemcpy(GM1+1, GM+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
        buf_mover++;
        index_y++;
    }

    //取出結果
    cudaMemcpy(&tmp,gmaxs+xsize,sizeof(int),cudaMemcpyDeviceToHost);//best score
    printf("%d ",tmp);
    cudaMemcpy(&tmp,init_idy+xsize,sizeof(int),cudaMemcpyDeviceToHost);//inital index
    printf("%d ",tmp);
    cudaMemcpy(&tmp,last_idy+xsize,sizeof(int),cudaMemcpyDeviceToHost);//last index
    printf("%d",tmp);
}

