#include <cstdlib>
#include <iostream>

#define BUF_SIZE 1000

using namespace std;

int main(int argc,char* argv[]){
    if(argc!=8){
        printf("please follow format: [x.txt] [y.txt] [out.txt] [tmp.txt] [afg.exe] [slice.exe] [alm.exe]");
        return 0;
    }
    FILE* fp;
    char *xtxt=argv[1],*ytxt=argv[2],*outtxt=argv[3],*tmptxt=argv[4],*afgexe=argv[5],*sliceexe=argv[6],*almexe=argv[7],*p;
    char buf[BUF_SIZE];
    int sc1,l,r;

    sprintf(buf,"%s %s %s > %s",afgexe,xtxt,ytxt,tmptxt);
    printf("%s\n",buf);
    system(buf);

    p=buf;
    fp=fopen(tmptxt,"r");
    fgets(buf,BUF_SIZE,fp);
    fclose(fp);
    sc1=strtol(p,&p,10);
    l=strtol(p,&p,10);
    r=strtol(p,&p,10);
    printf("afg best score: %d\n",sc1);

    sprintf(buf,"%s %s %d %d %s",sliceexe,ytxt,l,r,tmptxt);
    printf("%s\n",buf);
    system(buf);

    sprintf(buf,"%s %s %s %s",almexe,xtxt,tmptxt,outtxt);
    printf("%s\n",buf);
    system(buf);
}