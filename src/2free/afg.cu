#include <cstdlib>
#include <iostream>
#include <cstring>
#include "../common/afg_unit.cu"
#include "../common/score4.cu"
#include "../common/dim.cu"

#define BUF_SIZE_Y 10000
#define THREAD_SIZE 1024

using namespace std;

__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,char* x,char* y,int buf_mover,int index_y,res_unit* gbest,int xsize) {
    int t=threadIdx.x+blockDim.x*blockIdx.x;
    M[t+1].x=M1[t].to_x();
    M[t+1].y=M1[t+1].to_y();
    M[t+1].m=M2[t].to_m(x[t]==y[buf_mover-t]);
    if(t==0){
        M[t+1].x.start=index_y+1;
        M[t+1].m.start=index_y;
    }
    if(t+1==xsize){
        M[t+1].result().end=index_y-t;
        *gbest=max2(*gbest,M[t+1].result());
    }
    return;
}

__global__ void gmemset(int* m,int val) {
    int t=threadIdx.x+blockDim.x*blockIdx.x;
    m[t+1]=val;
}

int main(int argc,char** argv){
    FILE* file;
    char *x,*y;
    int *gx_int,*gy_int,*x_int,*y_int;
    afg_unit *M,*GM;
    int xsize,ysize,index_y;
    int nthread,nblock;
    if(argc!=3){
        cout<<"Follow format: command [x.txt] [y.txt]\n";
        return 0;
    }
    //common
    gscore_matrix_load();

    //讀取 x
    file=fopen(argv[1],"r");
    fseek(file,0,SEEK_END);
    xsize=ftell(file);
    fseek(file,0,SEEK_SET);
    x=new char[xsize+1];
    fgets(x,xsize+1,file);
    fclose(file);
    x_int=new int[xsize+1];
    x_int[0]=-1;
    for(int i=0;i<xsize;i++){
        x_int[i+1]=mapping_DNA(x[i]);
    }
    cudaMalloc(&gx_int,sizeof(int)*(xsize+1));
    cudaMemset(gx_int,-1,sizeof(int));
    cudaMemcpy(gx_int+1,x_int,sizeof(int)*xsize,cudaMemcpyHostToDevice);
    //讀取 y
    file=fopen(argv[2],"r");
    fseek(file,0,SEEK_END);
    ysize=ftell(file);
    fseek(file,0,SEEK_SET);
    y=new char[ysize+1];
    fgets(y,ysize+1,file);
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
    index_y=0;

    M[0].m=0;
    M1[0].m=0;
    M2[0].m=0;

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

    //分段讀取並運算
    res_unit best;
    res_unit* gbest;
    cudaMalloc(&gbest,sizeof(res_unit));
    cudaMemcpy(gbest,&best,sizeof(res_unit),cudaMemcpyHostToDevice);
    while(true){
        //可平行化運算
        while(buf_mover<BUF_SIZE_Y&&index_y<ysize){
            calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx,gy,buf_mover,index_y,gbest,xsize);
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
        calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx,gy,buf_mover,index_y,gbest,xsize);
        cudaMemcpy(GM2+1, GM1+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
        cudaMemcpy(GM1+1, GM+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
        buf_mover++;
        index_y++;
    }

    //取出結果
    cudaMemcpy(&best,gbest,sizeof(res_unit),cudaMemcpyDeviceToHost);//best score
    printf("%d %d %d",best.score,best.start,best.end);
}

