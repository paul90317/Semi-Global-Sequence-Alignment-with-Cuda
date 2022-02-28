#include <cstdlib>
#include <iostream>
#include <cstring>

#include "utils.cuh"
#include "afg_unit.cuh"
#include "config.h"
#include "layout.cuh"
#include "macro.cuh"
#include "test_time.h"

#if END_MODE==0
__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,byte* x,byte* y,int index_y,int xsize,int ysize)
#elif END_MODE==3
__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,byte* x,byte* y,int index_y,int xsize,int ysize,res_unit_end* best_arr) 
#else
__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,byte* x,byte* y,int index_y,int xsize,int ysize,res_unit_end* best_stack,int* bs_count,datatype* bscore) 
#endif
{
    int xid=TID;
    int yid=index_y-xid-1;
    if(xid<0||yid<0||xid>xsize||yid>ysize)return;
#if START_MODE==0
    M[xid].x=M1[xid-1].to_x();
    M[xid].y=M1[xid].to_y();
    M[xid].m=M2[xid-1].to_m(x[xid],y[yid]);
#elif START_MODE==1
    M[xid].x=M1[xid-1].to_x();
    M[xid].y=M1[xid].to_y();
    M[xid].m=M2[xid-1].to_m(x[xid],y[yid]);
    if(yid==0){
        M[xid].m=0;
    }
    if(yid==1){
        M[xid].m.xstart=xid;
        M[xid].y.xstart=xid+1;
    }
#elif START_MODE==2
    if(xid==0)return;
    M[xid].x=M1[xid-1].to_x();
    M[xid].y=M1[xid].to_y();
    M[xid].m=M2[xid-1].to_m(x[xid],y[yid]);
    if(xid==1){
        M[xid].x.ystart=yid+1;
        M[xid].m.ystart=yid;
    }
#elif START_MODE==3
    res_unit zero(0,xid+1,yid+1);
    M[xid].x=max2(M1[xid-1].to_x(),zero);
    M[xid].y=max2(M1[xid].to_y(),zero);
    M[xid].m=max2(M2[xid-1].to_m(x[xid],y[yid]),zero);
#endif
#if END_MODE==3
    res_unit_end now(M[xid].result(),xid,yid);
    best_arr[xid]=max2(now,best_arr[xid]);
#elif END_MODE>0
    if(xid==xsize&&Y_FREE_END||yid==ysize&&X_FREE_END){
        res_unit_end now(M[xid].result(),xid,yid);
        update_score(now,best_stack,bs_count,bscore);
    }
#endif
}

int main(int argc,char** argv){
    byte *gx_int,*gy_int;
    afg_unit *M,*M1,*M2,*GM,*GM1,*GM2;
    int xsize,ysize;
    int nthread,nblock;
    if(argc!=4){
        std::cout<<"follow format: semi_interval.exe [x.txt] [t.txt] [best interval.txt]\n";
        return 0;
    }
    //common
    gscore_matrix_load();

    //讀取
    if(!load_file(&gx_int,&xsize,argv[1])){
        printf("讀不到 x 序列");
        exit(0);
    }
    std::cout<<"X sequence: "<<argv[1]<<" , Global interval=[1, "<<xsize<<"]\n";
    if(!load_file(&gy_int,&ysize,argv[2])){
        printf("讀不到 y 序列");
        exit(0);
    }
    std::cout<<"Y sequence: "<<argv[2]<<" , Global interval=[1, "<<ysize<<"]\n";
    
    //宣告最佳解
#if (!X_FREE_END&&!Y_FREE_END)
#elif (X_FREE_END&&Y_FREE_END)
    res_unit_end* g_best_arr;
    cudaMalloc(&g_best_arr,sizeof(res_unit_end)*(xsize+1));
    assign_arr(g_best_arr,NEG_INF,xsize+1);
#else
    res_unit_end* g_best_stack;
    int* g_bs_count;
    cudaMalloc(&g_best_stack,sizeof(res_unit_end)*BEST_STACK_SIZE);
    cudaMalloc(&g_bs_count,sizeof(int));
    cudaMemset(g_bs_count,0,sizeof(int));
    datatype* g_best_score;
    cudaMalloc(&g_best_score,sizeof(datatype));
    assign_single(g_best_score,(datatype)NEG_INF);
#endif
    //挖記憶體
    M=new afg_unit[xsize+2];
    M1=new afg_unit[xsize+2];
    M2=new afg_unit[xsize+2];
    M++;
    M1++;
    M2++;
    cudaMalloc(&GM, (xsize+2)*sizeof(afg_unit));
    cudaMalloc(&GM1, (xsize+2)*sizeof(afg_unit));
    cudaMalloc(&GM2, (xsize+2)*sizeof(afg_unit));
    GM++;
    GM1++;
    GM2++;
    M[0].m=0;
    M1[0].m=0;
    M2[0].m=0;
    cudaMemcpy(GM-1, M-1, (xsize+2)*sizeof(afg_unit), cudaMemcpyHostToDevice);
    cudaMemcpy(GM1-1, M1-1, (xsize+2)*sizeof(afg_unit), cudaMemcpyHostToDevice);
    cudaMemcpy(GM2-1, M2-1, (xsize+2)*sizeof(afg_unit), cudaMemcpyHostToDevice);
    thread_assign(xsize+1,&nblock,&nthread);

    //分支
    time_start();
    for(int idy=2;Y_NOT_END(idy,xsize,ysize);idy++){
        #if (END_MODE==0)
            calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx_int,gy_int,idy,xsize,ysize);
        #elif (END_MODE==3)
            calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx_int,gy_int,idy,xsize,ysize,g_best_arr);
        #else
            calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx_int,gy_int,idy,xsize,ysize,g_best_stack,g_bs_count,g_best_score);
        #endif
        cudaMemcpy(GM2,GM1,sizeof(afg_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
        cudaMemcpy(GM1,GM,sizeof(afg_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
    }
    time_end();
    std::cout<<"Best interval saved in: "<<argv[3]<<"\n\n";

    //印出結果
#if (!X_FREE_END&&!Y_FREE_END)
    afg_unit last;
    cudaMemcpy(&last,GM+xsize,sizeof(afg_unit),cudaMemcpyDeviceToHost);//last
    std::cout<<"Best score: "<<last.result().score<<"\n";
    show_best_and_output_file(argv[3],res_unit_end(last.result(),0,0),xsize,ysize);
#elif (X_FREE_END&&Y_FREE_END)
    res_unit_end* cbests;
    datatype bestscore=interval_result_from_gup(&cbests,g_best_arr,xsize+1);
    std::cout<<"Best score: "<<bestscore<<"\n";
    show_best_and_output_file(argv[3],cbests,xsize+1,xsize,ysize,bestscore);
#else
    datatype ctmp_bscore;
    cudaMemcpy(&ctmp_bscore,g_best_score,sizeof(datatype),cudaMemcpyDeviceToHost);
    std::cout<<"Best score: "<<ctmp_bscore<<"\n";
    res_unit_end*cbest_stack;
    int c_bs_count=interval_result_from_gup(&cbest_stack,g_best_stack,g_bs_count);
    show_best_and_output_file(argv[3],cbest_stack,c_bs_count,xsize,ysize,ctmp_bscore);
#endif
}

