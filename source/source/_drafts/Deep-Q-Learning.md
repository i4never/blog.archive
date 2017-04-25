---
title: Deep Q Learning(DQN)
date: 2017-04-24 13:07:20
tags: [Machine Learning]
categories: [Machine Learning]
---

DeepMind开创新的论文《Human-level control through deep reinforcement learning》登上了15年的Nature封面，将传统的增强学习与神经网络结合后，相同架构可以学习如何玩七种不同的Atari游戏。DeepMind被Google收购后，DQN相关技术也被用于AlphaGo的开发。
本文以openAI[开源库gym][1]中的"CartPole-v0"作为example，其中也会穿插其他示例，试图展现Reinforcement Learning的理论基础以及其是如何与NN结合的。
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

Agent的目标是未来能够获得最大的回报。例如"CartPole-v0"中，Agent可以施加的动作只有两个：向左或者向右移动黑色块，Agent可以观察到的环境为块的位置，木棒与块的角度等等，而Reward的定义可以是如果游戏没有结束，Reward为1，否则为-1等等。在DeepMind论文中的模型输入，即Agent的Observation是游戏图像；输出Action为18个动作中的一种，Reward为获得的游戏分数。

{%asset_img atari.png ATARI%}

其中有以下两点需要注意：
 1. Agent希望获得的是“未来”的最大回报，这意味着为了将来能够获得更大的回报，聪明的Agent会牺牲眼前的利益。
 2. 每个Action所带来的回报可能是long-term的。这意味着在$t$时刻采取的动作，可能在很久之后的$t+k$时刻才带来回报。（例如做一个投资决策，可能几个月才能知道投资的回报）

假设我们希望使用一个传统的神经网络去玩这个游戏，我们的想法是这样的：神经网络的输入应该是屏幕的图片，输出则应该是分为两个动作：向左、向右。这可以被看为是一种分类问题，但是显而易见的，这样的监督训练需要数量非常大的样本。而RL则不需要其他人无数次地告知碰到某个画面应该做出怎样的动作，需要的仅仅是做出动作后获得的Reward，就可以自己解决问题。

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
\begin{array}{c|lcr}
& C1 & C2 & C3 & Pass & Pub & FB & Sleep \\\\
\hline
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
简单的Markov Process并没有体现出Agent的作用，Agent所处的状态仅由所处环境随机决定。因此，在MDP模型中加入了Action与Reward的概念，有了这两个概念，Agent能够通过Action某种程度上决定自己所处的下一个状态，并且能够通过Reward评估所处状态的好坏，进而使“学习”变为可能。
MDP定义如下：
MDP定义在五元组($S, P, A, R, \gamma$)上，其中：
 1. $S$是所有状态组成的有限集
 2. $A$是所有动作组成的有限集
 3. $P$是状态概率转移矩阵
 $P\_{ss'}^{a}=P(S\_{t+1}=s'|S\_t=s,A\_t=a)$
 4. $R$是回报函数，
 $R\_{s}^{a}＝E[R\_{t+1}|S\_t=s,A\_t=a]$
 5. $\gamma$是回报衰减因子，$\gamma\in[0,1]$

在这个定义下，Agent所处的状态是由环境与自己共同决定的。比如明天有1％的概率会下雨，但是采取了人工降雨，从而明天下雨的概率达到了90%，转移到“下雨”这个状态的概率是由环境和Action共同决定的。
首先我们定义在MDP下的episode，用$a,r$分别表示Action与Reward，Agent与Environment的交互可以用这样一个有限状态序列表示：

$$
s\_0,a\_0,r\_1,s\_1,a\_1,r\_2...s\_{n-1},a\_{n-1},r\_n,s\_n
$$
其中$s\_i$表示i时刻状态，$a\_i$表示i时刻Agent采取的动作，$r\_{i+1}$表示执行了动作后立即获得回报。这个序列最终以$s\_n$结束，例如游戏中出现Gameover或者Win。

