---
title: Deep Q Learning(DQN)
date: 2017-04-24 13:07:20
tags: [Machine Learning]
categories: [Machine Learning]
---

DeepMind开创新的论文《Human-level control through deep reinforcement learning》登上了15年的Nature封面，将传统的增强学习与神经网络结合后，相同架构可以学习如何玩七种不同的Atari游戏。DeepMind被Google收购后，该技术也被用于AlphaGo的开发。
本文以openAI[开源库gym][1]中的"CartPole-v0"作为贯穿全文的example，其中也会穿插其他问题，试图展现Reinforcement Learning的理论基础以及其是如何与NN结合的。
"CartPole-v0"是一个小游戏，需要通过向左或者向右移动黑色块，使与块连接的棒处于平衡状态。
{%asset_img cartpole_v0.png CartPole-v0%}

<!--more-->

# Reinforcement Learning
## Model
增强学习是基于以下的模型：
{%asset_img rl_model.png Model%}
一个Agent不断地与其所处的Environment交互，交互过程如下：
Agent:
 1. 执行一个Action（根据某种Policy）
 2. 观察环境状态变化（Observation）
 3. 因为执行Action而获得不同的Reward

Environment:
 1. 接受动作Action
 2. 因为接受Action而发生变化
 3. 反馈Reward

Agent的目标是未来能够获得最大的回报。例如"CartPole-v0"中，Agent可以施加的动作只有两个：向左或者向右移动黑色块，Agent可以观察到的环境为块的位置，木棒与块的角度等等，而Reward的定义可以是如果游戏没有结束，Reward为1，否则为-1等等。在DeepMind论文中的模型输入，即Agent的Observation是游戏图像；输出，即Action为18个动作中的一种，Reward为获得的游戏分数。

{%asset_img atari.png ATARI%}

其中有以下两点需要注意：
 1. Agent希望获得的是“未来”的最大回报，这意味着为了将来能够获得更大的回报，Agent会牺牲眼前的利益。
 2. 每个Action所带来的回报可能是long-term的。这意味着在$t$时刻采取的动作，可能在很久之后的$t+k$时刻才带来回报。（例如做一个投资决策，可能几个月才能知道投资的回报）

假设我们希望使用一个传统的神经网络去玩这个游戏，那么神经网络的输入应该是屏幕的图片，输出则应该是分为两个动作：向左、向右。这可以被看为是一种分类问题，我们需要对每一个游戏画面做出决定，是该往左移，还是往右。但是显而易见的，这样的监督训练需要数量非常大的样本。而增强学习不需要其他人无数次地告知碰到某个画面应该选择怎样的动作，需要的仅仅是做出动作后获得的反馈，就可以自己解决问题。

# Markov Model
有了这样一个模型后，我们需要把模型公式化，才能进一步定义模型的学习方法。增强学习是基于Markov模型的。
## Markov Process
用$S_t$来表示$t$时刻的状态，如果一系列的状态满足：

$$
P(s\_{t+1}|s\_t)=P(s\_{t+1}|s\_t, s\_{t-1}...s\_1)
$$
换句话说
{% centerquote %}
The future is independent of the past given the present
{% endcenterquote %}
也就是如果下一时刻的状态仅与当前时刻的状态有关，与之前的历史状态无关，那么这就是一个Markov过程。
用规范的语言描述：

Markov Process定义在二元组($S, P$)上，其中：
 1. $S$是所有状态组成的有限集
 2. $P$是状态概率转移矩阵

概率转移矩阵$P$（transition probability matrix），其中$P\_{ss'}=P(S\_{t+1}=s'|S\_t=s)$。矩阵的每个元素代表了由状态$s$转移至$s'$的概率。
{%asset_img markov_state.png Markov State%}

$$
P=
\begin{array}{c lcr}
& C1 & C2 & C3 & Pass & Pub & FB & Sleep \\\\
C1 &  & 0.5 & & & & 0.5 &  \\\\
C2 &  &  & 0.8 & & &  & 0.2 \\\\
C3 &  &  &  & 0.6  & 0.4 & & \\\\
Pass & & &  & & & & 1.0 \\\\
Pub & 0.2 & 0.4 & 0.4 & & & & \\\\
FB & 0.1 &  &  & & & 0.9 & \\\\
Sleep & &  &  & & &  & 1.0\\\\
\end{array}
$$
上图就是一个Markov状态的迁移图以及转移矩阵。
一个状态序列：

$$
S\_1,S\_2...S\_t
$$
被称作是一个episode，以下是几个初始状态为C1的episode：
- C1 C2 C3 Pass Sleep
- C1 FB FB C1 C2 Sleep
- C1 C2 C3 Pub C2 C3 Pass Sleep
- C1 FB FB C1 C2 C3 Pub C1 FB FB FB C1 C2 C3 Pub C2 Sleep

## Markov Decision Process
简单的Markov Process并没有体现出Agent的作用，Agent所处的状态仅由状态转移矩阵决定。因此，我们在模型中加入Action与Reward的概念，使Agent能够通过Action某种程度上决定自己所处的下一个状态，并且能够通过Reward评估所处状态的好坏。
MDP定义如下：
MDP定义在五元组($S, P, A, R, \gamma$)上，其中：
 1. $S$是所有状态组成的有限集
 2. $A$是所有动作组成的有限集
 3. $P$是状态概率转移矩阵
 $P\_{ss'}^{a}=P(S\_{t+1}=s'|S\_t=s,A\_t=a)$
 4. $R$是回报函数，
 $R\_{s}^{a}＝E[R\_{t+1}|S\_t=s,A\_t=a]$
 5. $\gamma$是回报衰减因子，$\gamma\in[0,1]$

在这个定义下，Agent所处的状态是由环境与自己共同决定的。比如明天有1％的概率会下雨，但是采取了人工降雨，从而明天下雨的概率达到了90%，转移到“下雨”这个状态的概率是由环境和Action共同决定的。值得考虑的是其中Reward函数与衰减因子。
首先我们定义在MDP下的episode，用$a,r$分别表示Action与Reward，Agent与Environment的交互可以用这样一个有限状态序列表示：

$$
s\_0,a\_0,r\_1,s\_1,a\_1,r\_2...s\_{n-1},a\_{n-1},r\_n,s\_n
$$
其中$s\_i$表示i时刻状态，$a\_i$表示i时刻Agent采取的动作，$r\_{i+1}$表示执行了动作后立即获得回报。这个序列最终以$s\_n$结束，例如游戏中出现Gameover或者Win。
我们把其中的reward都挑出来，每一步action后的回报组成了这样一个序列：

$$
r\_1,r\_2...r\_n
$$
在$t$时刻，




[1]: https://github.com/openai/gym
