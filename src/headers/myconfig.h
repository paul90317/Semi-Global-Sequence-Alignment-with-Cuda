#ifndef MY_CONFIG_H
#define MY_CONFIG_H

//GPU calculation
#define THREAD_SIZE 128 //thread size (>=1,<=1024)

//best interval stack
#define BEST_STACK_SIZE 30 //how many intervals can the best stack store (>=1)
#define SAFE_PUSH_MODE true //should detect the best stack is full
#define BEST_DIFF 1 //upper bound that how much less than the optimal alignment score can alignment be pushed into the optimal solution stack

//how many intervals should show.(semi_interval.exe)
#define BEST_SHOW_NUMBER 3

#define DEFAULT_INTERVAL_INDEX 0 //which interval used by alignment.exe, just set to 0.

//semi global settings for semi_interval.exe
#define X_FREE_START false
#define X_FREE_END false
#define Y_FREE_START false
#define Y_FREE_END false

//score matrix
typedef double datatype;//The data type of the score matrix, recommended double and int
#define NEG_INF -10000000 // the negative infinity value of the score

//float number
#define FLOAT_ERROR 0.05 //if the result difference in this value, it's ok. (alignment.exe)
#define FLOAT_PRECISION 5 //how many precision of best score should be outputed. (semi_interval.exe)

//alignment.exe return point.
#define ALM_END_POINT_SIZE ((long long unsigned int)60000) //how small the sub sequence does DFS call 2D alignment.

#endif