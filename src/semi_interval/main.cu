#include <cstdlib>
#include <iostream>
#include <cstring>

#include "utils.cuh"
#include "afg_unit.cuh"
#include "config.h"
#include "layout.cuh"
#include "macro.cuh"
#include "test_time.h"

__global__ void calculate_yfreeStart(afg_unit* M,int* x,int* y,int index_y,int xsize,int ysize,res_unit* best_stack,int* bs_count,datatype* bscore) {
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
#if (Y_FREE_END || X_FREE_END)
#if !(Y_FREE_END&&X_FREE_END)
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END){
#endif
        res_unit& now=M[dimcf(0,xid)].result();
        update_score(now,xid,yid,best_stack,bs_count,bscore);
#if !(Y_FREE_END&&X_FREE_END)
    }
#endif
#endif
}
__global__ void calculate_xyfreeStart(afg_unit* M,int* x,int* y,int index_y,int xsize,int ysize,res_unit* best_stack,int* bs_count,datatype* bscore) {
    int xid=TID;
    int yid=index_y-xid-1;
    if(xid<0||yid<0||xid>xsize||yid>ysize)return;
    res_unit zero(0,xid+1,xid,yid+1,yid);
    M[dimcf(0,xid)].x=max2(M[dimcf(1,xid-1)].to_x(),zero);
    M[dimcf(0,xid)].y=max2(M[dimcf(1,xid)].to_y(),zero);
    M[dimcf(0,xid)].m=max2(M[dimcf(2,xid-1)].to_m(x[xid],y[yid]),zero);
    #if (Y_FREE_END || X_FREE_END)
#if !(Y_FREE_END&&X_FREE_END)
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END){
#endif
        res_unit& now=M[dimcf(0,xid)].result();
        update_score(now,xid,yid,best_stack,bs_count,bscore);
#if !(Y_FREE_END&&X_FREE_END)
    }
#endif
#endif
}
__global__ void calculate_fixedStart(afg_unit* M,int* x,int* y,int index_y,int xsize,int ysize,res_unit* best_stack,int* bs_count,datatype* bscore) {
    int xid=TID;
    int yid=index_y-xid-1;
    if(xid<0||yid<0||xid>xsize||yid>ysize)return;
    M[dimcf(0,xid)].x=M[dimcf(1,xid-1)].to_x();
    M[dimcf(0,xid)].y=M[dimcf(1,xid)].to_y();
    M[dimcf(0,xid)].m=M[dimcf(2,xid-1)].to_m(x[xid],y[yid]);
#if (Y_FREE_END || X_FREE_END)
#if !(Y_FREE_END&&X_FREE_END)
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END){
#endif
        res_unit& now=M[dimcf(0,xid)].result();
        update_score(now,xid,yid,best_stack,bs_count,bscore);
#if !(Y_FREE_END&&X_FREE_END)
    }
#endif
#endif
}
__global__ void calculate_xfreeStart(afg_unit* M,int* x,int* y,int index_y,int xsize,int ysize,res_unit* best_stack,int* bs_count,datatype* bscore) {
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
#if (Y_FREE_END || X_FREE_END)
#if !(Y_FREE_END&&X_FREE_END)
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END){
#endif
        res_unit& now=M[dimcf(0,xid)].result();
        update_score(now,xid,yid,best_stack,bs_count,bscore);
#if !(Y_FREE_END&&X_FREE_END)
    }
#endif
#endif
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
    }
    std::cout<<"X sequence: "<<filename_x<<" , Global interval=[1, "<<xsize<<"]\n";
    if(!load_file(&gy_int,&ysize,filename_y)){
        printf("讀不到 y 序列");
        exit(0);
    }
    std::cout<<"Y sequence: "<<filename_y<<" , Global interval=[1, "<<ysize<<"]\n";
    //宣告最佳解
    res_unit* g_best_stack;
    int* g_bs_count;
    cudaMalloc(&g_best_stack,sizeof(res_unit)*BEST_STACK_SIZE);
    cudaMalloc(&g_bs_count,sizeof(int));
    cudaMemset(g_bs_count,0,sizeof(int));

    //挖記憶體
    M=new afg_unit[(xsize+2)*3];
    M+=3;
    cudaMalloc(&GM, 3*(xsize+2)*sizeof(afg_unit));
    GM+=3;

    datatype* g_best_score;
    cudaMalloc(&g_best_score,sizeof(datatype));
    assign_single(g_best_score,(datatype)NEG_INF);
    
    //分支
    time_start();
#if (START_MODE==2)
    M[dimcf(0,0)].m=0;
    M[dimcf(1,0)].m=0;
    M[dimcf(2,0)].m=0;
    cudaMemcpy(GM-3, M-3, 3*(xsize+2)*sizeof(afg_unit), cudaMemcpyHostToDevice);
    thread_assign(xsize,&nblock,&nthread);
    for(int idy=2;Y_NOT_END(idy,xsize,ysize);idy++){
        calculate_yfreeStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,xsize,ysize,g_best_stack,g_bs_count,g_best_score);
        dim_move(GM+3,xsize);
    }
#else
    M[dimcf(1,0)].m=0;
    cudaMemcpy(GM-3, M-3, 3*(xsize+2)*sizeof(afg_unit), cudaMemcpyHostToDevice);
    thread_assign(xsize+1,&nblock,&nthread);
    for(int idy=2;Y_NOT_END(idy,xsize,ysize);idy++){
    #if (START_MODE==0)
        calculate_fixedStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,xsize,ysize,g_best_stack,g_bs_count,g_best_score);
    #elif (START_MODE==1)
        calculate_xfreeStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,xsize,ysize,g_best_stack,g_bs_count,g_best_score);
    #elif (START_MODE==3)
        calculate_xyfreeStart<<<nblock,nthread>>>(GM,gx_int,gy_int,idy,xsize,ysize,g_best_stack,g_bs_count,g_best_score);
    #endif
        dim_move(GM,xsize+1);
    }
#endif
    time_end();
    std::cout<<"Best interval saved in: "<<filename_best_score_interval<<"\n\n";
    //印出結果
#if (!X_FREE_END&&!Y_FREE_END)
    res_unit last;
    cudaMemcpy(&last,GM+dimcf(0,xsize),sizeof(res_unit),cudaMemcpyDeviceToHost);//last
    std::cout<<"Best score: "<<last.score<<"\n";
    show_best_and_output_file(last,xsize,ysize);
#else
    datatype ctmp_bscore;
    cudaMemcpy(&ctmp_bscore,g_best_score,sizeof(datatype),cudaMemcpyDeviceToHost);
    std::cout<<"Best score: "<<ctmp_bscore<<"\n";
    res_unit*cbest_stack;
    int c_bs_count=interval_result_from_gup(&cbest_stack,g_best_stack,g_bs_count);
    show_best_and_output_file(cbest_stack,c_bs_count,xsize,ysize,ctmp_bscore);
#endif
}

