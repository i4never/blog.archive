---
title: LeetCode Dynamic Programming I
date: 2017-03-15 09:50:41
tags: [LeetCode, Dynamic Programming, C]
categories: [LeetCode]
---

刷到leetcode第十题[Regular Expression Matching][1]，纠结了非常长的时间，终于accept。以往刷题都是看哪题顺(jian)眼(dan)就刷哪题，做完这题之后打算按一个一个Tag做，先从[专题Dynamic Programming][2]开始。
<!--more-->

# Dynamic Programming

{% post_link LeetCode3-Longest-Substring-Without-Repeating-Characters Longest Substring Without Repeating Characters%}
这个问题用到过动态规划，主要的想法是将待求解的问题分解为若干个规模更小的子问题，求解子问题后再合并，最终得到原问题的解。
动态规划基本步骤:
1. 找出最优解的性质，并刻划其结构特征。
2. 递归地定义最优值。
3. 以自底向上的方式计算出最优值。
4. 根据计算最优值时得到的信息，构造最优解。
刷了几题之后，感觉DP方法最难的就是怎样定义子问题，以及如何通过子问题的解得到原问题的解。考虑不清楚怎样刻画问题时，可以先试图用递归的方法定义问题。

# Solved Problems
## [10] Regular Expression Matching
### Description & Example
Implement regular expression matching with support for '.' and '*'.
```
'.' Matches any single character.
'*' Matches zero or more of the preceding element.

The matching should cover the entire input string (not partial).

The function prototype should be:
bool isMatch(const char *s, const char *p)

Some examples:
isMatch("aa","a") → false
isMatch("aa","aa") → true
isMatch("aaa","aa") → false
isMatch("aa", "a*") → true
isMatch("aa", ".*") → true
isMatch("ab", ".*") → true
isMatch("aab", "c*a*b") → true
```

### Sub Problem
首先递归地定义问题，假设当前模式串与字符串``p[i] s[j]``匹配，那么下一个要匹配的是``p[i+1] s[j+1]``，有如下几种情况：
1. ``p[i+1] == '\0'``：匹配结束，如果``s[j+1]``也是``\0``的话匹配完成，否则两者不匹配
```
               j j+1
s: a b c d e f g \0
         i i+1
p: a . * g \0
```
2. ``p[i+1] != '\0' && p[i+1] != '*'``：如果``p[i+1] == '.' || p[i+1] == s[i+1]``则两者匹配，否则不匹配。
```
               j j+1
s: a b c d e f g h s d\0
         i i+1
p: a . * g .  \0
```
3. ``p[i+1] == '*'``：这种情况最复杂。出现‘\*’意味着模式串‘\*’前的字符可以不出现或者出现任意多次。该字符不出现的情况下，如果模式串``p[i-1]``与``s[j+1]``匹配的话，``p[i+1]``与``s[j+1]``匹配；如果``p[i-1]``与``s[j+1]``匹配的前提下，``s[j+1]``之后出现任意多个字符``p[i]``，都与模式串``p[i+1]``匹配。
```
            j+1
s: a b c d e f h \0
            i-1 i+1
p: a b c d e f g * h \0

            j+1
s: a b c d e f g g g g h \0
            i-1 i+1
p: a b c d e f g * h \0
```
如此，构造一个bool数组``m[p_len][s_len]``来记录``p[i] s[j]``的匹配情况，从上到下逐行计算，就可以判断模式串是否匹配。有个tricky的地方是空串的匹配，构造数组的时候在字符串与模式串的开头多加了一行／列，方便处理。假设带匹配字符串与模式串分别为``s = "abcdddefg" p = "z*y*abcd*z*e.*"``，则计算结果如下：
{%asset_img 10_exp.png Example%}
其中黄色标注的是初识计算空字符串的匹配结果，很好理解，空字符串只能与类似于“x*x*x*”匹配。
### Code
```c
bool isMatch(char *s, char *p)
{
    int s_len = 0, p_len = 0;
    while(s[s_len] != 0) s_len++;
    while(p[p_len] != 0) p_len++;
    s_len++;p_len++;

    bool m[p_len][s_len];
    memset(m, 0, p_len*s_len);
    m[0][0] = true;
    for (int i = 1 ; i < p_len ; i++)
        m[i][0] = i > 1 && p[i-1] == '*' && m[i-2][0] ? true : false;

    for (int i = 1 ; i < p_len ; i++)
    {
        for (int j = 1 ; j < s_len ; j++)
        {
            if (p[i-1] != '*')
                m[i][j] = m[i-1][j-1] && (p[i-1] == '.' || p[i-1] == s[j-1]);
            else
                m[i][j] = m[i-2][j] || ((m[i][j-1]) && (p[i-2] == '.' || p[i-2] == s[j-1]));
        }
    }

    return m[p_len-1][s_len-1];
}
```
{%asset_img 10_dp_runtime.png Time used%}

