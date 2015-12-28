#include <stdio.h>
#include <limits.h>		// 宏定义整型变量的极限值
#include <float.h>		// 宏定义浮点型变量的极限值

// 将数组传递给函数参数的实质是指针传递
// 在函数中对数组的操作将直接影响到数组在内在中的存储
// 即，地址传递将产生副作用
// 并没有什么原则要求所有的函数进行值传递，选择哪种方式要因地制宜，因时制宜，因需制宜
// 数组排序的时候要从”简“，即功能最小化，是否拷贝应该在程序中考虑，而不是函数中
// 标准库algorithm中的sort函数的返回值为void，而不是数组指针，这是最好的印证


template<class T>
void select_sort(T arr[], size_t len);

template<class T>
void bubble_sort(T arr[], size_t len);

template<class T>
void insert_sort(T arr[], size_t len);

template<class T>
void merge_sort(T arr[], size_t head, size_t tail);

template<class T>
void quick_sort(T arr[], size_t left, size_t right);

template<class T>
void shell_sort(T arr[], size_t len);

template<class T>
void heap_sort(T arr[], size_t len);



// SELECT-SORT(A)
// for i = 1 TO A.length
//   for j = i+1 TO A.length
//       if A[i] > A[j]
//           temp = A[i]
//           A[i] = A[j]
//           A[j] = temp
//
// 复杂度： O(n^2)
// 循环不变式：每次循环将第n小的值放到对应位置
// 算法优化： 类似BUBBLE-SORT一样，增加一个布尔变量标志是否已经排序完成

template<class T>
void select_sort(T arr[], size_t len)
{
  for(int i=0; i<len; i++){
    for(int j=i+1; j<len; j++)
      if(arr[j] < arr[i]){
	T temp = arr[i];
	arr[i] = arr[j];
	arr[j] = temp;
      }
  }
}




// INSERT-SORT(A)
// for i = 2 TO A.length
//   key = A[i]
//   j = i-1
//   while j>0 and A[j]>key
//       A[j+1] = A[j]
//       j = j-1
//   A[i+1] = key
//
// 复杂度： O(n^2)
// 循环不变式： 每次迭代后对应的前段是排好序的

template<class T>
void insert_sort(T arr[], size_t len)
{
  for(int i=1; i<len; i++){
    T key = arr[i];
    int j = i-1;
    while(j>=0 && arr[j]>key){
      arr[j+1] = arr[j];
      j--;
    }
    arr[j+1] = key;
  }
}


// MERGE(A, p, q, r)
// n1 = q-p+1
// n2 = r-q
// for i = 1 to n1
//   L[i] = A[p+i-1]
// for j = 1 to n2
//   R[j] = A[q+j]
// L[n1+1] = MAX
// R[n2+1] = MAX  //增加哨兵牌
// i = 1
// j = 1
// for k = p to r
//   if L[i] <= R[j]
//     A[k] = L[i]
//     i = i+1
//  else
//     A[k] = R[j]
//     j = j+1
//
// MERGE-SORT(A, p, r)
// if p<r
//   q = (p+r)/2
//      MERGE-SORT(A, p, q)
//      MERGE-SORT(A,q+1, r)
//      MERGE(A, p, q, r)
//
// 复杂度： O(nlogn)
// 分治法： 分解-解决-合并

template<class T>
void merge(T arr[], size_t p, size_t q, size_t r)
{
  int n1 = q - p + 1;
  int n2 = r - q;
  double l_arr[n1+1], r_arr[n2+1];
  for(int i=0; i<n1; i++)
    l_arr[i] = arr[p+i];
  l_arr[n1] = DBL_MAX;
  for(int j=0; j<n2; j++)
    r_arr[j] = arr[q+j+1];
  r_arr[n2] = DBL_MAX;

  int i=0, j=0, k;
  for(k=p; k<=r; k++){
    if(l_arr[i] < r_arr[j]){
      arr[k] = l_arr[i];
      i++;
    }
    else{
      arr[k] = r_arr[j];
      j++;
    }
  }
}

template<class T>
void merge_sort(T arr[], size_t head, size_t tail)
{
  if(head < tail){
    size_t mid = (head+tail)/2;
    merge_sort(arr, head, mid);
    merge_sort(arr, mid+1, tail);
    merge(arr, head, mid, tail);
  }
}


// BUBBLE_SORT(A)
// for i = 1 to A.length
//   for j = 1 to A.length-i
//     if A[j] > A[j]
//       tmp = A[j]
//       A[j] = A[j+1]
//       A[j+1] = tmp
//
// 复杂度： O(n^2)
// 循环不变式： 每次迭代将第n大的值移到对应位置
// 算法优化： 增加排序结束标志

template<class T>
void bubble_sort(T arr[], size_t len)
{
  for(int i=0; i<len; i++){
    bool no_swap = true;
    for(int j=0; j<len-1-i; j++){
      if(arr[j] > arr[j+1]){
	T temp = arr[j];
	arr[j] = arr[j+1];
	arr[j+1] = temp;
	no_swap = false;
      }
    }
    if(no_swap)
      break;
  }
}


template<class T>
void quick_sort(T arr[], size_t left, size_t right)
{}

template<class T>
void shell_sort(T arr[], size_t len){}

template<class T>
void heap_sort(T arr[], size_t len){}
