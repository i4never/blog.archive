---
title: LeetCode2 Add Two Numbers
categories: LeetCode
date: 2017-01-13 16:25:08
tags: [LeetCode, C, Java, Python]
---

LeetCode第二题。

[Question link][1]

# Description
You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

<!--more-->

## Example
```
Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
```

# Solution
仿佛就是一个简单的链表操作，没有什么特殊的algorithm，解法如下：
## C
```c
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     struct ListNode *next;
 * };
 */
struct ListNode* addTwoNumbers(struct ListNode* l1, struct ListNode* l2)
{
    struct ListNode* res,*pt,*node;
    int j = 0,temp = 0;
    res = (struct ListNode*) malloc(sizeof(struct ListNode));
    res->next = NULL;
    pt = res;
    while (l1 != NULL || l2 != NULL || j!=0)
    {
        node = (struct ListNode*) malloc(sizeof(struct ListNode));
        temp = (l1 ? l1->val : 0) + (l2 ? l2->val : 0) + j;
        node->val = temp%10;
        j = temp/10;
        node->next = NULL;
        pt->next = node;
        pt = node;
        l1 = l1 ? l1->next : l1;
        l2 = l2 ? l2->next : l2;
    }
    pt = res->next;
    free(res);
    return pt;
}
```
{% asset_img c_runtime.png Time used for C solution %}

## Java
```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) { val = x; }
 * }
 */
public class Solution {
    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
       if (l1 == null && l2 == null)
            return null;
        
        int carry, sum;
        carry = sum = 0;
        ListNode result = new ListNode(-1);
        ListNode pt = result;
        pt.next = null;
        while (carry !=0 || l1 != null || l2 != null)
        {
            sum = carry;
            sum += l1 == null ? 0 : l1.val;
            sum += l2 == null ? 0 : l2.val;
            pt.next = new ListNode(sum%10);
            carry = sum/10;
            pt.next.next = null;
            pt = pt.next;
            l1 = l1 == null? null : l1.next;
            l2 = l2 == null? null : l2.next;
        }
        
        return result.next;
    }
}
```
{% asset_img java_runtime.png Time used for Java solution %}

# Discussion
贴个高票Python答案，其实都大同小异。
```python
class Solution:
# @return a ListNode
def addTwoNumbers(self, l1, l2):
    carry = 0
    root = n = ListNode(0)
    while l1 or l2 or carry:
        v1 = v2 = 0
        if l1:
            v1 = l1.val
            l1 = l1.next
        if l2:
            v2 = l2.val
            l2 = l2.next
        carry, val = divmod(v1+v2+carry, 10)
        n.next = ListNode(val)
        n = n.next
    return root.next
```

[1]: https://leetcode.com/problems/add-two-numbers/