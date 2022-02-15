#ifndef UTILS
#define UTILS

template<typename T>
inline void gmalloc(T** arr,int sz){
    cudaMalloc(arr, (sz)*sizeof(T));
}

template<typename T>
inline void gmemcpy_h2d(T* dst, T* src, int sz){
    cudaMemcpy(dst, src, sz*sizeof(T), cudaMemcpyHostToDevice);
}

template<typename T>
inline void gmemcpy_d2d(T* dst, T* src, int sz){
    cudaMemcpy(dst, src, sz*sizeof(T), cudaMemcpyDeviceToDevice);
}

template<typename T>
inline void gmemcpy_d2h(T* dst, T* src, int sz){
    cudaMemcpy(dst, src, sz*sizeof(T), cudaMemcpyDeviceToHost);
}

template<typename T>
inline void gmemset(T* arr, char val, int sz){
    cudaMemset(arr, val, sz*sizeof(T));
}

template<typename T>
inline void gassign(T* p,T val){
    gmemcpy_h2d(p,&val,sizeof(T));
}
#endif