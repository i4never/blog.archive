---
title: RL-CH2 MULTI-ARMED BANDITS
date: 2017-11-07 15:55:00
tags: [Reinforcement Learning, 读书笔记]
categories: 读书笔记
---

## 多臂赌博机(A k-armed Bandit Problem)

一个赌徒，要去摇老虎机，走进赌场一看，一排k个老虎机，外表一模一样，但是每个老虎机吐钱的概率不同，他不知道每个老虎机吐钱的概率分布是什么，每个选择之后都会收到一个数字化的收益。赌徒的任务是在固定的次数，比如说选择100次，每次选择按下哪k个老虎机按钮的情况下，最大化收益。

在k臂赌博机问题中，每个动作（拉下k中的哪几个手柄）都会有一个期望收益。我们把$t$时间的选择的动作记作 $A\_t$ ，相应的收益记作$R\_t$，那么动作$a$的期望受益就可以写作：
$$
q\_*(a)=E[R\_t|A\_t=a]
$$

如果知道了每个动作的期望收益，那么选择期望最大的动作就是我们的策略。

<!--more-->

### Exploiting & Exploring

假设当前我们有了对动作价值（期望收益）的估计，在需要做出决策时我们有两个选择，一是选择价值最大的动作（Exploiting），这相当于墨守成规，根据已有的经验决定；二是选择价值非最大的动作(Exploring)，这是对策略的“探索”，可以避免当前策略陷入局部最优的情况。

## 基于动作的方法(Action-value Methonds)

我们把$t$时刻动作$a$的期望收益记作：
$$
Q\_t(a)=\frac{\sum\_{i=1}^{t-1}R\_i|A\_i=a}{\sum\_{i=1}^{t-1}|A\_i=a}
$$
其实就是t时刻前选择动作$a$的收益之和除以t时刻前选择动作$a$的次数。

### $\varepsilon$-greedy action selection

在基于动作的方法中，$\varepsilon$-greedy是常用的方法。简单的说，就是在每次选择动作时，已$(1-\varepsilon)$的概率选择期望收益最大的动作（即$A\_t={argmax}\_aQ\_t(a)$），以$\varepsilon$的概率随机选择动作。

## The 10-armed Testbed

$\varepsilon$的大小，选择的效果取决于不同的task。比如收益分布有着很大的方差，noisier也很严重，比较大的$\varepsilon$值比较好；反之收益分布的方差接近0，$\varepsilon＝0$，也就是所谓的greedy选择比较好。

## 增量计算(Incremental Implementation)

把$Q\_n(a)$记作动作$a$被选择$n$次之后的动作价值的估计：
$$
Q\_n(a)=\frac{R\_1+R\_2+...+R\_{n-1}}{n-1}
$$
那么:
$$
\begin{align}
Q\_{n+1}(a)&=\frac{1}{n}\sum\_{i=1}^{n}R\_i \\\\
&=\frac{1}{n}(R\_n+\sum\_{i=1}^{n-1}R\_i) \\\\
&=\frac{1}{n}(R\_n+(n-1)\frac{1}{n-1}\sum\_{i-1}^{n-1}R\_i) \\\\
&=Q\_n(a)+\frac{1}{n}[R\_n-Q\_n(a)]
\end{align}
$$
增量计算pseudocode如下：

```pascal
Initialize, for a = 1 to k:
    Q(a) = 0
    N(a) = 0
Repeat:
    A = argmaxQ(a)          with probaility 1-e
        a random action     with probaility e
    R = bandit(A)
    N(A) = N(A)+1
    Q(A) = Q(A)+1/N(A)[R-Q(A)]
```

更新的规则其实是：
$$
NewEstimate = OldEstimate+StepSize[Target-OldEstimate]
$$

## 非平稳问题(Tracking a Nonstationary Problem)

在许多情况下，增强学习处理的问题都是“非平稳”的，放在bandits问题上，就是每台老虎机的Reward分布随时间改变，一段时间赢钱概率高，一段时间输钱概率高。在这种情况下，最近的收益比起历史收益更加有用。对于非平衡问题，一种popular的方法是把常数当作 $StepSize$，n次选择后的动作$a$的收益变成了初始值$Q\_1$和历史收益的加权平均：
$$
\begin{align}
Q\_{n+1}& = Q\_n+\alpha[R\_n-Q\_n] \\\\
&=\alpha R\_n+(1-\alpha)Q\_n \\\\
&=\alpha R\_n+(1-\alpha)[\alpha R\_{n-1}+(1-\alpha)Q\_{n-1}] \\\\
&=(1-\alpha)^nQ\_1+\sum\_{i=1}^{n}\alpha(1-\alpha)^{n-i}R\_i
\end{align}
$$
根据大数定律，$\alpha\_n=\frac{1}{n}$会收敛到收益的真实值，但并不是所有的$StepSize$都会收敛。根据    stochastic approximation theory，只有步长满足以下条件时期望才回收敛：
$$
\sum\_{n=1}^{\infty}\alpha\_n(a)=\infty\\\\
\sum\_{n=1}^{\infty}\alpha\_n^2(a)<\infty
$$
第一个条件保证了大量迭代后消除初值或者收益的波动的影响；第二个条件保证了收敛。

当步长为常数时，显然不满足第二个条件，对收益的估计不会收敛，而是根据近期值不停地改变（这对于非平稳问题是有利的）。**在理论研究中经常选择能够收敛的步长，然而在应用中却不这样。**