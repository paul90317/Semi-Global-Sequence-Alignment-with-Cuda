#ifndef ALM_CONTROLLER_H
#define ALM_CONTROLLER_H

#include "alm_unit.cuh"
#include "myconfig.h"
#include "../func.cuh"
#include "sequence.cuh"

__all__
inline long long unsigned int dimcf(long long unsigned int i,long long unsigned int j,long long unsigned int hsize=ALM_END_POINT_SIZE+1){
    return i*hsize+j;
}

class cpair{
public:
    char x,y;
    cpair(char _x,char _y){
        x=_x;
        y=_y;
    }
};

__global__ static void calculate(alm_unit*GM,alm_unit*GM1,alm_unit*GM2,sequence gx,sequence gy,int offset_y,int offset_t,trace_unit* trace) {
    int tid=TID+offset_t;
    int xid=tid;
    int yid=offset_y-tid;
    if((xid<0)||(yid<0)||(xid>gx.size())||(yid>gy.size()))return;
    trace_unit tu;
    GM[tid].x=GM1[tid-1].to_x(&tu);
    GM[tid].y=GM1[tid].to_y(&tu);
    GM[tid].m=GM2[tid-1].to_m(gx.gget(xid),gy.gget(yid),&tu);
    trace[dimcf(xid,yid)]=tu;
}

class alm_controller{
private:
    alm_unit *GM,*GM1,*GM2;
    trace_unit *gtrace_back,*ctrace_back;
    long long unsigned int matrix_size;
    long long unsigned int end_size;
    __host__ void dp(sequence x, sequence y,bool xbackgap){
        {
            alm_unit temp;
            assign_alm(GM-1,temp,x.size()+2);
            assign_alm(GM1-1,temp,x.size()+2);
            assign_alm(GM2-1,temp,x.size()+2);
            if(xbackgap){
                temp.y=0;
            }else{
                temp.m=0;
            }
            assign_alm(GM1,temp);
        }
        int nb,nt,tneed,off_t=0;
        //thread_assign(x.size()+1,&nb,&nt);
        for(int off_y=1;off_y-x.size()<=y.size();off_y++){
            tneed=bound_assign(x.size(),y.size(),off_y,&off_t);
            thread_assign(tneed,&nb,&nt);
            calculate _kernel(nb,nt)(GM,GM1,GM2,x,y,off_y,off_t,gtrace_back);
            cudaMemcpy(GM2,GM1,sizeof(alm_unit)*(x.size()+1),cudaMemcpyDeviceToDevice);
            cudaMemcpy(GM1,GM,sizeof(alm_unit)*(x.size()+1),cudaMemcpyDeviceToDevice);
        }
    }
public:
    __host__ alm_controller(){
        end_size=ALM_END_POINT_SIZE;
        cudaMalloc(&GM, (end_size+2)*sizeof(alm_unit));
        cudaMalloc(&GM1, (end_size+2)*sizeof(alm_unit));
        cudaMalloc(&GM2, (end_size+2)*sizeof(alm_unit));
        matrix_size=(end_size+1)*(end_size+1);
        cudaMalloc(&gtrace_back,matrix_size*sizeof(trace_unit));
        ctrace_back=(trace_unit*)malloc(matrix_size*sizeof(trace_unit));
        GM++;
        GM1++;
        GM2++;
    }
    __host__ datatype cal_out_trace_back(FILE* file,sequence x,sequence y,bool xbackgap){
        dp(x,y,xbackgap);
        cudaMemcpy(ctrace_back,gtrace_back,matrix_size*sizeof(trace_unit),cudaMemcpyDeviceToHost);
        pointer now,next;
        alm_unit tmp;
        cudaMemcpy(&tmp,GM+x.size(),sizeof(alm_unit),cudaMemcpyDeviceToHost);
        datatype ret=tmp.result(&now);
        int i=x.size();
        int j=y.size();
        char _x,_y;
        std::stack<cpair> st;
        while(i||j){
            next=ctrace_back[dimcf(i,j)].next(now);
            switch(now){
            case pointer::tom:
                _x=score::Char_map[x.cget(i--)];
                _y=score::Char_map[y.cget(j--)];
                break;
            case pointer::tox:
                _x=score::Char_map[x.cget(i--)];
                _y='-';
                break;
            case pointer::toy:
                _x='-';
                _y=score::Char_map[y.cget(j--)];
                break;
            }
            now=next;
            st.push(cpair(_x,_y));
        }
        while(st.size()){
            cpair cp=st.top();
            st.pop();
            print_alm(file,cp.x,cp.y);
        }
        return ret;
    }   
};


#endif