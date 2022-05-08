#include <cstdlib>
#include <iostream>
#include <cstring>
#include <iomanip>
#include "sequence.cuh"
#include "alm_controller/alm_controller.cuh"
#include "afg_controller.cuh"

namespace dfs{
    FILE* file;
    afg_controller *afg_c;
    alm_controller *alm_c;
    datatype bscore;
    void dfs(sequence x,sequence y, bool xgap){
        if(x.size()<=0){
            for(int i=1;i<=y.size();i++){
                print_alm(file,'-',score::Char_map[y.cget(i)]);
            }
            return;
        }
        if(y.size()<=0){
            for(int i=1;i<=x.size();i++){
                print_alm(file,score::Char_map[x.cget(i)],'-');
            }
            return;
        }
        if(x.size()<ALM_END_POINT_SIZE&&y.size()<ALM_END_POINT_SIZE){
            bscore=alm_c->cal_out_trace_back(file,x,y,xgap);
            return;
        }
        int ymid=(1+y.size())/2;
        res_unit tmp=afg_c->get_xmid(x,y,ymid,xgap);
        int xmid=tmp.xmid;
        if(tmp.is_xbackgap){//y 對應到 x 後的 gap
            dfs(x.subseq(1,xmid),y.subseq(1,ymid-1),xgap);
            print_alm(file,'-',score::Char_map[y.cget(ymid)]);;
            dfs(x.subseq(xmid+1,x.size()-xmid),y.subseq(ymid+1,y.size()-ymid),true);
        }else{
            dfs(x.subseq(1,xmid-1),y.subseq(1,ymid-1),xgap);
            print_alm(file,score::Char_map[x.cget(xmid)],score::Char_map[y.cget(ymid)]);;
            dfs(x.subseq(xmid+1,x.size()-xmid),y.subseq(ymid+1,y.size()-ymid),false);
        }
        bscore=tmp.score;
    }
}

bool is_same(datatype a,datatype b){
if (typeid(datatype)==typeid(float) || typeid(datatype)==typeid(double) || typeid(datatype)==typeid(long double))
    return abs(a-b)<=FLOAT_ERROR;
else
    return a==b;
}

int main(int argc,char** argv){
    std::cout<<"\n";
    if(argc!=6){
        std::cout<<"error: follow format: alignment.exe <x.txt> <y.txt> <best interval.txt> <score.txt> <alignment.txt>\n";
        return 0;
    }
    //common
    if(!score::load(argv[4])){
        std::cout<<"error: can't load score matrix in "<<argv[4]<<"\n";
        exit(0);
    }else{
        std::cout<<"score matrix: "<<argv[4]<<"\n";
    }
    sequence x,y;
    datatype interval_score;
    //讀取 best interval
    {
        int xl,xr,yl,yr;

        //讀取 best interval
        if(!load_best_interval(argv[3],&interval_score,&xl,&xr,&yl,&yr)){
            std::cout<<"error: can't open best interval file\n";
            exit(0);
        }
        std::cout<<"interval: "<<argv[3]<<"\n";
        std::cout<<" - index: " <<DEFAULT_INTERVAL_INDEX<<"\n";
        std::cout<<" - score: " <<interval_score<<"\n";
        x=sequence(argv[1]).subseq(xl,xr-xl+1);
        y=sequence(argv[2]).subseq(yl,yr-yl+1);
        std::cout<<" - sequence X: "<<argv[1]<<"\n";
        std::cout<<" -  - interval: ["<<xl<<", "<<xr<<"]\n";
        std::cout<<" - sequence Y: "<<argv[2]<<"\n";
        std::cout<<" -  - interval: ["<<yl<<", "<<yr<<"]\n";
    }
    

    //運算
    dfs::afg_c=new afg_controller(x.size());
    dfs::alm_c=new alm_controller();
    dfs::file=fopen(argv[5],"w");
    mytime::start();
    dfs::dfs(x,y,false);
    mytime::end();
    fclose(dfs::file);
    std::cout<<"[OUTPUT]\n";
    std::cout<<"best score: "<<dfs::bscore<<"\n";
    
    datatype chk_score;
    bool match=check_alm(argv[5],x,y,&chk_score);
    if(!match){
        std::cout<<"error: the alignment don't match original sequences\n";
        exit(0);
    }else{
        std::cout<<"alignment: "<<argv[5]<<"\n";
        std::cout<<" - score: "<<chk_score<<"\n";
    }
    if(!is_same(dfs::bscore,interval_score)||!is_same(dfs::bscore,chk_score)){
        std::cout<<"error: the score is not the same\n";
    }
}