### Policy
MDP中的关键之一是Agent的Policy，Policy体现了Agent为了获得更大的回报而做出的动作。Policy定义为Agent的action与state的条件分布，也就是在某个state s下，agent做出某个action a的可能（例如state是离上班还有30分钟，90%的可能选择打车，90%的概率不会迟到，10%的可能选择坐地铁，10%的概率不会迟到）：

$$
\pi(a|s)=P(A\_t=a|S\_t=s)
$$
在MDP中，Agent的策略仅仅依靠当前状态，而与当前状态之前的历史状态无关。

### Discounted Reward
我们把Episode中的reward都挑出来，每一步action后的回报组成了这样一个序列：

$$
r\_1,r\_2...r\_n
$$
对于一个episode，可以计算出整个过程中获得的Reward：$\sum\_{i=1}^{n} r\_i$；其中的某一时刻$t$之后的Reward为$\sum\_{i=t+1}^{n} r\_i$。加上衰减系数，$t$时刻起获得的total discounted reward定义为：

$$
G\_t=r\_{t+1}+{\gamma}r\_{t+2}+{\gamma}^2 r\_{t+3}...=\sum\_{k=0}^n {\gamma}^k r\_{t+k+1}
$$
这个公式的观点是在$t$时刻作出的动作，经过的时间越长，因为这个动作带来的回报就越小。如果$\gamma=0$，那么这个Agent比较目光短浅，相反如果$\gamma=1$，那么这个Agent太“深谋远虑”，在大部分情况下这两种情况都不是一个好的选择。
根据UCL David Silver[课程][2]中所述，加入衰减系数$\gamma$是由于以下几个原因：
 1. 数学上更加方便计算。（？？？）
 2. 如果一个episode中存在无限循环的话（C1 C2 C3 C1 C2 C3...），可以避免出现无限大的reward。
 3. 环境是随机的，即时在同一个state下做了与上次一样的action，带来的回报是不同的。
 4. 在某些情况下，我们更关注动作带来的近期回报。（例如短期投资）
 5. 如果所有episode都是有限的，有时候也会使$\gamma＝1$。