## [44] Wildcard Matching
### Description & Example
Implement wildcard pattern matching with support for '?' and '*'.
```
'?' Matches any single character.
'*' Matches any sequence of characters (including the empty sequence).

The matching should cover the entire input string (not partial).

The function prototype should be:
bool isMatch(const char *s, const char *p)

Some examples:
isMatch("aa","a") → false
isMatch("aa","aa") → true
isMatch("aaa","aa") → false
isMatch("aa", "*") → true
isMatch("aa", "a*") → true
isMatch("ab", "?*") → true
isMatch("aab", "c*a*b") → false
```
### Sub Problem
与上题相似的是这题，唯一的区别是‘\*’在这里相当于第10题中的字符+‘\*’，大家可以试着自己分解一下子问题。
### Code
```c
bool isMatch(char *s, char *p)
{
    int s_len = 0, p_len = 0;
    while(s[s_len] != 0) s_len++;
    while(p[p_len] != 0) p_len++;
    s_len++;p_len++;

    bool m[p_len][s_len];
    memset(m, 0, p_len*s_len);
    m[0][0] = true;
    for (int i = 1 ; i < p_len ; i++)
        m[i][0] = p[i-1] == '*' && m[i-1][0] ? true : false;

    for (int i = 1 ; i < p_len ; i++)
    {
        for (int j = 1 ; j < s_len ; j++)
        {
            if (p[i-1] != '*')
                m[i][j] = m[i-1][j-1] && (p[i-1] == '?' || p[i-1] == s[j-1]);
            else
                m[i][j] = m[i-1][j] || m[i][j-1];
        }
    }
```

## [32] Longest Valid Parentheses
### Description & Example
Given a string containing just the characters '(' and ')', find the length of the longest valid (well-formed) parentheses substring.
For "(()", the longest valid parentheses substring is "()", which has length = 2.

Another example is ")()())", where the longest valid parentheses substring is "()()", which has length = 4.

