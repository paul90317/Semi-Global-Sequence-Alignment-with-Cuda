#include <cstdlib>
#include <iostream>
#include <cstring>

#include "func.cuh"
#include "sequence.cuh"

#if END_MODE==0
__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,sequence x,sequence y,int offset_y,int offset_t)
#elif END_MODE==3
__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,sequence x,sequence y,int offset_y,int offset_t,res_unit_end* best_arr) 
#else
__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,sequence x,sequence y,int offset_y,int offset_t,res_unit_end* best_stack,int* bs_count,datatype* bscore) 
#endif
{
    int tid=TID+offset_t;
    int xid=tid;
    int yid=offset_y-tid;
    if(xid<0||yid<0||xid>x.size()||yid>y.size())return;
#if START_MODE==0
    M[xid].x=M1[xid-1].to_x();
    M[xid].y=M1[xid].to_y();
    M[xid].m=M2[xid-1].to_m(x.gget(xid),y.gget(yid));
#elif START_MODE==1
    M[xid].x=M1[xid-1].to_x();
    M[xid].y=M1[xid].to_y();
    M[xid].m=M2[xid-1].to_m(x.gget(xid),y.gget(yid));
    if(yid==0){
        M[xid].m=0;
        M[xid].m.xstart=xid+1;
        M[xid].y.xstart=xid+1;
    }
#elif START_MODE==2
    if(xid==0){
        M[xid].x.ystart=yid+1;
        M[xid].m.ystart=yid+1;
        return;
    }
    M[xid].x=M1[xid-1].to_x();
    M[xid].y=M1[xid].to_y();
    M[xid].m=M2[xid-1].to_m(x.gget(xid),y.gget(yid));
#elif START_MODE==3
    res_unit zero(0,xid+1,yid+1);
    M[xid].x=max2(M1[xid-1].to_x(),zero);
    M[xid].y=max2(M1[xid].to_y(),zero);
    M[xid].m=max2(M2[xid-1].to_m(x.gget(xid),y.gget(yid)),zero);
#endif
#if END_MODE==3
    res_unit_end now(M[xid].result(),xid,yid);
    best_arr[xid]=max2(now,best_arr[xid]);
#elif END_MODE>0
    if(xid==x.size()&&Y_FREE_END||yid==y.size()&&X_FREE_END){
        res_unit_end now(M[xid].result(),xid,yid);
        update_score(now,best_stack,bs_count,bscore);
    }
#endif
}
#define free_or_fixed(free) (free?"free":"fixed")
int main(int argc,char** argv){
    std::cout<<std::fixed<<std::setprecision(FLOAT_PRECISION)<<"\n";
    if(argc!=5){
        std::cout<<"error: follow format: semi_interval.exe <x.txt> <y.txt> <best interval.txt> <score.txt>\n";
        return 0;
    }
    afg_unit *GM,*GM1,*GM2;

    std::cout<<"semi-global-setting: src/headers/myconfig.h\n";
    std::cout<<" - x: ["<<free_or_fixed(X_FREE_START)<<", "<<free_or_fixed(X_FREE_END)<<"]\n";
    std::cout<<" - y: ["<<free_or_fixed(Y_FREE_START)<<", "<<free_or_fixed(Y_FREE_END)<<"]\n";
    if(!score::load(argv[4])){
        std::cout<<"error: can't load score matrix in "<<argv[4]<<"\n";
        exit(0);
    }else{
        std::cout<<"score matrix: "<<argv[4]<<"\n";
    }

    sequence x(argv[1]);
    sequence y(argv[2]);
    std::cout<<"sequence X: "<<argv[1]<<"\n";
    std::cout<<" - size: "<<x.size()<<"\n";
    std::cout<<"sequence Y: "<<argv[2]<<"\n";
    std::cout<<" - size: "<<y.size()<<"\n";
    
    //宣告最佳解
#if (X_FREE_END&&Y_FREE_END)
    res_unit_end* g_best_arr;
    cudaMalloc(&g_best_arr,sizeof(res_unit_end)*(x.size()+1));
    assign_value2res(g_best_arr,NEG_INF,x.size()+1);
#elif START_MODE>0
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
    {
        cudaMalloc(&GM, (x.size()+2)*sizeof(afg_unit));
        cudaMalloc(&GM1, (x.size()+2)*sizeof(afg_unit));
        cudaMalloc(&GM2, (x.size()+2)*sizeof(afg_unit));
        afg_unit temp;
        assign_afg(GM,temp,x.size()+2);
        assign_afg(GM1,temp,x.size()+2);
        assign_afg(GM2,temp,x.size()+2);
        GM++;
        GM1++;
        GM2++;
        temp.m=0;
        assign_afg(GM,temp);
        assign_afg(GM1,temp);
        assign_afg(GM2,temp);
    }
    

    int nthread,nblock;
    int thread_needed,offset_t=0;
    //thread_assign(x.size()+1,&nblock,&nthread);
    mytime::start();
    for(int offset_y=1;offset_y-x.size()<=y.size();offset_y++){
        thread_needed=bound_assign(x.size(),y.size(),offset_y,&offset_t);
        thread_assign(thread_needed,&nblock,&nthread);
        #if (END_MODE==0)
            calculate _kernel(nblock,nthread)(GM,GM1,GM2,x,y,offset_y,offset_t);
        #elif (END_MODE==3)
            calculate _kernel(nblock,nthread)(GM,GM1,GM2,x,y,offset_y,offset_t,g_best_arr);
        #else
            calculate _kernel(nblock,nthread)(GM,GM1,GM2,x,y,offset_y,offset_t,g_best_stack,g_bs_count,g_best_score);
        #endif
        cudaMemcpy(GM2,GM1,sizeof(afg_unit)*(x.size()+1),cudaMemcpyDeviceToDevice);
        cudaMemcpy(GM1,GM,sizeof(afg_unit)*(x.size()+1),cudaMemcpyDeviceToDevice);
    }
    mytime::end();
    std::cout<<"[OUTPUT]\n";
    std::cout<<"best intervals: "<<argv[3]<<"\n";

    //印出結果
#if (!X_FREE_END&&!Y_FREE_END)
    afg_unit last;
    cudaMemcpy(&last,GM+x.size(),sizeof(afg_unit),cudaMemcpyDeviceToHost);//last
    std::cout<<"best score: "<<last.result().score<<"\n";
    show_best_and_output_file(argv[3],res_unit_end(last.result(),0,0),x.size(),y.size());
#elif (X_FREE_END&&Y_FREE_END)
    res_unit_end* cbests;
    datatype bestscore=interval_result_from_gup(&cbests,g_best_arr,x.size()+1);
    std::cout<<"best score: "<<bestscore<<"\n";
    show_best_and_output_file(argv[3],cbests,x.size()+1,x.size(),y.size(),bestscore);
#else
    datatype ctmp_bscore;
    cudaMemcpy(&ctmp_bscore,g_best_score,sizeof(datatype),cudaMemcpyDeviceToHost);
    std::cout<<"best score: "<<ctmp_bscore<<"\n";
    res_unit_end*cbest_stack;
    int c_bs_count=interval_result_from_gup(&cbest_stack,g_best_stack,g_bs_count);
    show_best_and_output_file(argv[3],cbest_stack,c_bs_count,x.size(),y.size(),ctmp_bscore);
#endif
}

