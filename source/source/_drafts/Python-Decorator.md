---
title: Python Decorator
date: 2017-05-22 14:36:42
tags: [Python]
---

最近帮朋友用flask写了个小网页。与Django一样，flask的模版引擎也是[Jinja2][1]但是相比于Django，感觉flask更加轻量，更加灵活。flask在每个页面对应的函数前加上一个router装饰符来为这个url注册函数。依稀记得Django的每个页面都需要在一个url文件里注册函数，当初写的时候一改url就需要不停的在该文件与函数文件里切来切去，很是不方便。

<!--more-->

# Flask中的``@app.route('url')``
```python
@app.route('/home')
def home():
    return render_template('home.html')
```
这是一个页面最简单的注册与渲染方法。函数home中渲染了``home.html``这个页面，而``@app.route('/home')``为url``server:port/home``注册了``home()``函数。于是监听到有对该url的访问时，就会调用相应的函数做处理。

# 什么是Decorator
Decorator本质上是一个函数，接受装饰的函数做为参数，可以扩展被装饰函数的处理能力。比如说，有这个求和函数：
```python
def sum(a,b):
    return a+b

def sum3(a,b,c) 
    return a+b+c
```
如果希望执行函数的时候输出日志，可以这样做：
```python
def sum(a,b):
    print("call %s, input %d, %d" % (f.__name__, a, b))
    return a+b

def sum3(a,b,c):
    print("call %s, input %d, %d, %d" % (f.__name__, a, b, c))
    return a+b+c
```
如果所有的函数都需要加log，每个函数前都来这么一行太繁琐，用decorator就可以解决这个问题。比如我们构造如下这个装饰符：
```python
def log_decorator(f):
    def cant_be_seen(a,b):
        print("Call %s, input: %d %d" % (f.__name__, a, b))
        return f(a,b)
    return cant_be_seen

```
用这个装饰符修饰``sum``函数，运行后会有这个结果：
```python
@log_decorator
def sum(a,b):
    return a+b

sum(2,3)

# Output:
# Call sum, input: 2 3
# 5
```
这就完成了输出log的功能。
decorator其实封装了原来的函数，不加装饰符，``sum.__name__``是``sum``，加了之后会变成``cant_be_seen``，调用的其实是封装后的函数。这就带来这样一个问题，封装的函数``cant_be_seen``接受的参数个数要与原函数一致，如果用上面这个decorator修饰``sum3``，会有这样的问题：
```python
@log_decorator
def sum3(a,b,c) 
    return a+b+c

sum3(1,2,3)

# Output:
# TypeError
# Traceback (most recent call last)
# <ipython-input-37-72eb16989985> in <module>()
# ----> 1 sum3(1,2,3)

# TypeError: cant_be_seen() takes 2 positional arguments but 3 were given
```
需要有一个不受参数个数影响的方法。
# \*args \*\*kwargs
为了解决这个问题，可以使用python中的不定参数。这两个不定参数乍看像是C中的一二级指针，实则不然，其中\*为tuples，\*\*为dict。这里不细究不定参数的问题，有疑问的看看这个[例子][2]就明白了。
```python
def log_decorator(f):
    def cant_be_seen(*args, **kwargs):
        log_str = "Call %s, input: " % f.__name__ 
        for arg in args:
            log_str += str(arg)+' '
        for key in kwargs:
            log_str += str(key)+':'+str(kwargs[key])+' '
        print (log_str)
        return f(*args, **kwargs)
    return cant_be_seen

@log_decorator
def sum3(a,b,c) 
    return a+b+c

sum3(1,2,3)
# Call sum3, input: 1 2 3 
# 6
```
这样就可以处理参数不定的情况。
但是，封装函数还会带来这样一个问题，在规范的代码中，我们常常为函数写了大量注释：
```python
@log_decorator
def sum(a,b):
    """
    Add tow numbers
    Input:
        a, b
    Ouput:
        a+b
    """
    return a+b
```
装饰之后函数name与doc都变了：
```python
sum.__name__
#'cant_be_seen'

sum.__doc__
#
```
为了解决这个问题，可以在decorator中定义一个新方法：
```python
def log_decorator(f):
    def cant_be_seen(*args, **kwargs):
        g = f
        g.__name__ = f.__name__
        g.__doc__ = f.__doc__
        log_str = "Call %s, input: " % f.__name__ 
        for arg in args:
            log_str += str(arg)+' '
        for key in kwargs:
            log_str += str(key)+':'+str(kwargs[key])+' '
        print (log_str)
        return g(*args, **kwargs)
    return cant_be_seen
```


[1]: https://github.com/pallets/jinja
[2]: http://www.cnblogs.com/KingCong/p/6412972.html