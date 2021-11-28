#include <cstdlib>
#include <iostream>
#include <fstream>

using namespace std;

int main(int argc,char* argv[]){
    if(argc!=3){
        printf("please follow fromat:[in.txt] [out.txt]");
        return 0;
    }
    fstream fin,fout;
    char c;
    fin.open(argv[1],ios::in);
    fout.open(argv[2],ios::out);
    while(fin){
        fin>>c;
        fout<<c;
    }
    fin.close();
    fout.close();
}