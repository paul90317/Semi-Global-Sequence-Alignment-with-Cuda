#include <iostream>
#include <cstdlib>
int main(){
    long long unsigned t=100000000000000*sizeof(int);
    int *arr=(int*)malloc(t);
    std::cout<<sizeof(long long unsigned)<<"\n";
    std::cout<<t<<arr[t-1]<<"\n";
}