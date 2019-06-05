---
title: Flask学习-重构helloworld项目
date: 2019-02-21 14:08:25
tags: [python]
---

### 写在前面

> 在环境搭建一文中，已经学习了怎么跑起一个helloworld，这只是万里长征第一步，本章节就来重构一下它，让它更贴近实际开发。

#### 推荐的项目结构

```python
├── Pipfile
├── Pipfile.lock        
├── app                      # 应用目录
│   ├── api                  # 用于存放第三方接口的调用
│   ├── form                 # 入参校验
│   ├── models	             # 数据层-存放库表模型
│   ├── secury.py            # 涉及到安全的配置文件
│   ├── settings.py          # 常规的配置
│   ├── static               # 静态资源
│   ├── tpl                  # 页面模板文件
│   ├── utils                # 封装的工具类
│   └── web                  # controller层，存放项目的蓝图
├── main.py                  # 入口文件
└── test                     # 测试目录，可以跑一些测试脚本
```

#### 解释蓝图的作用

> 在helloworld程序中，我们将路由（视图函数）都放在入口文件中了，试想，当程序变得越来越大时，入口文件的体积将变得很大，很不好维护，这十分的糟糕。所以，我们应该按照业务模块进行路由的划分，而蓝图就是做这件事情的，它可以把路由划分成一个个模块，最终都注册到app上，一个程序中可以有多个蓝图。

#### 将flask核心对象app进行拆分

```python
"""
    在app目录下新建__init__.py，该文件顾名思义可以用来初始化，
    引入当前包的时候就会执行，相当于把当前包当模块来使用，所以可以将公共的内容放在这。
"""
	
# app/__init__.py

    from flask import Flask
    
    # 为什么不放main中？
    # 因为很多地方都会用flask核心对象app，且项目中会注册很多插件或蓝图，所以单独维护
    def create_app():
        app = Flask(__name__)
        return app
    
# main.py

    from app import create_app
    
    app = create_app()

    @app.route('/')
    def hello():
        return 'hello world'
    
    if __name__ == '__main__':
        app.run()
```

#### 对路由进行拆分

```python
# 在web目录下新建__init__.py和路由模块（比如，goods.py)

    # web/__init__.py
        from flask import Blueprint
        # 传入蓝图名称和导入名称
        web = Blueprint('web', __name__)
        # 模块只有被导入才会被执行，所以蓝图下挂的路由都要在这导入一下
        from app.web import goods

    # web/goods.py
        from app.web import web

        @web.route('/')
        def hello():
            return 'hello world'

# 注册蓝图

   # app/__init__.py
    from flask import Flask

    def create_app():
        app = Flask(__name__)
        register_blueprint(app)
        return app
    
    # 注册蓝图的方法
    def register_blueprint(app):
        # 导入蓝图
        from app.web import web
        app.register_blueprint(web)

```

#### 配置文件的使用

```python
# 注意：配置文件中的变量都要使用大写字母，以下划线连接

# 在flask核心对象app上注入配置文件
# app/__init__.py
    def create_app():
        app = Flask(__name__)
        # 参数是模块，而不是路径，不要写成路径
        app.config.from_object('app.settings')
        app.config.from_object('app.secury')
        register_blueprint(app)
        return app
```

#### 热部署的实现

```python
# app/settings.py
     DEBUG = True

# main
     if __name__ == '__main__':
        # host=0.0.0.0让所有ip可访问
        app.run(debug=app.config['DEBUG'], port=8080, host='0.0.0.0')
    
  
```

### 写在最后

> 后续将不定时更新，后面更精彩！预告：梳理Form，sqlalchemy，requests的使用