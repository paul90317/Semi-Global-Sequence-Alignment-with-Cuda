#ifndef AFG_CONTROLER_H
#define AFG_CONTROLER_H

#include "afg_unit_gpu.h"
#define THREAD_SIZE 1024

__global__ void initM_uf(afg_unit* GM,afg_unit* GM1,afg_unit* GM2,int cnt){
    int tid=threadIdx.x+blockDim.x*blockIdx.x;
    if(tid>=cnt)return;
    GM[tid].m=NEG_INF;
    GM[tid].x=NEG_INF;
    GM[tid].y=NEG_INF;
    GM1[tid].m=NEG_INF;
    GM1[tid].x=NEG_INF;
    GM1[tid].y=NEG_INF;
    GM2[tid].m=NEG_INF;
    GM2[tid].x=NEG_INF;
    GM2[tid].y=NEG_INF;
}
__global__ void initM_mf(afg_unit* GM1,int l,bool xgap){
    if(xgap){
        GM1[l-1].y=0;
    }else{
        GM1[l-1].m=0;
    }
}
__global__ void front_uf(afg_unit* GM,afg_unit* GM1,afg_unit* GM2,char*mx,char*my,int xl,int xr,int yl,int yr,int ymover,int ymid) {
    int tid=threadIdx.x+blockDim.x*blockIdx.x;
    int xp=tid+xl-1;
    int yp=ymover-tid;
    if((yp<(yl-1))||(xp>xr)||(yp>yr))return;
    GM[xp].x=GM1[xp-1].gto_x();
    GM[xp].y=GM1[xp].gto_y();
    GM[xp].m=GM2[xp-1].gto_m(mx[xp]==my[yp]);
    if(yp==ymid){
        GM[xp].m.start=xp;
        GM[xp].m.is_backgap=false;
        GM[xp].y.start=xp;
        GM[xp].y.is_backgap=true;
    }
    return;
}

class afg_controler{
private:
    afg_unit *GM,*GM1,*GM2;
    char *gx,*gy;
    int xsize,ysize;
    __host__ void initM(int l,int r,bool xgap){
        int initx=l-2;
        int cnt=r-l+3;
        int nb=cnt/THREAD_SIZE+((cnt%THREAD_SIZE)>0);
        initM_uf<<<nb,THREAD_SIZE>>>(GM+initx,GM1+initx,GM2+initx,cnt);
        initM_mf<<<1,1>>>(GM1,l,xgap);
    }
    __host__ void dp(int xl,int xr,int yl,int yr,int ymid,bool xgap){
        int nx=xr-xl+2;// 平行化數量
        int nb=nx/THREAD_SIZE+((nx%THREAD_SIZE)>0);
        initM(xl,xr,xgap);
        for(int ymover=yl;ymover<=yr+nx-1;ymover++){
            front_uf<<<nb,THREAD_SIZE>>>(GM,GM1,GM2,gx,gy,xl,xr,yl,yr,ymover,ymid);
            cudaMemcpy(GM2+xl-1, GM1+xl-1, nx*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
            cudaMemcpy(GM1+xl-1, GM+xl-1, nx*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
        }
    }
public:
    __host__ afg_controler(char*x,char*y,int _xsize,int _ysize){
        xsize=_xsize;
        ysize=_ysize;
        // example (apc, app, 3, 3)
        //初始化
        //GPU copy (must have -1 index as input)
        cudaMalloc(&GM, (xsize+2)*sizeof(afg_unit));
        cudaMalloc(&GM1, (xsize+2)*sizeof(afg_unit));
        cudaMalloc(&GM2, (xsize+2)*sizeof(afg_unit));

        GM++;
        GM1++;
        GM2++;

        cudaMalloc(&gx, (xsize+1)*sizeof(char));
        cudaMemset(gx, '-', sizeof(char));
        cudaMemcpy(gx+1, x, xsize*sizeof(char), cudaMemcpyHostToDevice);

        cudaMalloc(&gy, (ysize+1)*sizeof(char));
        cudaMemset(gy, '-', sizeof(char));
        cudaMemcpy(gy+1, y, ysize*sizeof(char), cudaMemcpyHostToDevice);
    }
    __host__ res_unit get_xmid(int xl,int xr,int yl,int yr,int ymid,bool xgap){
        dp(xl,xr,yl,yr,ymid,xgap);
        afg_unit a;
        cudaMemcpy(&a, GM+xr, sizeof(afg_unit),cudaMemcpyDeviceToHost);
        return a.cresult();
    }
};


#endif