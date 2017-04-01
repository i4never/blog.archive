---
title: LeetCode1 Two Sum
categories: LeetCode
tags: [LeetCode, Hash, Python, C, Java]
date: 2016-12-10 22:16:50
---

LeetCode第一题。

[Question link][1]

# Description
Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution.

<!--more-->

## Example
```
Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].
```

# Solution
## First try
第一次尝试，没有任何算法，穷举，复杂度$O({n^2})$效果比较差：
``` c
/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* twoSum(int* nums, int numsSize, int target) {
    int *result;
    result = (int*) malloc(sizeof(int)*2);
    for (int i = 0 ; i < numsSize-1 ; i++)
        for (int j = i+1 ; j < numsSize ; j++)
            if (nums[i] + nums[j] == target)
            {
                result[0] = i;
                result[1] = j;
                return result;
            }
    return result;
}
```
{% asset_img runtime1.png Time used for solution1 %}

同样的代码，第二次跑的结果，虽然快了点，但是并没有什么实质性改变：
{% asset_img runtime2.png Time used for solution1 %}

几毫秒的差别，在200ms以上的应该基本都是这种穷举算法。
细想的话，其实这是一个查找问题，只不过每次要找的数字是在数组中寻找目标与当前数字的差，自然而然Hash是想到的方法。

## HashTable
Hash表不多提了，这里有个小例子，散列函数为模12的结果（12同时也为表长，但是用一个合数来构造哈希表是不合适的，理论表明使用素数能降低conflict的概率）。
{% asset_img hashtable.png An example for hash table %}

算法主要如下：

 1. 根据素数P构造长度为P的HashTable
 2. 遍历数组，取出下一个元素，在HashTable中寻找元素``target-nums[i]``。
 3. 如果找到，释放HashTable，返回；如果未找到，将元素加入HashTable中，散列函数为``nums[i]%p``，转2。

一直觉得LeetCode的OJ不怎么人性化，debug起来比较难，于是本地写了一个模拟的测试环境。

``` c
#include <stdio.h>
#include <stdlib.h>

/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
 
#define P 109
 
struct HashNode{
    int index;
    struct HashNode * next;
};

void show_HashTable(struct HashNode * HT)
{
    for (int i = 0 ; i < P ; i++)
    {
        printf("%d ",HT[i].index);
    }
}

struct HashNode * init_HashTable(struct HashNode* HT)
{
    HT = (struct HashNode*)malloc(P*sizeof(struct HashNode));
    for (int i = 0 ; i < P ; i++)
    {
        HT[i].index = -1;
        HT[i].next = NULL;
    }
    return HT;
}

void free_HashTable(struct HashNode* HT)
{
    struct HashNode* temp1;
    for (int i = 0 ; i < P ; i++)
    {
        temp1 = HT[i].next;
        while (temp1 != NULL)
        {
            struct HashNode* temp2 = temp1->next;
            free(temp1);
            temp1 = temp2;
        }
    }
    free(HT);
}

int * twoSum(int* nums, int numsSize, int target) {
    int *result;
    result = (int*) malloc(sizeof(int)*2);
    
    struct HashNode* HT;
    HT = init_HashTable(HT);
    // show_HashTable(HT);
    
    for (int i = 0 ; i < numsSize ; i++)
    {
        // printf("iteration %d\n",i);
        struct HashNode * temp;
        temp = &HT[nums[i]%P];
        while(temp && temp->index != -1)
        {
            if (nums[temp->index] + nums[i] == target)
            {
                // find the match one
                result[0] = temp->index;
                result[1] = i;
                // show_HashTable(HT);
                // printf("%d %d", result[0],result[1]);
                free_HashTable(HT);
                return result;
            }
            temp = temp->next;
        }
        // no element matchs, add number to HT, key = remains mod P
        int key = (target-nums[i])%P;
        if (HT[key].index == -1)
        {
            //doesn't conflict
            HT[key].index = i;
        }
        else
        {
            //conflict, add in the head of chain
            temp = (struct HashNode*)malloc(sizeof(struct HashNode));
            temp->index = i;
            temp->next = HT[key].next;
            HT[key].next = temp;
        }
    }
    free_HashTable(HT);
    return result;
}

int main()
{
    int numbers[] = {3,-3,4};
    int target = 0;

    int *index = twoSum(numbers, sizeof(numbers) / sizeof(numbers[0]), target);

    for (int i = 0; i < 2; i++){
        printf("index%d = %d ", i + 1, index[i]);
    }
    printf("\n");

    return 0;
}
```
这份代码在本地上跑所有的test都没有问题，但是自信Submit的结果却是Runtime error。疑惑了很久，search之后发现Runtime error 99%都是因为内存越界或者访问空指针了。于是回头找代码中的bug，有兴趣的可以先不看下面，自己找一找。fix的过程如下：

 1. free的时候比较可能出错。注释掉free后仍然Runtime error。
 2. ``while(temp && temp->index != -1)``写下这一行的时候心里也是相当忐忑的。这个访问的合法性是因为编译器的优化，如果``temp``指针为空，与操作的第一个条件为False的话，是会略过计算第二个条件的。尝试把第二个条件加入循环体中判断，仍然Runtime error。
 3. 最后终于找到了症结。观察到所有Runtime error的结果无一例外都包含了负数。查找和加入HashTable时如果用的key是负数没有做任何处理，自然而然就越界了。本地的代码不知道为什么没有提示这个错误－ －。
