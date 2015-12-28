#include <iostream>
#include <cstdio>
#include "sorts.h"
#include "selects.h"
#include "recursive.h"

using namespace std;

template<class T>
inline void print_arr(T arr[], size_t len);

int main(int argc, char *argv[])
{
  // double arr[] = {0.2, -1.2, 23, 3.1, 0, 15, 17};
  // size_t len = sizeof(arr) / sizeof(double);
  // double tar = optimized_sort_select(arr, len, 2);
  // cout << tar << endl;


  // recursive
  // bad_recursive(1);

  printNum(123456789);

  return 0;
}


template<class T>
inline void print_arr(T arr[], size_t len){
  for(int i=0; i<len; i++){
    cout << arr[i] << ' ';
  }
  cout << endl;
}