### Sub Problem
假设待匹配的字符串为p，当前计算到``p[i]``为止的最长合法串，下一个需要计算``p[i+1]``，数组``l[i]``纪录以``p[i]``结尾的合法子串长度，有以下几种情况。
1. 如果``p[i+1] == '(' ``，因为不会有以‘(’结尾的合法串，即``l[i+1] = 0``。
2. 如果``p[i+1] == ')' ``那么需要判断``p[i]``是否为‘(’：
    如果``p[i] == '('``，那么以``p[i+1]``结尾的合法子串长度是以``p[i]``结尾的合法子串长度加2，即``l[i+1]=l[i-1]+2``。
    如果``p[i] == '('``那么需要找到``p[i-l[i]-1]``，判断其是否是‘(’，如果是，则这个左括号与当前右括号把中间的合法子串括了起来，共同构成一个合法串，长度为``l[i]+2``并且可能与``p[i-l[i]-2]``链接起来，共同构成合法串。
    ```
    i   0 1 2 3 4 5 6 7 8 9
    p = ) ) ) ) ( ) ( ( ) )
    l = 0 0 0 0 0 2 0 0 2 6
    ```
``l[i]``的最大值即为最长合法串。

### Code
```c
int longestValidParentheses(char* s) {
    if (s[0] == 0)
        return 0;

    int len = 0;
    while (s[len] != 0) len++;
    int l[len], max = 0;
    l[0] = 0;
    for (int i = 1 ; i < len ; i++)
    {
        if (s[i] == '(')
            l[i] = 0;
        else
        {
            if (s[i-1] == '(')
                l[i] = i>1 ? l[i-2] + 2 : 2;
            else
                l[i] = s[i-1-l[i-1]] == '(' ? l[i-1] + 2 + (i-2-l[i-1] >= 0 ? l[i-2-l[i-1]] : 0) : 0;
        }
        max = max >l[i] ? max : l[i];
    }
    return max;
}
```

## [53] Maximum Subarray
### Description & Example
Find the contiguous subarray within an array (containing at least one number) which has the largest sum.
For example, given the array [-2,1,-3,4,-1,2,1,-5,4],
the contiguous subarray [4,-1,2,1] has the largest sum = 6.

### Sub problem
《算法导论》开篇就是这个问题，用的是分治法，类似于quick sort的思想，先求左半边，再求右半边，然后左右合并以下。但是这里依然用动态规划的方法来求解
假设数组为``nums``，数组``m[i]``纪录以``nums[i]``为结尾的最大子序列和。同样的，假设当前计算到``m[i+1]``
1. 如果``m[i]<=0``，那么前面的项对最大和没有贡献，以当前元素为结尾的最大和就是他本身，即``m[i+1]=nums[i+1]``
2. 如果``m[i]>0``，那么``m[i+1]=m[i]+nums[i+1]``
``m[i]``的最大值即为最大和

### Code
```c
int maxSubArray(int* nums, int numsSize) {
    if (numsSize == 0)
        return 0;
    int max = nums[0], p[numsSize];
    p[0] = nums[0];
    for (int i = 1 ; i < numsSize ; i++)
    {
        p[i] = p[i-1] < 0 ? nums[i] : p[i-1] + nums[i];
        max = max > p[i] ? max : p[i];
    }
    return max;
}
```

## [62] Unique Paths
### Description & Example
A robot is located at the top-left corner of a m x n grid (marked 'Start' in the diagram below).

The robot can only move either down or right at any point in time. The robot is trying to reach the bottom-right corner of the grid (marked 'Finish' in the diagram below).

How many possible unique paths are there?
Note: m and n will be at most 100.

### Sub problem
这题比较简单，构造一个与map大小相等的数组，由于只能向下或者向右走，走到``m[i+1][j+1]``的方法有两种，一是先走到``m[i][j+1]``再向右走，另一种是先走到``m[i+1][j]``再向下走，也就是``m[i+1][j+1]=m[i][j+1]+m[i+1][j]``。此外注意第一行和第一列的初始化就可以了。
[Discuss][3]中有人提到这其实是个排列组合的问题，可以直接求解排列数，想法没有问题，但是需要计算$(m+n)!$，当m和n较小时没有问题，较大时可能超出int或者long的表示范围，带来一定的问题。

### Code
```c
int uniquePaths(int m, int n) {
    if (n == 1 || m == 1)
        return 1;
        
    int p[n][m];
    
    for (int i = 0 ; i < n ; i++)
        p[i][0] = 1;
    for (int i = 0 ; i < m ; i++)
        p[0][i] = 1;
    for (int i = 1 ; i < n ; i++)
        for (int j = 1 ; j < m ; j++)
            p[i][j] = p[i-1][j] + p[i][j-1];
    
    return p[n-1][m-1];
}
```

## [63] Unique Paths II
### Description & Example
Follow up for "Unique Paths":

Now consider if some obstacles are added to the grids. How many unique paths would there be?

An obstacle and empty space is marked as 1 and 0 respectively in the grid.

For example,
There is one obstacle in the middle of a 3x3 grid as illustrated below.
```
[
  [0,0,0],
  [0,1,0],
  [0,0,0]
]
The total number of unique paths is 2.
```

### Sub problem
与上题相同，注意map中标注1的格子走不到，即``m[i][j]=map[i][j]==1 ? 0 : m[i][j+1]+m[i+1][j]``。

### Code
```c
int uniquePathsWithObstacles(int** obstacleGrid, int obstacleGridRowSize, int obstacleGridColSize) {
    int p[obstacleGridRowSize][obstacleGridColSize];
    
    for (int i = 0 ; i < obstacleGridRowSize ; i++)
        p[i][0] = obstacleGrid[i][0] == 1 || (i>0 && p[i-1][0] == 0) ? 0 : 1;
    for (int i = 0 ; i < obstacleGridColSize ; i++)
        p[0][i] = obstacleGrid[0][i] == 1 || (i>0 && p[0][i-1] == 0) ? 0 : 1;
    for (int i = 1 ; i < obstacleGridRowSize ; i++)
        for (int j = 1 ; j < obstacleGridColSize ; j++)
            p[i][j] = obstacleGrid[i][j] == 1 ? 0 : p[i-1][j] + p[i][j-1];  
    
    return p[obstacleGridRowSize-1][obstacleGridColSize-1];
}
```

## [64] Minimum Path Sum
### Description & Example
Given a m x n grid filled with non-negative numbers, find a path from top left to bottom right which minimizes the sum of all numbers along its path.

Note: You can only move either down or right at any point in time.

### Sub problem
同上两题，判断``m[i+1][j+1]``时，选择上方和左方cost比较小的值走就可以了。

### Code
```c
int minPathSum(int** grid, int gridRowSize, int gridColSize) {
    int p[gridRowSize][gridColSize];
    for (int i = 0 ; i < gridRowSize ; i++)
        p[i][0] = i > 0 ? p[i-1][0]+grid[i][0] : grid[i][0];
    for (int i = 0 ; i < gridColSize ; i++)
        p[0][i] = i > 0 ? p[0][i-1]+grid[0][i] : grid[0][i];
       
    
    for (int i = 1 ; i < gridRowSize ; i++)
        for (int j = 1 ; j < gridColSize ; j++)
            p[i][j] = p[i-1][j] < p[i][j-1] ? p[i-1][j] + grid[i][j] : p[i][j-1] + grid[i][j];
        
    return p[gridRowSize-1][gridColSize-1];
        
}
```

## [70] Climbing Stairs
### Description & Example
You are climbing a stair case. It takes n steps to reach to the top.

Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?

Note: Given n will be a positive integer.

### Sub problem
爬到第n级台阶（n>2）有两种方法，第一种是先爬到n-2然后爬两步，第二种是先爬到n-1再爬一步。所以如果用``step[i]``表示爬到第i级台阶的方法，那么``step[i+2]=step[i]+step[i+1]``并且``step[1]=1 step[2] =2``。

### Code
```c
int climbStairs(int n) {
    if (n == 1 || n == 2)
        return n;
    int step[n+1];
    step[0] = 0;
    step[1] = 1;
    step[2] = 2;
    
    for (int i = 3 ; i < n+1 ; i++)
        step[i] = step[i-2] + step[i-1];
    return step[n];
}
```



[1]: https://leetcode.com/problems/regular-expression-matching/#/description
[2]: https://leetcode.com/tag/dynamic-programming
[3]: https://discuss.leetcode.com/category/70/unique-paths
