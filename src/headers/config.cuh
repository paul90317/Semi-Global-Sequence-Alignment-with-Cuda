#ifndef CONFIG_H
#define CONFIG_H

typedef int datatype;//資料型態可改 double 或 int
#define NEG_INF -10000000 //最小值，可改
#define THREAD_SIZE 1024 //最大 1024，最小 1
const char filename_x[]="../res/x.txt";
const char filename_y[]="../res/y.txt";
const char filename_best_score_interval[]="../res/best.txt";
#define X_FREE_START true
#define Y_FREE_START true
#define X_FREE_END true
#define Y_FREE_END true
#define SCORE_G -2.0
#define SCORE_E -1.0
#define CHAR_NUMBER 5 //所有字元個數，包含空字元
namespace protected_space{
    char const Char_map[CHAR_NUMBER]={'-','A','T','C','G'};//0 是 空字元 '-'
    datatype const score_matrix[CHAR_NUMBER][CHAR_NUMBER]={
        {NEG_INF,NEG_INF,NEG_INF,NEG_INF,NEG_INF},
        {NEG_INF,1,-1,-1,-1},
        {NEG_INF,-1,1,-1,-1},
        {NEG_INF,-1,-1,1,-1},
        {NEG_INF,-1,-1,-1,1},
    };
}

#endif