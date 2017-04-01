---
title: LeetCode3 Longest Substring Without Repeating Characters
categories: LeetCode
date: 2017-02-17 13:28:23
tags: [LeetCode, C, Java, String, Dynamic Programming]
---

LeetCode第三题。

[Question link][1]

# Description
Given a string, find the length of the longest substring without repeating characters.

<!--more-->

## Example
```
Given "abcabcbb", the answer is "abc", which the length is 3.

Given "bbbbb", the answer is "b", with the length of 1.

Given "pwwkew", the answer is "wke", with the length of 3.
Note that the answer must be a substring, "pwke" is a subsequence and not a substring.
```

# Solution
字符串处理经常在算法中出现，所用的方法也千变万化。本题希望找到字符串中最长的没有重复字符的子串。
首先，最简单的方法当然是暴力破解。从每个字符开始，向后寻找符合要求的最长子串，代码基本是如下三层循环，复杂度为$O(n^3)$：
```c
char s = "abcadfasdf";
for (i = 0 ; i < size ; i++)
    for (j = i+1 ; j < size ; j++)
        //check whether the character has appeared
        for (k = i ; k < j ; k++)
            //...    
    //update temp longest length
```
当然，引入一个hash数组可以减少一些计算复杂度。由于char类型占1byte，8bit，有256种可能，所以引入一个size为256的数组，用于记录该字符是否出现过，在检查是否重复时可以避免循环，复杂度降为$O(n^2)$。
```c
char s = "abcadfasdf";
int hash[256];
memset(hash, 0 , 256);
for (i = 0 ; i < size ; i++)
    for (j = i+1 ; j < size ; j++)
        hash[s[j]] == 0? 
        //...
    //update temp longest length
```
进一步降低复杂度，就不能依靠暴力破解的方法，需要引入动态规划的思想。
## Dynamic Programming
动态规划与分治法的想法类似，目标是将待求解的问题分解为若干个规模更小的子问题，求解子问题后再合并，最终得到原问题的解。
{% asset_img dp1.jpg 子问题分解 %}
动态规划与分治法的不同在于，分治法的子问题是独立的，相互不包含（例如快速排序），而动态规划分解后的子问题往往不是相互独立的。
{% asset_img dp2.jpg 动态规划子问题 %}
动态规划有以下几个基本步骤：
动态规划基本步骤:
1. 找出最优解的性质，并刻划其结构特征。
2. 递归地定义最优值。
3. 以自底向上的方式计算出最优值。
4. 根据计算最优值时得到的信息，构造最优解。

放到这个问题里来看，寻找最长不重复子串的过程中，新子串的长度与重复字符出现的位置有关。假如当前寻找的子串起始位置为x，下一个字符位置为y，如果该字符上一次出现的位置z在x之前（z<x），或者该字符没有出现过，那么该字符就可以纳入到当前符合要求的子串中，继续向后寻找；如果该字符上一次出现的位置在x之后(z>=x)，那么以当前位置为结尾的符合要求的子串从z+1开始，到当前位置结束。
下图以字符串"aadbcabcdeaa"为例，直观地给出了计算过程：
{% asset_img example.png example%}
每一行记录的都是到当前字符的最长不重复子串，第一个字符为起始位置``last_start``。蓝色标注的第1，5，6，7，10，11次循环中，当前字符上一次出现位置（``last_loc``）都在上一次计算的起始位置``last_start``之后（``last_loc>=last_start``），所以``last_start``更新为``last_loc+1``；其余循环中，字符上一次出现位置都在当前子串起始位置之前，（``last_loc<last_start``），对于当前子串没有影响，可以将字符纳入到当前子串中。如此计算，最后可得到符合要求的最长不重复子串。
计算``last_loc``数组可以用上文所述的hash方法，复杂度为$O(n)$，使用动态规划的方法，计算子串的复杂度也为$O(n)$，最后在线性时间内可以求解这个问题。
## Code
### C
```c
int lengthOfLongestSubstring(char* s) {
    int size;
    for (size = 0 ; s[size] ; size++)
        ;
    // empty string
    if (size == 0)
        return 0;

    int last_loc[size];
    int hash[256];
    for (int i = 0 ; i < 256 ; i++)
        hash[i] = -1;
    for (int i = 0 ; i < size ; i++)
    {
        last_loc[i] = hash[s[i]];
        hash[s[i]] = i;
    }

    int longest = 1, last_start = 0, temp_max = 1;

    for (int i = 1 ; i<size ; i++)
    {
        if (last_loc[i] >= last_start)
            last_start = last_loc[i] + 1;
        temp_max = i - last_start + 1;
        longest = temp_max > longest ? temp_max : longest;
    }

    return longest;
}
```
{% asset_img c_runtime1.png Time used for C solution %}
### Java
```java
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        if (s.length() == 0)
            return 0;
        
        int[] hash = new int[256];
        int[] last_loc = new int[s.length()];
        for (int i = 0 ; i < 256 ; i++)
            hash[i] = -1;
        for (int i = 0 ; i < s.length() ; i++)
        {
            last_loc[i] = hash[s.charAt(i)];
            hash[s.charAt(i)] = i;
        }

        int longest = 0, last_start = 0, temp_max = 1;
        
        for (int i = 0 ; i < s.length() ; i++)
        {
            if (last_loc[i] >= last_start)
                last_start = last_loc[i] + 1;
            temp_max = i - last_start + 1;
            longest = temp_max > longest ? temp_max : longest;
        }
        
        
        return longest;
    }
}
```
{% asset_img java_runtime.png Time used for Java solution %}

没有用到什么特别的，对于这题来说String类感觉还不如C来的方便。

# Discuss
本以为写到这个程度已经可以了，看了Discuss中的[这个解答][2]才发现，何必hash时候循环一遍，再循环一遍求符合要求的子串，完全可以放在一次循环里做。
```c
nt lengthOfLongestSubstring(char* s) {
    int size;
    for (size = 0 ; s[size] ; size++)
        ;
    // empty string
    if (size == 0)
        return 0;

    int hash[256];
    //initialize
    for (int i = 0 ; i < 256 ; i++)
        hash[i] = -1;


    int longest = 1, last_start = 0, temp_max = 1;

    for (int i = 0 ; i < size ; i++)
    {
        if (hash[s[i]] >= last_start)
            last_start = hash[s[i]] + 1;
        temp_max = i - last_start + 1;
        longest = temp_max > longest ? temp_max : longest;
        hash[s[i]] = i;
    }

    
    return longest;
}
```
{% asset_img c_runtime2.png Time used for C solution %}

[1]: https://leetcode.com/problems/longest-substring-without-repeating-characters/
[2]: https://discuss.leetcode.com/topic/8232/11-line-simple-java-solution-o-n-with-explanation