回到[Markov Process](#Markov-Process)这一节中提到的状态图和序列，如果每个状态的reward如下：
{%asset_img markov_reward.png Markov state with Reward%}
如果衰减系数为0.5，那么这样计算：
$$
\begin{array}{c|c}
Episode & Discounted Reward\\\\
\hline
C1 C2 C3 Pass Sleep & -2-\frac{1}{2}\*2-\frac{1}{4}\*2+\frac{1}{8}\*10=-2.25\\\\
C1FBFBC1C2Sleep & -2-\frac{1}{2}\*1-\frac{1}{4}\*1-\frac{1}{8}\*2-\frac{1}{16}\*2=-3.125\\\\
\end{array}
$$

### State Value(Bellman (Optimality) Equation)
有了$G\_t$还不够，$G\_t$只能评估某个episode中某一时刻的action带来的收益，我们希望能够评估某个状态的价值，这样Agent就可以通过action主动向高价值状态转移。State Value定义为Agent处于某个state s下，遵循某个policy所获得的未来回报的期望：
$$
v\_{\pi}(s)=E\_{\pi}[G\_t|S\_t=s]
$$

这个公式可以做如下展开：
$$
\begin{align}
v\_{\pi}(s) & =E\_{\pi}[G\_t|S\_t=s] \\\\
& = E\_{\pi}[r\_{t+1}+{\gamma}r\_{t+2}+{\gamma}^2 r\_{t+3}...|S\_t=s]\\\\
& = E\_{\pi}[r\_{t+1}+{\gamma}(r\_{t+2}+{\gamma} r\_{t+3}...)|S\_t=s]\\\\
& = E\_{\pi}[r\_{t+1}+{\gamma}G\_{t+1}))|S\_t=s]\\\\
& = E\_{\pi}[r\_{t+1}+{\gamma}v\_{\pi}(s\_{t+1}))|S\_t=s]\\\\
\end{align}
$$
也就是：
$$
v\_{\pi}(s) = R\_s+{\gamma}\sum\_{s' \in S} P\_{ss'}v(s')
$$
这意味着，状态价值是由两部分组成的，一部分是immediate reward，另一部分是未来的discounted reward。这就是Bellman方程，这个方程使状态价值的迭代计算成为可能。相似地，我们可以定义最优Bellman方程（Bellman Optimality Equation）：
$$
v\_{\*\pi}(s) = {max}\_a(R\_s+{\gamma}\sum\_{s' \in S} P\_{ss'}v\_{\*\pi}(s'))
$$

### Action Value
与State Value相似，我们也可以根据Agent的Policy定义它Action Value。通过Action Value，我们希望可以评估在某个状态下，采取哪个action获得的期望收益最高。优化State Value与Action Value是Reinforcemnt Learning的两个主要思路，也就是所谓的值优化与策略优化。
Action Value定义为处于某个state s下，根据某个policy选择动作a所能获得的未来回报的期望：
$$
q\_{\pi}(s,a)=E\_{\pi}[G\_t|S\_t=s, A\_t=a]
$$
参考Bellman方程，Action Value也能被分解成相似形式，从而进行迭代计算：
$$
q\_{\pi}(s,a)=E\_{\pi}[r\_{t+1}+{\gamma}q\_{\pi}(s\_{t+1}, a\_{t+1})|S\_t=s, A\_t=a]
$$
相似地可以定义最优action value：
$$
q\_{\pi}(s,a)=max(E\_{\pi}[r\_{t+1}+{\gamma}q\_{\pi}(s\_{t+1}, a\_{t+1})|S\_t=s, A\_t=a])
$$

## Theorem
对于MDP，有这样的理论：
 1. 存在一个最优策略$\pi$，这个策略不差于其他任何策略。
 2. 遵循最优策略，计算出的state value是最优的。
 3. 遵循最优策略，计算出的action value是最优的。

Agent的目的就是找到这个最优策略。

# Learning Algorithm
有了上面这些理论基础，下面就需要讨论实现Agent学习的算法。RL问题中，Agent的目标是未来能够获得最大的收益。基于上述State Value与Action Value的定义，分别有Policy Iteration与Value Iteration等等的算法。这里先简述这两种算法及其缺陷进而引出Q-Learning与神经网络。

## Policy Iteration
Policy Iteration是基于Bellman方程的：
$$
\begin{align}
v\_{\pi}(s) &= R\_s+{\gamma}\sum\_{s' \in S} P\_{ss'}v(s')\\\\
&=\sum\_{a}\pi(a|s)\sum\_{s',r}p(s',r|s,a)[r+\gamma v\_k(s')]
\end{align}
$$
Policy Iteration分为两步：
 1. Policy Evaluation，目的是根据当前策略，计算一个episode的Value，也就是基于当前策略的价值
 2. Policy Improvement，使用根据第一步中计算出的Value，更新策略，每次都选择Value更大方向来更新。

{%asset_img policy_alg.png Policy Iteration%}

## Value Iteration
Value Iteration是基于最优Bellman方程的：
$$
\begin{align}
v\_{\*\pi}(s) &= {max}\_a(R\_s+{\gamma}\sum\_{s' \in S} P\_{ss'}v\_{\*\pi}(s')) \\\\
&={max}\_a \sum\_{s',r}p(s',r|s,a)[r+\gamma v\_{\*}(s')]
\end{align}
$$
算法如下：
{%asset_img value_iteration.png Value Iteration%}

上述两个算法明显的缺陷是需要对问题有充分的了解，也就是要知道状态转移矩阵$p$，在许多问题中这是不现实的。此外，虽然这两个算法的收敛性都得到了证明，但是时间复杂度高，需要施加许多优化才能解决收敛速度慢的问题。为此，有了蒙特卡洛方法，TD方法，Q-Learning等等的改进。这里着重关注Q-Learning。

## Q-Learning
Q-Learning的想法是源于Value Iteration的








[1]: https://github.com/openai/gym
[2]: http://www0.cs.ucl.ac.uk/staff/D.Silver/web/Teaching_files/MDP.pdf
