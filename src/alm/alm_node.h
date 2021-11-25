#define STACK_SIZE 20000

struct alm_node{
    char x,y;
    alm_node *next;
};

__host__ alm_node** cuda_2D(int r,int c){
    alm_node **a=new alm_node*[r+1],**b;
    for(int i=1;i<=r;i++){
        cudaMalloc(&a[i], c*sizeof(alm_node));
    }
    cudaMalloc(&b, (r+1)*sizeof(alm_node*));
    cudaMemcpy(b, a, (r+1)*sizeof(alm_node*), cudaMemcpyHostToDevice);
    return b;
}

class alm_node_control{
private:
    alm_node** stks;
    int* backs;
public:
    __host__ alm_node_control(int xsize){
        cudaMalloc(&backs, (xsize+1)*sizeof(int));
        cudaMemset(backs,0,(xsize+1)*sizeof(int));
        stks=cuda_2D(xsize,STACK_SIZE);
    }
    __device__ alm_node* alm_node_alloc(int t1){
        int i=backs[t1];
        backs[t1]=(backs[t1]+1)%STACK_SIZE;
        return stks[t1]+i;
    }
};
