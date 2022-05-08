#ifndef TEST_TIME_H
#define TEST_TIME_H
#include <cstdio>
#include <ctime>
namespace mytime {
    namespace protected_space{
        clock_t tStart;
    }
    void start(){
        protected_space::tStart = clock();
        
    }
    void end(){
        printf("\nTime taken: %.2fs\n", (double)(clock() - protected_space::tStart)/CLOCKS_PER_SEC);
    }
}

#endif