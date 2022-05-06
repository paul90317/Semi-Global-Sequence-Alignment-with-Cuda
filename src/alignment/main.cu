#include <cstdlib>
#include <iostream>
#include <cstring>
#include <iomanip>
#include "afg_controller.cuh"
#include "file.cuh"
#include "test_time.h"
#include "check_alm.h"
#include "alm_controller/alm_controller.cuh"

namespace dfs{
    byte *x_int,*y_int;
    FILE* file;
    afg_controller afg_c;
    alm_controller alm_c;
    datatype bscore;
    void dfs(int xl,int xr,int yl,int yr,bool xgap){
        int xs=(xr-xl+1),ys=(yr-yl+1);
        if(xs<=0){
            for(int i=yl;i<=yr;i++){
                print_alm(file,'-',to_Char(y_int[i]));
            }
            return;
        }
        if(ys<=0){
            for(int i=xl;i<=xr;i++){
                print_alm(file,to_Char(x_int[i]),'-');
            }
            return;
        }
        if(xs<ALM_END_POINT_SIZE&&ys<ALM_END_POINT_SIZE){
            bscore=alm_c.cal_out_trace_back(file,xl,xr,yl,yr,xgap);
            return;
        }
        int ymid=(yl+yr)/2;
        res_unit tmp=afg_c.get_xmid(xl,xr,yl,yr,ymid,xgap);
        int xmid=tmp.xmid; 
        if(tmp.is_xbackgap){//y 對應到 x 後的 gap
            dfs(xl,xmid,yl,ymid-1,xgap);
            print_alm(file,'-',to_Char(y_int[ymid]));;
            dfs(xmid+1,xr,ymid+1,yr,true);
        }else{
            dfs(xl,xmid-1,yl,ymid-1,xgap);
            print_alm(file,to_Char(x_int[xmid]),to_Char(y_int[ymid]));
            dfs(xmid+1,xr,ymid+1,yr,false);
        }
        bscore=tmp.score;
    }
}

bool is_same(datatype a,datatype b){
    if(typeid(datatype)==typeid(float)){
        return abs(a-b)<=ERROR_FLOAT;
    }
    if(typeid(datatype)==typeid(double)){
        //std::cout<<std::fixed<<std::setprecision(5)<<a<<" "<<b<<"\n";
        return abs(a-b)<=ERROR_FLOAT;
    }
    if(typeid(datatype)==typeid(long double)){
        return abs(a-b)<=ERROR_FLOAT;
    }
    return a==b;
    
}

int main(int argc,char** argv){
    byte *gx,*gy;
    if(argc!=6){
        std::cout<<"Error: follow format => alignment.exe [x.txt] [y.txt] [best interval.txt] [score.txt] [alignment.txt]\n";
        return 0;
    }
    //common
    if(!score::load(argv[4])){
        std::cout<<"Error: can't load score matrix in "<<argv[4]<<"\n";
        exit(0);
    }else{
        std::cout<<"loaded score matrix in "<<argv[4]<<"\n";
    }

    //讀取 best interval
    datatype score;
    int xl,xr,yl,yr;

    //讀取 best interval
    if(!load_best_interval(argv[3],&score,&xl,&xr,&yl,&yr)){
        std::cout<<"Error: can't open best interval!!!\n";
        exit(0);
    }
    std::cout<<"Load semi interval from "<<argv[3]<<" , Index=" <<DEFAULT_INTERVAL_INDEX<<", Score="<<score<<"\n";
    int xsz=xr-xl+1;
    int ysz=yr-yl+1;
    
    //讀取 x
    if(!load_file(&gx,&dfs::x_int,argv[1],xl,xr)){
        std::cout<<"Error: can't read x sequence!!!\n";
        exit(0);
    }
    std::cout<<"X sequence: "<<argv[1]<<" , Semi interval=["<<xl<<", "<<xr<<"]\n";

    //讀取 y
    if(!load_file(&gy,&dfs::y_int,argv[2],yl,yr)){
        std::cout<<"Error: can't read y sequence!!!\n";
        exit(0);
    }
    std::cout<<"Y sequence: "<<argv[2]<<" , Semi interval=["<<yl<<", "<<yr<<"]\n";

    //運算
    dfs::afg_c=afg_controller(gx,gy,xsz);
    dfs::alm_c=alm_controller(gx,gy,dfs::x_int,dfs::y_int);
    dfs::file=fopen(argv[5],"w");
    time_start();
    dfs::dfs(1,xsz,1,ysz,false);
    time_end();
    fclose(dfs::file);
    std::cout<<"Best score: "<<dfs::bscore<<"\n";
    
    datatype chk_score;
    bool match=check_alm(argv[5],dfs::x_int,dfs::y_int,&chk_score);
    if(!match){
        std::cout<<"Error: the alignment don't match original sequences!!!\n";
    }else{
        std::cout<<"The score of alignment "<<argv[5]<<" is "<<chk_score<<"\n";
    }
    if(!is_same(dfs::bscore,score)||!is_same(dfs::bscore,chk_score)){
        std::cout<<"Error: the score is not the same!!!\n";
    }
}