于是循环体内稍微改了两行：
一个是查找的时候``int key = nums[i]%P;key = key < 0 ? key+P : key;temp = &HT[key];``
另一个是加入元素的时候：``key = (target-nums[i])%P;key = key < 0 ? key+P : key;``
简单来说就是如果模的结果是负数，就加上HashTable的长度。

最后完美解决，运行结果如下：
{% asset_img runtime3.png Time used for solution2 %}

6ms，和原来不在一个量级上。

# Discussion

首先是个[C solution][2]，先把所有元素放倒HashTable里，再去一个个找，总共遍历两边数组，花了9ms。

Discussion里有个高票的[Python solution][3]，区区几行：
``` python
class Solution(object):
    def twoSum(self, nums, target):
        if len(nums) <= 1:
            return False
        buff_dict = {}
        for i in range(len(nums)):
            if nums[i] in buff_dict:
                return [buff_dict[nums[i]], i+1]
            else:
                buff_dict[target - nums[i]] = i+1
```
基本思路和我的算法一样。

# Java
初学Java，以后所有题都用Java给出解法。
## Java Solution
```java
public class Solution {
    public int[] twoSum(int[] nums, int target) {
        int[] result = new int[2];
        int remains;
        HashMap<Integer, Integer> HM = new HashMap<Integer, Integer>();
        for (int i = 0 ; i<nums.length ; i++)
        {
            remains = target-nums[i];
            if (HM.containsKey(remains))
            {
                result[0] = HM.get(remains);
                result[1] = i;
                break;
            }
            HM.put(nums[i],i);
        }
        return result;
    }
}
```

## Java.util.HashMap
``HashMap``类是Java中实现Hash的类之一，其他的还有``HashTable``等。[doc][4]中提到，需要注意该类不保证数据的存储顺序，并且由capacity(default:16)与loadfactor(default:0.75)决定表长与填充程度。在构造时可以指定capacity与loadfactor参数。可以想象，如果loadfactor较小，conflict的概率小，但是浪费了大量空间；反之conflict概率大，但是节约了空间。如果对性能有要求，不应该把初始capacity设的太高，最好考虑到实际大小。如果capacity*loadfactor大于使用到的bucket，那么不会有rehash过程。此外，``HashMap``不是线程安全的。

## How to hash
有趣的是计算Hash值的方法。在自己写的C Solution中，散列方法是除以一个素数，但是除法是一个非常耗费时间的操作，``HashMap``使用如下方法巧妙地避开了除法。
### Java7 and before
java7以及之前的hash是这样计算的：
```java
 static int hash(int h) {
         // This function ensures that hashCodes that differ only by
         // constant multiples at each bit position have a bounded
         // number of collisions (approximately 8 at default load factor).
         h ^= (h >>> 20) ^ (h >>> 12);
         return h ^ (h >>> 7) ^ (h >>> 4);
     }

  bucketIndex = indexFor(hash, table.length);

  static int indexFor(int h, int length) {  
       return h & (length-1);  
   }  
```

