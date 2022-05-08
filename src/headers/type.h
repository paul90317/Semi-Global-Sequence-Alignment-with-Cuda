#ifndef TYPE_H
#define TYPE_H
#include <fstream>
#include <stack>
#include <cstdio>
#include <iostream>
typedef unsigned char byte;
typedef long long unsigned size_2D;
#define __all__ __device__ __host__
#define _single <<<1,1>>>
#define _kernel(nb,nt) <<<(nb),(nt)>>>
#endif