---
title: 读书笔记：RL-CH4 Dynamic Programming
tags: [Reinforcement Learning, 读书笔记, Dynamic Programming]
categories: 读书笔记
---

[The book is here][1]

Chapter3的主要内容是Markov Decision Process，在之前的{% post_link Deep-Q-Learning post%}中有涉及，先略过。

在RL中，DP可以看做是所有算法的基础，但是由于DP计算量比较大，对模型的限制也比较多，其他的算法的努力基本在于减少计算量和**去除对模型的某些限制。**

DP需要假设Environment是一个确定的MDP过程。过程由$S,A,R$定义，分别表示State，Action，Reward集合。并且转移概率$p(s^\prime,r|s,a) ,$for all$ s\in S, a\in A(s),r\in R$。

### Bellman optimality equations

$$
\begin{align}
v_*(s)&=max_aE[R_{t+1}+\gamma v_*(S_{t+1})|S_t=s, A_t=a] \\
&=max_a\sum_{s\prime, r}p(s\prime,r|s,a)[r+\gamma v_*(s\prime)] \\
q_*(s,a)&=E[R_{t+1}+\gamma max_{a\prime}q_*(S_{t+1}, a\prime)|S_t=s,A_t=a] \\
&=\sum_{s\prime, r}p(s\prime,r|s,a)[r+\gamma max_{a\prime}q_*(s\prime,a\prime)]
\end{align}
$$

 ## 4.1策略估计(Policy Evaluation)

策略估计是估计一个策略优劣的方法。在RL中策略被定义为概率分布，用$\pi$表示，$\pi(a|s)$用来表示处于状态$s$时采取动作$a$的概率。策略估计就是在已知策略$\pi$的情况下，估计state-value：$v_{\pi}(s)$的方法。MDP中state-value的定义如下：
$$
\begin{align}
v_{\pi}(s)&=E_{\pi}[G_t|S_t=s] \\
&=E_{\pi}[R_{t+1}+\gamma G_{t+1}|S_t=s] \\
&=E_{\pi}[R_{t+1}+\gamma v_{\pi}(S_{t+1})|S_t=s] \\
&=\sum_a\pi(a|s)\sum_{s\prime,r}p(s\prime, r|s,a)[r+\gamma v_{\pi}(s\prime)]
\end{align}
$$




[1]: https://github.com/i4never/i4never.github.io/blob/master/appendix/reinforcement_learning_an_introduction.pdf