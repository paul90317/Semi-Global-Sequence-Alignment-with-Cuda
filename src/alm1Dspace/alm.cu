#include <cstdlib>
#include <iostream>
#include <cstring>
#include "afg_controler.h"

#define THREAD_SIZE 1024

using namespace std;

char *x,*y;
res_unit res;
void dfs(FILE* file,afg_controler ac,int xl,int xr,int yl,int yr,bool xgap){
    int xs=(xr-xl+1),ys=(yr-yl+1);
    static char buf[1000];
    if(xs<=0){
        for(int i=yl-1;i<yr;i++){
            sprintf(buf,"- %c\n",y[i]);
            fputs(buf,file);
        }
        return;
    }
    if(ys<=0){
        for(int i=xl-1;i<xr;i++){
            sprintf(buf,"%c -\n",x[i]);
            fputs(buf,file);
        }
        return;
    }
    int ymid=(yl+yr)/2;
    res_unit tmp=ac.get_xmid(xl,xr,yl,yr,ymid,xgap);
    int xmid=tmp.start;
    if(tmp.is_backgap){//y 對應到 x 後的 gap
        dfs(file,ac,xl,xmid,yl,ymid-1,xgap);
        sprintf(buf,"- %c\n",y[ymid-1]);
        fputs(buf,file);
        dfs(file,ac,xmid+1,xr,ymid+1,yr,true);
    }else{
        dfs(file,ac,xl,xmid-1,yl,ymid-1,xgap);
        sprintf(buf,"%c %c\n",x[xmid-1],y[ymid-1]);
        fputs(buf,file);
        dfs(file,ac,xmid+1,xr,ymid+1,yr,false);
    }
    res=tmp;
}

int main(int argc,char** argv){
    FILE* file;
    int xsize,ysize;

    if(argc!=4){
        cout<<"Follow format: command [x.txt] [y.txt] [out.txt]\n";
        return 0;
    }
    
    //讀取 x
    file=fopen(argv[1],"r");
    fseek(file,0,SEEK_END);
    xsize=ftell(file);
    x=new char[xsize+1];
    fseek(file,0,SEEK_SET);
    fgets(x,xsize+1,file);
    fclose(file);

    //讀取 y buffer
    file=fopen(argv[2],"r");
    fseek(file,0,SEEK_END);
    ysize=ftell(file);
    y=new char[ysize+1];
    fseek(file,0,SEEK_SET);
    fgets (y , ysize+1 , file);
    fclose(file);

    //運算
    afg_controler ac(x,y,xsize,ysize);
    file=fopen(argv[3],"w");
    dfs(file,ac,1,xsize,1,ysize,false);
    fclose(file);
    printf("best score: %d\n",res.score);
}

