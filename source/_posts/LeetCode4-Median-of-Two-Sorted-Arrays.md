---
title: LeetCode4 Median of Two Sorted Arrays
categories: LeetCode
date: 2017-03-06 09:33:04
tags: [LeetCode, C, BinarySearch]
---
LeetCode第四题。

[Question link][1]

# Description
There are two sorted arrays nums1 and nums2 of size m and n respectively.

Find the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).

<!--more-->

## Example
```
nums1 = [1, 3]
nums2 = [2]

The median is 2.0

nums1 = [1, 2]
nums2 = [3, 4]

The median is (2 + 3)/2 = 2.5
```

# Solution
用到的是BinarySearch，但是比较复杂，看了Discission中的[Share my O(log(min(m,n)) solution with explanation][2]后思路才比较清楚。主要的几点如下：
首先，中位数的作用是把一个数组分成左右两部分，并且就升序来说，左边一半最大的数字不能大于右边一半最小的数字，对于两个数组来说，我们可以找到这样两个位置把他们分成两半。
```
        left_A           |          right_A
A[0], A[1], ..., A[i-1]  |  A[i], A[i+1], ..., A[m-1]

        left_B           |          right_B
B[0], B[1], ..., B[j-1]  |  B[j], B[j+1], ..., B[n-1]
```
只要保证合并后的左右两部分个数满足``i+j == (m-i)+(n-j) or i+j == (m-i)+(n-j)+1``的话，根据元素个数的奇偶性，中位数分别为``max(A[i-1], B[j-1]) or (max(A[i-1], B[j-1])+min(A[i], B[j]))/2`` 
```
        left_part        |          right_part
A[0], A[1], ..., A[i-1]  |  A[i], A[i+1], ..., A[m-1]
B[0], B[1], ..., B[j-1]  |  B[j], B[j+1], ..., B[n-1]
```
其次，这里要注意必须保证``n<=m``，这是因为从``i+j == (m-i)+(n-j) or i+j == (m-i)+(n-j)+1``中我们可以得到``j = (m+n-2i)/2 or j = (m+n-2i+1)/2``，而i~[0,n]，如果``n>m``，那么j就可能小于0从而导致越界。

## Code
```c
//由于代码高亮的bug，加入define后高亮失效，这里注释掉，如有需要运行时请去掉注释
//#define MAX(a, b) (a>=b ? a : b);
//#define MIN(a, b) (a<=b ? a : b);

double findMedianSortedArrays(int* nums1, int nums1Size, int* nums2, int nums2Size)
{
    if (nums1Size == 0 && nums2Size == 0)
        return 0;
    if (nums1Size == 0)
        return nums2Size%2 == 0 ? 0.5*(nums2[nums2Size/2] + nums2[nums2Size/2-1]) : nums2[nums2Size/2] ;
    if (nums2Size == 0)
        return nums1Size%2 == 0 ? 0.5*(nums1[nums1Size/2] + nums1[nums1Size/2-1]) : nums1[nums1Size/2] ;

    if (nums1Size > nums2Size)
    {
        int * temp = nums2;
        nums2 = nums1;
        nums1 = temp;

        int size = nums2Size;
        nums2Size = nums1Size;
        nums1Size = size;
    }

    int i,j,imin,imax,num,half;
    double res = 0;
    num = nums1Size + nums2Size;
    half = num>>1;
    bool is_even = num%2 == 0 ? true : false;
    imin = 0;
    imax = nums1Size;

    while (true)
    {
        i = (imin + imax)>>1;
        j = half - i;
        if (i == 0 || j == nums2Size)
            if (nums2[j-1] <= nums1[i])
                break;
            else
                imin = i+1;
        if (i == nums1Size || j == 0)
            if (nums1[i-1] <= nums2[j])
                break;
            else
                imax = i-1;

        if (nums1[i-1] <= nums2[j])
            if (nums2[j-1] <= nums1[i])
                break;
            else
                imin = i+1;
        else
            imax = i-1;
    }

    double right_min,left_max;
    if (i == 0)
        left_max = nums2[j-1];
    else if (j == 0)
        left_max = nums1[i-1];
    else
        left_max = MAX(nums1[i-1], nums2[j-1]);

    if (i == nums1Size)
        right_min = nums2[j];
    else if (j == nums2Size)
        right_min = nums1[i];
    else right_min = MIN(nums1[i], nums2[j]);

    if (is_even)
        res = (left_max + right_min) / 2;
    else
        res = right_min;

    return res;
}

```

{%asset_img runtime.png RunTime%}

[1]: https://leetcode.com/problems/median-of-two-sorted-arrays/
[2]: https://discuss.leetcode.com/topic/4996/share-my-o-log-min-m-n-solution-with-explanation