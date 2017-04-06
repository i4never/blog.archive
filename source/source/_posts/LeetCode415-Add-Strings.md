---
title: LeetCode415 Add Strings
date: 2017-04-06 15:20:31
tags: [C, 踩过的坑]
categories: [LeetCode]
---

LeetCode415，同学刷题的时候问到这道题，本身不难，但是因为C memcpy的坑纠结了一下。

[Question link][1]

# Description
Given two non-negative integers num1 and num2 represented as string, return the sum of num1 and num2.

Note:
The length of both num1 and num2 is < 5100.
Both num1 and num2 contains only digits 0-9.
Both num1 and num2 does not contain any leading zero.
You must not use any built-in BigInteger library or convert the inputs to integer directly.

<!--more-->

# Solution
计算两个字符串的长度，假设为``len1 len2``，答案``res``长度为``max(len1, len2)+1`` ，多一位是为了进位的情况。分别从字符串尾部开始一位一位加，最后得到res，根据结果再决定是否需要去掉开头多的一位。
## Code
```c
char* addStrings(char* num1, char* num2) {
    int len1,len2;
    for (len1 = 0 ; num1[len1] != 0 ; len1++)
        ;
    for (len2 = 0 ; num2[len2] != 0 ; len2++)
        ;
    int res_len;
    if (len1 > len2)
        res_len = len1 + 2;
    else
        res_len = len2 + 2;
    
    char * res;
    res = (char*)malloc(sizeof(char)*res_len);
    memset(res, 0 , res_len);
  
    for (int i = 1, carry = 0 ; len1-i >= 0 || len2-i >= 0 || carry != 0 ; i++)
    {
        int sum = carry;
        sum += len1-i < 0 ? 0 : num1[len1-i] - '0';
        sum += len2-i < 0 ? 0 : num2[len2-i] - '0';
        res[res_len-i-1] = sum%10 + '0';
        carry = sum/10;
    }
    
    if (res[0] == 0)
    {
        char * res_;
        res_ = (char*)malloc(sizeof(char)*(res_len-1));
        memcpy(res_, res+1, res_len-1);
        free(res);
        return res_;
    }
        
    return res;
    
}
```
关键在于``memcpy``函数这里，开始是这样写的：``memcpy(res, res+1, res_len-1)``，结果无论如何都不对，最后翻了man，其中有这样一句话：
{% centerquote %}
If dst and src overlap, behavior is undefined.  Applications in which dst and src might overlap should use memmove(3) instead.
{% endcenterquote %}
``memcpy``的src与dst不能有重叠的部分，否则结果不保证。如果有重叠的部分，推荐使用memmove。也就是说，最后的if条件里的部分可以改成这样：
```c
if (res[0] == 0)
{
    memmove(res, res+1, res_len-1);
    return res;
}
```

[1]: https://leetcode.com/problems/add-strings/