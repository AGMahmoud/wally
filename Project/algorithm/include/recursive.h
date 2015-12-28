#include <stdio.h>
#include <iostream>


// 递归的四条基本法则
// 1. 基本情形：必须总有某些基本情形不用递归就能求解
// 2. 不断推进：对于需要递归求解的情形，递归调用必须总能朝着基准情形的方向推进
// 3. 设计法则：假设所有的递归调用都能运行
// 4. 合成效益法则：在求解一个问题的同一实例时，切勿在不同的递归中调用重复性的工作

int bad_recursive(int n)
{
  if(0 == n)
    return 0;
  else
    return bad_recursive(n / 3 + 1) + n - 1;
}



int printDigit(int n)
{
  if(n<0 || n>9)
    return -1;
  std::cout << n;
  return 0;
}

void printNum(int n){
  if(n >= 10)
    printNum(n / 10);		// 为了要打印出76234,需要先打印出7623,
  printDigit(n % 10);		// 然后再打印4
}
