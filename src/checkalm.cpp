#include <cstdlib>
#include <iostream>
#include <cstring>

using namespace std;

int main(int argc,char* argv[]){
    char buf[10];
    FILE *fp;
    char *x,*y;
    int sc=0,status=0,xsize,ysize,xp=0,yp=0;

    if(argc!=4){
        printf("please follow format: [alm.txt] [x.txt] [y.txt]\n");
        return 0;
    }

    //讀取 x
    fp=fopen(argv[2],"r");
    fseek(fp,0,SEEK_END);
    xsize=ftell(fp);
    x=new char[xsize+1];
    fseek(fp,0,SEEK_SET);
    fgets(x,xsize+1,fp);
    fclose(fp);

    //讀取 y buffer
    fp=fopen(argv[3],"r");
    fseek(fp,0,SEEK_END);
    ysize=ftell(fp);
    y=new char[ysize+1];
    fseek(fp,0,SEEK_SET);
    fgets (y , ysize+1 , fp);
    fclose(fp);

    fp=fopen(argv[1],"r");
    while(fgets(buf,10,fp)){
        if(buf[0]==buf[2]){
            status=0;
            sc++;
        }else if(buf[0]=='-'){
            if(status==1){
                sc-=1;
            }else{
                sc-=2;
            }
            status=1;
        }else if(buf[2]=='-'){
            if(status==2){
                sc-=1;
            }else{
                sc-=2;
            }
            status=2;
        }else{
            sc--;
            status=0;
        }

        if(buf[0]!='-'){
            if(xp<xsize&&x[xp]==buf[0]){
                xp++;
            }else{
                printf("x not match.\n");
                return 0;
            }
        }
        if(buf[2]!='-'){
            if(yp<ysize&&y[yp]==buf[2]){
                yp++;
            }else{
                printf("y not match.\n");
                return 0;
            }
        }
    }
    if(xp!=xsize){
        printf("x not match.\n");
        return 0;
    }
    if(yp!=ysize){
        printf("y not match.\n");
        return 0;
    }
    printf("score: %d\n",sc);
    fclose(fp);
}