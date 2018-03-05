---
title: 不同的RL方法
date: 2018-02-20 13:55:46
tags: [Reinforcement Learning, Machine Learning]
categories: Machine Learning
---

此blog持续更新，主要记录不同RL算法的主要特点，对于算法的描述并不完全。

# 1. Q-Learning & SARSA
Q-Learning以及SARSA是RL最基本的方法，不同之处在于Q-Learning在更新是使用最优值；而SARSA则根据自己现有的策略来计算更新用的Q值。这就导致了SARSA比较看重已有的经验，比起QL更加保守，因此容易陷入类似于“局部最优”的情况。而QL始终根据maxQ来更新Q值，比起SARSA更加“贪婪”。
{%asset_img ql_sarsa.png Q-Learning & SARSA (From 莫烦python)%}

<!--more-->

# 2. SARSA($\lambda$)
和普通的SARSA相比，SARSA($\lambda$)的更新有一个“回溯”的过程。比如在拿过程$s\_t,a\_t,r\_t,s\_{t+1},a\_{t+1},r\_{t+1},s\_{t+2},a\_{t+2},r\_{t+2}$来说（这也是得名sarsa的原因），对于t这一步的更新，SARSA值考虑t+1时刻的action和reward，而SARSA($\lambda$)考虑了t时刻之后，直到这个eposide终止的所有reward。也就是说，比如t时刻获得了一个比较大的reward，那么这个reward会被$\lambda$指数衰减后用于更新t-1($\lambda^0$),t-2($\lambda^1$)....直到0时刻的Q值，也就是离好／坏结果更近的步骤能够更快地学习到Q值。当$\lambda$为0时，即为普通的SARSA。算法中，这个“回溯”体现在E(s,a)这个表格当中，一开始非常不理解为什么E(s,a)更新时除了$\lambda$衰减，还要乘以reward衰减$\gamma$，仔细考虑后，其实$\gamma$是markov理论中的收益衰减，本来t时刻的reward对于t-n时刻的影响为$\gamma^{n}r\_t$，而$\lambda$描述的是这个reward对于t-n时刻的重要性。$\gamma$的意义和其他算法中一样，是学习过程中agent“向前看”的范围，而$\lambda$是学习过程中的回溯，是“向后看”的程度。
{%asset_img sarsa_lambda.png SARSA($\lambda$)(From 莫烦python)%}

# 3. DQN
DQN，其实是使用网络来拟合Q-Learning中的表格Q(s,a)，由于使用网络，泛化能力更强，也弥补了基于table的方法，难以处理未出现的state或action的缺陷。关于DQN，训练过程在
{% post_link Deep-Q-Learning 过去的blog%}中有介绍，这篇blog是刚接触rl时候写的，除了dqn，还有一些markov process等内容。

# Reference
[https://morvanzhou.github.io/tutorials/machine-learning/reinforcement-learning/][1]


[1]: https://morvanzhou.github.io/tutorials/machine-learning/reinforcement-learning/