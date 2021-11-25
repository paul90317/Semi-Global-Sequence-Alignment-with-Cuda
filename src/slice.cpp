#include <cstdlib>
#include <iostream>

using namespace std;

int main(int argc,char* argv[]){
    if(argc!=5){
        printf("please follow fromat:[in.txt] [initial index] [last index] [out.txt]");
        return 0;
    }
    int l,r,n;
    FILE* file;
    char* buf;

    l=strtol(argv[2],NULL,10);
    r=strtol(argv[3],NULL,10);
    n=r-l+1;

    file=fopen(argv[1],"r");
    fseek(file,l,SEEK_SET);
    buf=new char[n+1];
    fgets(buf,n+1,file);
    fclose(file);

    file=fopen(argv[4],"w");
    fputs(buf,file);
    fclose(file);
}