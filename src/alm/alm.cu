#include <cstdlib>
#include <iostream>
#include <cstring>
#include "afg_unit_gpu.h"

#define THREAD_SIZE 1024

using namespace std;

__global__ void calculate(afg_unit* M,afg_unit* M1,afg_unit* M2,char* x,char* y,int buf_mover,int* maxs,alm_node** bestalms,alm_node_control alc) {
    int t=threadIdx.x+blockDim.x*blockIdx.x;
    alm_node* tmp;

    if(x[t]==0||y[buf_mover-t]==0)return;

    tmp=alc.alm_node_alloc(t+1);
    M[t+1].stk_x=M1[t].alm_x(x[t],tmp);

    tmp=alc.alm_node_alloc(t+1);
    M[t+1].stk_y=M1[t+1].alm_y(y[buf_mover-t],tmp);

    tmp=alc.alm_node_alloc(t+1);
    M[t+1].stk_m=M2[t].alm_m(x[t],y[buf_mover-t],tmp);

    M[t+1].x=    M1[t]  .gto_x();
    M[t+1].y=    M1[t+1].gto_y();
    M[t+1].m=    M2[t]  .gto_m(x[t]==y[buf_mover-t]);

    bestalms[t+1]=max2sel(maxs[t+1],M[t+1].gresult(),bestalms[t+1],M[t+1].best_alm());
    maxs[t+1]=       max2(maxs[t+1],M[t+1].gresult());
    return;
}
void ptr_stk(alm_node* gstk,char* filename){
    alm_node *stk=nullptr,*tmp;
    FILE* fp;
    char buf[100];

    while(gstk){
        tmp=(alm_node*)malloc(sizeof(alm_node));
        cudaMemcpy(tmp, gstk, sizeof(alm_node), cudaMemcpyDeviceToHost);
        gstk=tmp->next;
        tmp->next=stk;
        stk=tmp;
    }

    fp=fopen(filename,"w");
    while(stk){
        sprintf(buf,"%c %c\n",stk->x,stk->y);
        fputs(buf,fp);
        stk=stk->next;
    }
    fclose(fp);
}

alm_node* cuda_alm_node(char x,char y,alm_node* next=nullptr){
    alm_node a,*b;
    a.x=x;
    a.y=y;
    a.next=next;
    cudaMalloc(&b,sizeof(alm_node));
    cudaMemcpy(b, &a, sizeof(alm_node), cudaMemcpyHostToDevice);
    return b;
}

/*void debug(int * garr,int count){
    int *arr=new int[count];
    cudaMemcpy(arr, garr, count*sizeof(int), cudaMemcpyDeviceToHost);
    for(int i=0;i<count;i++){
        printf("%d ",arr[i]);
    }
    printf("\n");
}

void debug(afg_unit * garr,int count){
    afg_unit *arr=new afg_unit[count];
    cudaMemcpy(arr, garr, count*sizeof(afg_unit), cudaMemcpyDeviceToHost);
    for(int i=1;i<count;i++){
        printf("[r=%d,score=%d,%d,%d]:\n",i,arr[i].m,arr[i].x,arr[i].y);
        ptr_stk(arr[i].cbest_alm());
        printf("\n");
    }
}*/

int main(int argc,char** argv){
    FILE* file;
    char *x,*y,*gx,*gy;
    afg_unit *M,*M1,*M2,*GM,*GM1,*GM2;
    int xsize,buf_mover,tmp,nthread,nblock,nsize,*gmaxs,ysize;
    alm_node **gbestalms,*best_alm;

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

    //初始化 cuda 參數
    nthread=min(xsize,THREAD_SIZE);
    nblock=xsize/THREAD_SIZE;
    if(xsize%THREAD_SIZE)nblock++;
    nsize=nblock*nthread;

    //動態規劃 M
    M=new afg_unit[nsize+1];
    M1=new afg_unit[nsize+1];
    M2=new afg_unit[nsize+1];

    //讀取 y buffer
    file=fopen(argv[2],"r");
    fseek(file,0,SEEK_END);
    ysize=ftell(file);
    y=new char[ysize+1];
    fseek(file,0,SEEK_SET);
    fgets (y , ysize+1 , file);
    fclose(file);

    //初始化 M
    M1[0].y=0;
    M2[0].y=0;

    M2[1].x=SCORE_G;
    M2[1].stk_x=cuda_alm_node(x[0],'-');
    M1[2].x=SCORE_G+SCORE_E;
    M1[2].stk_x=cuda_alm_node(x[1],'-',cuda_alm_node(x[0],'-'));

    M1[1].m=afg_unit::equal(x[0]==y[0]);
    M1[1].y=M2[1].to_y();
    M1[1].x=M2[0].to_x();
    
    M1[1].stk_m=cuda_alm_node(x[0],y[0]);
    M1[1].stk_x=cuda_alm_node(x[0],'-',cuda_alm_node('-',y[0]));
    M1[1].stk_y=cuda_alm_node('-',y[0],cuda_alm_node(x[0],'-'));

    buf_mover=1;

    //GPU COPY
    cudaMalloc(&GM, (nsize+1)*sizeof(afg_unit));
    cudaMemcpy(GM, M, (nsize+1)*sizeof(afg_unit), cudaMemcpyHostToDevice);

    cudaMalloc(&GM1, (nsize+1)*sizeof(afg_unit));
    cudaMemcpy(GM1, M1, (nsize+1)*sizeof(afg_unit), cudaMemcpyHostToDevice);

    cudaMalloc(&GM2, (nsize+1)*sizeof(afg_unit));
    cudaMemcpy(GM2, M2, (nsize+1)*sizeof(afg_unit), cudaMemcpyHostToDevice);

    cudaMalloc(&gx, nsize*sizeof(char));
    cudaMemset(gx, 0, nsize*sizeof(char));
    cudaMemcpy(gx, x, xsize*sizeof(char), cudaMemcpyHostToDevice);

    cudaMalloc(&gy, (nsize+ysize+xsize-1)*sizeof(char));
    cudaMemset(gy, 0, (nsize+ysize+xsize-1)*sizeof(char));
    gy=gy+nsize;
    cudaMemcpy(gy, y, ysize*sizeof(char), cudaMemcpyHostToDevice);

    tmp=NEG_INF;
    cudaMalloc(&gmaxs, (nsize+1)*sizeof(int));
    cudaMemcpy(gmaxs+xsize,&tmp,sizeof(int),cudaMemcpyHostToDevice);

    cudaMalloc(&gbestalms, (nsize+1)*sizeof(alm_node*));
    cudaMemset(gbestalms+xsize,0,sizeof(alm_node*));

    //link list table
    alm_node_control alc(xsize);

    //可平行化運算
    while(buf_mover<ysize+xsize-1){
        calculate<<<nblock,nthread>>>(GM,GM1,GM2,gx,gy,buf_mover,gmaxs,gbestalms,alc);
        buf_mover++;
        if(buf_mover==ysize+xsize-1){
            break;
        }
        cudaMemcpy(GM2+1, GM1+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
        cudaMemcpy(GM1+1, GM+1, nsize*sizeof(afg_unit),cudaMemcpyDeviceToDevice);
    }

    //取出結果
    cudaMemcpy(&tmp,gmaxs+xsize,sizeof(int),cudaMemcpyDeviceToHost);
    printf("best's score: %d\n",tmp);
    cudaMemcpy(&best_alm,gbestalms+xsize,sizeof(alm_node*),cudaMemcpyDeviceToHost);
    ptr_stk(best_alm,argv[3]);
    printf("ALM saved finish!!\n");
}

