#include <cstdlib>
#include <iostream>
#include <ctime>

using namespace std;

int main(int argc,char** argv){
    char buf[10000];
    int len=0;
    for(int i=1;i<argc;i++){
        len+=sprintf(buf+len,"%s ",argv[i]);
    }
    printf("Start %s\n",buf);
    clock_t tStart = clock();
    system(buf);
    printf("\nTime taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
}