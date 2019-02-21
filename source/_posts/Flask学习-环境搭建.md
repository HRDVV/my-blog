---
title: Flask学习-环境搭建
date: 2019-02-21 09:35:33
tags: [python, web, 服务端]
---

> **写在前面**
>
> ------
>
> Flask是python一款轻量级的web框架，使用起来十分灵活，学习它需要一些前置知识：python基础、web后台的知识（比如数据库操作等）。

1. ####  IDE选择

   vscode 和 pyCharm 均可，看个人习惯，pyCharm会更强大一些

2.  #### 创建一个简单的项目结构

   ```shell
   # 创建项目目录
   mkdir my-app
   
   # 进入项目
   cd my-app
   
   # 创建入口文件
   touch main.py
   ```

   

3. #### 虚拟环境安装（virtualenv）

   - 作用：当需要开发多个应用的时候，其实它们都是共用一套python环境，也就是你机器上安装的python2或者python3，但是当不同应用需要引入不同版本的同一个库时，就会比较麻烦了，这时候我们就需要给每个应用配备一套自己的环境，而虚拟环境就是做这个事情的。

   - 安装：(推荐使用pipenv)

     ```python
     '''
        安装时，一定要在指定项目根目录下执行命令
     '''
     pip install pipenv
     ```

   - 常用的pipenv 命令

     ```python
     # 进入虚拟环境
     pipenv shell
     
     # 安装第三方模块或库
     pipenv install [moudleName]
     
     # 卸载模块
     pipenv uninstall [moudleName]
     
     # 查看安装的依赖
     pipenv graph
     
     # 退出虚拟环境
     exit
     ```

4. #### 安装Flask

```python
# 要进入虚拟环境
pipenv install flask
```

5. #### 启动flask应用

```python
# main.py

# 引入flask库
from flask import Flask

# 创建flask核心对象
app = Flask(__name__)

# 创建视图函数(类似于controller)
@app.route('/')
def hello():
    return 'hello world'

'''
    判断模块名是不是__main__,开发环境的是python main.py方式启动的，
    这时候__name__ = '__main__', 但是生产环境时，main.py是以普通模块的形式加载的，
    __name__ != '__main__', 这是因为，开发和生产使用不同的服务，
    开发使用flask内置的服务(app.run()), 加这个判断就是避免线上环境运行了app.run()
'''
 
if __name__ == '__main__':
    app.run()
```

> **写在最后**
>
> ------
>
> 后续将不定时更新，后面更精彩！