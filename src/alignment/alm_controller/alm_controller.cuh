#ifndef ALM_CONTROLLER_H
#define ALM_CONTROLLER_H

#include "alm_unit.cuh"
#include "config.h"
#include "utils.cuh"
#include "macro.cuh"
#include <stack>

#define dimcf(i,j) ((i)*ALM_END_POINT_SIZE+(j))

class cpair{
public:
    char x,y;
    cpair(char _x,char _y){
        x=_x;
        y=_y;
    }
};

namespace protected_space{
    __global__ static void _alm_assign(alm_unit* garr,alm_unit value,int count){
        int tid=TID;
        if(tid>=count)return;
        garr[tid]=value;
    }
}

static inline void alm_assign(alm_unit* garr,alm_unit value,int count){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_alm_assign _kernel(nb,nt)(garr,value,count);
}

__global__ static void calculate(alm_unit*GM,alm_unit*GM1,alm_unit*GM2,byte* gx,byte* gy,int xl,int xr,int yl,int yr,int ymover,trace_unit* trace) {
    int tid=TID;
    int xid=tid+ZERO(xl);
    int yid=ymover-tid-1;
    if((xid<ZERO(xl))||(yid<ZERO(yl))||(xid>xr)||(yid>yr))return;
    byte _x=gx[xid];
    byte _y=gy[yid];
    trace_unit tu;
    GM[tid].x=GM1[tid-1].to_x(&tu);
    GM[tid].y=GM1[tid].to_y(&tu);
    GM[tid].m=GM2[tid-1].to_m(_x,_y,&tu);
    trace[dimcf(tid,yid-ZERO(yl))]=tu;
}

class alm_controller{
private:
    alm_unit *GM,*GM1,*GM2;
    trace_unit *gtrace_back,*ctrace_back;
    byte *gx,*gy,*cx,*cy;
    __host__ void initM(int l,int r,bool xbackgap){
        int cnt=r-l+3;
        alm_unit au;
        alm_assign(GM-1,au,cnt);
        alm_assign(GM1-1,au,cnt);
        alm_assign(GM2-1,au,cnt);
        if(xbackgap){
            au.y=0;
        }else{
            au.m=0;
        }
        alm_assign(GM1,au,1);
    }
    __host__ void dp(int xl,int xr,int yl,int yr,bool xbackgap){
        initM(xl,xr,xbackgap);
        int xsize=xr-xl+1;
        int nb,nt;
        thread_assign(xsize+1,&nb,&nt);
        for(int ymover=ZERO(yl)+2;Y_NOT_END(ymover,xsize,yr);ymover++){
            calculate _kernel(nb,nt)(GM,GM1,GM2,gx,gy,xl,xr,yl,yr,ymover,gtrace_back);
            cudaMemcpy(GM2,GM1,sizeof(alm_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
            cudaMemcpy(GM1,GM,sizeof(alm_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
        }
    }
public:
    __host__ alm_controller(){};
    __host__ alm_controller(byte*_gx,byte*_gy,byte* _cx,byte* _cy){
        int len=(ALM_END_POINT_SIZE+1);
        cudaMalloc(&GM, len*sizeof(alm_unit));
        cudaMalloc(&GM1, len*sizeof(alm_unit));
        cudaMalloc(&GM2, len*sizeof(alm_unit));
        cudaMalloc(&gtrace_back,ALM_END_POINT_SIZE*ALM_END_POINT_SIZE*sizeof(trace_unit));
        ctrace_back=(trace_unit*)malloc(ALM_END_POINT_SIZE*ALM_END_POINT_SIZE*sizeof(trace_unit));
        GM++;
        GM1++;
        GM2++;
        gx=_gx;
        gy=_gy;
        cx=_cx;
        cy=_cy;
    }
    __host__ datatype cal_out_trace_back(FILE* file,int xl,int xr,int yl,int yr,bool xbackgap){
        dp(xl,xr,yl,yr,xbackgap);
        cudaMemcpy(ctrace_back,gtrace_back,ALM_END_POINT_SIZE*ALM_END_POINT_SIZE*sizeof(trace_unit),cudaMemcpyDeviceToHost);
        int xsz=xr-xl+1;
        int ysz=yr-yl+1;
        pointer now,next;
        alm_unit tmp;
        cudaMemcpy(&tmp,GM+xsz,sizeof(alm_unit),cudaMemcpyDeviceToHost);
        datatype ret=tmp.result(&now);
        int i=xsz;
        int j=ysz;
        char _x,_y;
        std::stack<cpair> st;
        while(i||j){
            next=ctrace_back[dimcf(i,j)].next(now);
            //std::cout<<now<<next<<"\n";
            switch(now){
            case pointer::tom:
                _x=score::Char_map[cx[(i--)+ZERO(xl)]];
                _y=score::Char_map[cy[(j--)+ZERO(yl)]];
                break;
            case pointer::tox:
                _x=score::Char_map[cx[(i--)+ZERO(xl)]];
                _y='-';
                break;
            case pointer::toy:
                _x='-';
                _y=score::Char_map[cy[(j--)+ZERO(yl)]];
                break;
            }
            //std::cout<<_x<<_y<<"\n";
            now=next;
            st.push(cpair(_x,_y));
        }
        while(st.size()){
            cpair cp=st.top();
            st.pop();
            print_alm(file,cp.x,cp.y);
        }
        /*for(int i=0;i<=xsz;i++){
            for(int j=0;j<=ysz;j++){
                trace_unit tu=ctrace_back[dimcf(i,j)];
                std::cout<<tu.m<<tu.y<<" ";
            }
            std::cout<<"\n";
            for(int j=0;j<=ysz;j++){
                trace_unit tu=ctrace_back[dimcf(i,j)];
                std::cout<<tu.x<<"  ";
            }
            std::cout<<"\n";
        }*/
        return ret;
    }   
};


#endif