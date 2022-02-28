
#include <iostream>
__global__ void f(int & x){
    x=5;
}
void g(int&x){
    x=6;
}
int main(){
    int x=3;
    f<<<1,1>>>(x);
    std::cout<<x;
    g(x);
    std::cout<<x;
}