### Java8
java8源码中``put``函数以及其调用的相关函数：
```java
public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }

static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }

final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }

```
``hashCode()``是key抽象类的抽象方法，不同数据类型有不同的求取方法，例如Integer与String的计算方法如下：
```java
//Integer
/**
     * Returns a hash code for this {@code Integer}.
     *
     * @return  a hash code value for this object, equal to the
     *          primitive {@code int} value represented by this
     *          {@code Integer} object.
     */
    @Override
    public int hashCode() {
        return Integer.hashCode(value);
    }

    /**
     * Returns a hash code for a {@code int} value; compatible with
     * {@code Integer.hashCode()}.
     *
     * @param value the value to hash
     * @since 1.8
     *
     * @return a hash code value for a {@code int} value.
     */
    public static int hashCode(int value) {
        return value;
    }
/************/
/***String***/
/************/
/**
     * Returns a hash code for this string. The hash code for a
     * {@code String} object is computed as
     * <blockquote><pre>
     * s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
     * </pre></blockquote>
     * using {@code int} arithmetic, where {@code s[i]} is the
     * <i>i</i>th character of the string, {@code n} is the length of
     * the string, and {@code ^} indicates exponentiation.
     * (The hash value of the empty string is zero.)
     *
     * @return  a hash code value for this object.
     */
    public int hashCode() {
        int h = hash;
        if (h == 0 && value.length > 0) {
            char val[] = value;

            for (int i = 0; i < value.length; i++) {
                h = 31 * h + val[i];
            }
            hash = h;
        }
        return h;
    }
```

### Why
总的来说，这段代码实现了对hash值的“扰动”。java8中做了相对的简化，只进行一次向右16位移位，然后与原hash值做异或。HashMap使用时有几点需要注意的，其原因与Hash原理息息相关：
1. Hash表长度始终是2的次方，如果不指定，初始大小为16，否则若指定表长是$l$，则实际表长是$2^n,(2^{n-1}<l<=2^n)$。可以看到求数组索引的时候（java7:``h & (length-1);``，java8:``tab[i = (n - 1) & hash]``）都是与（数组长度－1）做与操作。由于``length``是2的次方，``length-1``是一个低位掩码（每一位都是1），那么与操作的结果每一位上都可能出现0和1。如果不是这样一个全1的掩码，那么掩码某些位置上会出现0，相应的bucket也就永远不会被使用到（即使引入了“扰动”，随机性也大大降低）。
2. 关于移位（java7:``h ^= (h >>> 20) ^ (h >>> 12);return h ^ (h >>> 7) ^ (h >>> 4);``，java8:``(h = key.hashCode()) ^ (h >>> 16)``）这个是所谓的“扰动”，混合了原始hash值的高低位，目的是增加随机性。java8中做了简化，认为将原值右移16位后再与原值做与操作，增加的随机性就足以减少碰撞次数。文章[《An introduction to optimising a hashing strategy》][5]通过hash352个string，对比了使用扰动与否对于碰撞次数的影响，结果表明增加扰动后，碰撞概率减少了10%左右。以下图为例(出自[JDK 源码中 HashMap 的 hash 方法原理是什么？][6])，可以直观java8的散列过程。
{% asset_img hashmap1.png Example %}


以上就是LeetCode第一题的解法与java hashmap的一些内容。

# Reference
[LeetCode Question1][1]
[Discussion(C)][2]
[Discussion(Python)][3]
[JavaDoc][4]
[An introduction to optimising a hashing strategy][5]
[JDK 源码中 HashMap 的 hash 方法原理是什么？][6]
[How does a HashMap work in JAVA][7]

  [1]: https://leetcode.com/problems/two-sum/
  [2]: https://discuss.leetcode.com/topic/69606/c-9ms-solution
  [3]: https://discuss.leetcode.com/topic/23004/here-is-a-python-solution-in-o-n-time
  [4]: http://docs.oracle.com/javase/8/docs/api/
  [5]: https://www.todaysoftmag.com/article/1663/an-introduction-to-optimising-a-hashing-strategy
  [6]: https://www.zhihu.com/question/20733617
  [7]: http://coding-geek.com/how-does-a-hashmap-work-in-java/

