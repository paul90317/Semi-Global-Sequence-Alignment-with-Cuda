#ifndef CONFIG_H
#define CONFIG_H

//GPU 計算參數
#define THREAD_SIZE 1024 //最大 1024，最小 1

//最佳區間的儲存設定
#define BEST_STACK_SIZE 1000 //能儲存的最好解的最大值(最小1)，
#define SAFE_PUSH_MODE true //程式是否判定是否超過上限
#define BEST_DIFF 3 //定義與最佳比對分數少多少的上限，超過可以推入最佳解 stack

//檔案
const char filename_x[]="../res/NC_000014.9[33600000..34599999].fa";//序列一
const char filename_y[]="../res/NC_000006.12[100000..1099999].fa";//序列二
const char filename_best_score_interval[]="../res/best.txt";//區間結果儲存

//semi 設定
#define X_FREE_START true
#define Y_FREE_START true
#define X_FREE_END true
#define Y_FREE_END true

//分數設定
typedef int datatype;//分數資料型態可改 double 或 int
#define NEG_INF -10000000 //分數默認極小值，可改
#define SCORE_G -2.0 //GAP score
#define SCORE_E -1.0 //Extension score
#define CHAR_NUMBER 5 //所有字元個數，包含空字元 '-'
namespace protected_space{
    //0 是 空字元 '-'
    char const Char_map[CHAR_NUMBER]={'-','A','T','C','G'};
    //注意邊界要是 NEG_INF，這並非 gap, extension 設定
    datatype const score_matrix[CHAR_NUMBER][CHAR_NUMBER]={
        {NEG_INF,NEG_INF,NEG_INF,NEG_INF,NEG_INF},
        {NEG_INF,1,-1,-1,-1},
        {NEG_INF,-1,1,-1,-1},
        {NEG_INF,-1,-1,1,-1},
        {NEG_INF,-1,-1,-1,1},
    };
}

#endif