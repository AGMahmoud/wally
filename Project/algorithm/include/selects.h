#include <cstdio>


// selection problem
// input: N个数，a1, a2, a3, ..., aN
// output: 第k个最大数ap


// 排序选择法: 首先对数组进行排序，然后返回索引为k的元素
// SORT-SELECT(A, k)
// sort(A)
// return A(k)

/// \brief 返回数组的第k个最大
/// \param  arr 数组
/// \param  len 数组长度
/// \param  k 第k
/// \return  所求的第k大数
template<class T>
T sort_select(T arr[], size_t len, size_t k)
{
  if(len < k){
    return -1;
  }

  // bubble sort
  for(int i=0; i<len; i++){
    bool no_swap = true;
    for(int j=0; j<len-i-1; j++)
      if(arr[j] < arr[j+1]){
	T temp = arr[j];
	arr[j] = arr[j+1];
	arr[j+1] = temp;
	no_swap = false;
      }

    if(no_swap)
      break;
  }
  return arr[k-1];
}


// 优化排序选择法：首先读入前k个元素并排序，之后将剩下的元素逐个读入，插入到适当位置，并将末尾元素挤出
// OPTIMIZED-SORT-SELECT(A, k)
// for i = 1:k
//     B[i] = A[i]
// sort(B)
// for i = k+1 to A.length
//     j = k
//     key = A[i]
//     while B[j]<key and j>1
//         B[j]=B[j-1]
//         j=j-1
//     B[j-1] = key
// return B[k]
//

template<class T>
T optimized_sort_select(T arr[], size_t len, size_t k)
{
  if(len < k)
    return -1;

  T brr[k];
  for(int i=0; i<k; i++)
    brr[i] = arr[i];

  // insert-sort
  for(int i=1; i<k; i++){
    T key = brr[i];
    int j = i-1;
    while(brr[j]<key && j>=0){
      brr[j+1] = brr[j];
      j--;
    }
    brr[j+1] = key;
  }

  for(int i=k; i<len; i++){
    int j = k-1;
    T key = arr[i];
    while(brr[j]<key && j>=0){
      brr[j]=brr[j-1];
      j--;
    }
    brr[j+1] = key;
  }
  return brr[k-1];
}
