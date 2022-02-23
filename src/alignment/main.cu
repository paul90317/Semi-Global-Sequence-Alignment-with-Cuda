#include <cstdlib>
#include <iostream>
#include <cstring>
#include "afg_controller.cuh"
#include "file_sys.cuh"
#include "test_time.h"
#include "check_alm.h"
#include "alm_controller/alm_controller.cuh"

#define THREAD_SIZE 1024

namespace dfs{
    int *x_int,*y_int;
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
            alm_head ah=alm_c.get_alm(xl,xr,yl,yr,xgap);
            ah.output(file);
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


int main(int argc,char** argv){
    int *gx,*gy;

    //common
    gscore_matrix_load();

    //讀取 best interval
    datatype score;
    int xl,xr,yl,yr;

    //讀取 best interval
    if(!load_best_interval(&score,&xl,&xr,&yl,&yr)){
        std::cout<<"can't open best interval!!!\n";
        exit(1);
    }
    std::cout<<"Load semi interval from "<<filename_best_score_interval<<" , Index=" <<DEFAULT_INTERVAL_INDEX<<", Score="<<score<<"\n";
    int xsz=xr-xl+1;
    int ysz=yr-yl+1;
    
    //讀取 x
    if(!load_file(&gx,&dfs::x_int,filename_x,xl,xr)){
        std::cout<<"can't read x sequence!!!\n";
        exit(1);
    }
    std::cout<<"X sequence: "<<filename_x<<" , Semi interval=["<<xl<<", "<<xr<<"]\n";

    //讀取 y
    if(!load_file(&gy,&dfs::y_int,filename_y,yl,yr)){
        std::cout<<"can't read y sequence!!!\n";
        exit(1);
    }
    std::cout<<"Y sequence: "<<filename_y<<" , Semi interval=["<<yl<<", "<<yr<<"]\n";

    //運算
    dfs::afg_c=afg_controller(gx,gy,xsz);
    dfs::alm_c=alm_controller(gx,gy);
    dfs::file=fopen(filename_alignment,"w");
    time_start();
    dfs::dfs(1,xsz,1,ysz,false);
    time_end();
    fclose(dfs::file);
    std::cout<<"Best score: "<<dfs::bscore<<"\n";
    
    datatype chk_score;
    bool match=check_alm(dfs::x_int,dfs::y_int,&chk_score);
    if(!match){
        std::cout<<"Error: the alignment don't match original sequences!!!\n";
    }else{
        std::cout<<"The score of alignment "<<filename_alignment<<" is "<<chk_score<<"\n";
    }
    if(dfs::bscore!=score||dfs::bscore!=chk_score){
        std::cout<<"Error: the score is not the same!!!\n";
    }
}

