#ifndef SEQ_H
#define SEQ_H
#include "comm.cuh"

class sequence{
private:
    byte *cdata,*gdata;
    int sz;
    sequence(byte*_cdata,byte*_gdata,int _size){
        cdata=_cdata;
        gdata=_gdata;
        sz=_size;
    }
public:
    sequence(char* filename){
        FILE* file=fopen(filename,"r");
        if(file==NULL){
            printf("error: file %s not found\n",filename);
            exit(0);
        }
        fseek(file,0,SEEK_END);
        sz=ftell(file);
        fseek(file,0,SEEK_SET);
        cdata=oalloc<byte>(sz+1);
        cdata[0]=0;
        int j=0;
        char c;
        while(c=my_get_ch(file),c!=EOF){
            byte b=score::char2byte(c);
            if(b==(byte)-1){
                printf("error: in %s, base [%c] is not defined in score matrix\n",filename,c);
                exit(0);
            }
            cdata[j+1]=b;
            j++;
        }
        sz=j;
        cudaMalloc(&gdata,sizeof(byte)*(sz+1));
        cudaMemcpy(gdata,cdata,sizeof(byte)*(sz+1),cudaMemcpyHostToDevice);
        fclose(file);
    }
    sequence(){}
    __all__ inline int size(){
        return sz;
    }
    sequence subseq(int i,int count){
        if(i<1){
            printf("error: start of sequence need to start from 1\n");
            exit(0);
        }
        return sequence(cdata+i-1,gdata+i-1,count);
    }
    __all__ inline byte cget(int i){
        return cdata[i];
    }
    __all__ inline byte gget(int i){
        return gdata[i];
    }
    __host__ inline sequence print_out(){
        printf("[");
        for(int i=1;i<=sz;i++){
           printf("%c",score::Char_map[cdata[i]]);
        }
        printf("]\n");
        return *this;
    }
};




#endif