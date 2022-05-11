#ifndef AFG_CONTROLER_H
#define AFG_CONTROLER_H

#include "afg_unit.cuh"
#include "myconfig.h"
#include "func.cuh"
#include "comm.cuh"
#include "sequence.cuh"

__global__ static void calculate(afg_unit*GM,afg_unit*GM1,afg_unit*GM2,sequence gx,sequence gy,int off_y,int off_t,int ymid) {
    int tid=TID+off_t;
    int xid=tid;
    int yid=off_y-tid;
    if((xid<0)||(yid<0)||(xid>gx.size())||(yid>gy.size()))return;
    GM[xid].x=GM1[xid-1].to_x();
    GM[xid].y=GM1[xid].to_y();
    GM[xid].m=GM2[xid-1].to_m(gx.gget(xid),gy.gget(yid));
    if(yid==ymid){
        GM[xid].m.xmid=xid;
        GM[xid].m.is_xbackgap=false;
        GM[xid].y.xmid=xid;
        GM[xid].y.is_xbackgap=true;
    }    
    
}

class afg_controller{
private:
    afg_unit *GM,*GM1,*GM2;
    __host__ void dp(sequence x,sequence y, int ymid,bool xgap){
        {
            afg_unit temp;
            assign_afg(GM-1,temp,x.size()+2);
            assign_afg(GM1-1,temp,x.size()+2);
            assign_afg(GM2-1,temp,x.size()+2);
            if(xgap){
                temp.y=0;
            }else{
                temp.m=0;
            }
            assign_afg(GM1,temp);
        }
        int nb,nt,tneed,off_t=0;
        //thread_assign(x.size()+1,&nb,&nt);
        for(int off_y=1;off_y-x.size()<=y.size();off_y++){
            tneed=bound_assign(x.size(),y.size(),off_y,&off_t);
            thread_assign(tneed,&nb,&nt);
            calculate _kernel(nb,nt)(GM,GM1,GM2,x,y,off_y,off_t,ymid);
            cudaMemcpy(GM2,GM1,sizeof(afg_unit)*(x.size()+1),cudaMemcpyDeviceToDevice);
            cudaMemcpy(GM1,GM,sizeof(afg_unit)*(x.size()+1),cudaMemcpyDeviceToDevice);
        }
    }
public:
    __host__ afg_controller(int xsize){
        cudaMalloc(&GM, (xsize+2)*sizeof(afg_unit));
        cudaMalloc(&GM1, (xsize+2)*sizeof(afg_unit));
        cudaMalloc(&GM2, (xsize+2)*sizeof(afg_unit));
        GM++;
        GM1++;
        GM2++;
    }
    __host__ res_unit get_xmid(sequence x, sequence y,int ymid,bool xgap){
        dp(x,y,ymid,xgap);
        afg_unit temp;
        cudaMemcpy(&temp, GM+x.size(), sizeof(afg_unit),cudaMemcpyDeviceToHost);
        return temp.result();
    }
};


#endif