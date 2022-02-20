
#include <cstdio>

#define NUM_BLOCKS 64
#define NUM_THREADS 256
__global__ void f()
{
    int tid=gridDim.x;
    printf("%d ",tid);
}
int main(){
    int gpu_n;
    cudaGetDeviceCount(&gpu_n);
    printf("CUDA-capable device count: %i\n", gpu_n);
    f<<<NUM_BLOCKS, NUM_THREADS, sizeof(float) * 2 *NUM_THREADS>>>();
}