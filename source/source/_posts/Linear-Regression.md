---
title: 不同角度的线性回归
categories: Machine Learning
date: 2018-09-10 13:59:39
tags: [Machine Learning, Deep Learning]
---

实习半年多，深感理论不扎实对于写模型的影响，不少算法看起来大同小异，实则完全基于不同的理论基础。借着写论文的这段时间，希望能从头整理Deep Learning的各种理论。

<!--more-->

# Linear Regression

线性回归是最简单的机器学习算法，其的一般形式为：
$$y=w^Tx$$ 
根据输入$x$估计输出$y$ 。线性回归使用均方误差：$$MSE=1/m\sum\_{i=1}^m(\hat y-y)^2=1/m\sum\_{i=1}^m(w^Tx\_i-y\_i)$$
做为准则函数。通过最小二乘法最小化均方误差以得到参数$w$。通过求解正规方程$w=(X^{(train)T}X^{(train)})^{-1}X^{(train)T}y^{(train)}$可以直接求得参数。
# LR与最大似然
对于最小化均坊误差的做法，实际上是去拟合了训练数据。LR过程也可以看做最大似然过程。
考虑独立同分布的样本数据集$X={x^1,x^2,...,.x^m}$，其是由未知的真实分布$p\_{data}(x)$生成的。同时，令$p\_{model;\theta}$是一族由$\theta$确定的同空间上的概率分布。对参数$\theta$的最大似然估计为：
$$\theta=argmax\_{\theta}p\_{model}(x;\theta)=argmax\_{\theta}\prod\_{i=1}^m p\_{model}(x^i;\theta)$$
也就是试图确定参数$\theta$，使样本服从$p\_{model}$分布时，观测到的数据集出现的概率最高。似然函数转积为和后：
$$\theta=argmax\_{\theta}\sum\_{i=1}^m log(p\_{model}(x^i;\theta))=argmax\_{\theta}E\_{x\~p\_{data}}log (p\_{model}(x;\theta))$$
计算中常取log也是为了防止计算数值的下溢。
值得一提的是，真实分布与模型分布之间KL散度为：
$$D\_{KL}(p\_{data}||p\_{model})=E\_{x\~p\_{data}}[log(p\_{data}(x))-log(p\_{model}(x))]$$
第一项为数据的真实分布，与模型无关，最大化似然函数其实也是在最小化KL散度。
对于线性回归，假设$p(y|x)=N(y;\hat y(x;w),\sigma^2)$（真态分布），似然函数为：
$$L=\sum\_{i=1}^m log(p(y^i|x^i;\theta))=-mlog\sigma-m/2log(2\pi)-\sum\_{i-1}^m||\hat y^i-y^i||^2/(2\sigma^2)$$
在上述假设下，最大化似然估计与最小化均坊误差会得到相同的值。
























