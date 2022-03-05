#ifndef CONFIG_H
#define CONFIG_H
#include <vector>


//GPU 計算參數
#define THREAD_SIZE 256 //最大 1024，最小 1

//最佳區間的儲存設定
#define BEST_STACK_SIZE 1000 //能儲存的最好解的最大值(最小1)，
#define SAFE_PUSH_MODE true //程式是否判定是否超過上限
#define BEST_DIFF 1 //定義與最佳比對分數少多少的上限，超過可以推入最佳解 stack

//顯示設定
#define BEST_SHOW_NUMBER 3 //指定 semi_interval.exe 顯示多少區間

//比對目標
#define DEFAULT_INTERVAL_INDEX 0 //指定 alignment.exe 對哪一條區間進行比對，從 0 開始
//腳本 script.py 會幫忙測試所有區間，此項已經不必修改

//semi 設定
#define X_FREE_START false
#define X_FREE_END false
#define Y_FREE_START false
#define Y_FREE_END false

//分數設定
typedef int datatype;//分數資料型態可改 double 或 int
#define NEG_INF -10000000 //分數默認極小值，可改

//alignment 中斷點設定
#define ALM_END_POINT_SIZE 60000ui64

#endif