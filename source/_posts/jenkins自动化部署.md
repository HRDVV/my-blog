---
title: jenkins自动化部署
date: 2019-05-18 23:15:47
tags: [docker,jenkins]
---
> **写在前面**
>
> ------
>
> 该文用于记录学习jenkins自动化部署前端项目的过程，以本博客为例

1. #### 安装、运行jenkins

   + 第一种：可以到[jenkins官网](https://jenkins.io/)去下载war包，然后`java -jar jenkins.war　`去启动它（前提是你已经安装了jdk），默认端口为8080，当然也可以在tomcat中去启动，这就是一个普通web项目的部署流程

   + 第二种：docker容器的方式安装运行jenkins，这也是本文要重点讲的。

     ##### 下载jenkins的docker镜像,要先安装docker(自行安装)

     `docker pull jenkins/jenkins`

     ##### 查看docker镜像，查看是否存在

     `docker images`

     ##### 运行jenkins容器

     ```javascript
     docker run -d -p 8080:8080 -p 5000:50000 -v ~/data/jenkins:/var/jenkins_home --name jenkins --privileged=true [镜像ID]
     
     # -d 后台方式运行，防止在终端中打印docker的运行日志
     # -p 端口映射，8080（默认）是宿主机和容器的映射， 50000（默认）是jenkins代理和jenkins主机的映射
     # -v 挂载目录，用于目录的映射（当然可以不映射），~/data/jenkins（喜欢放哪就放哪）是宿主机上的目录
     /*
       如果出现无访问权限的报错（ls -nd 查看归属者），chmod -R 1000:1000 [目录] ，因为容器默认使用	uid=1000，gid=1000来访问卷，如果是没有读写执行权限chmod -R 777 [目录]
     */
     # --name 给容器起个名字
     # --prilileges=true 使容器获得特权
     ```

     #####  交互式进入jenkins容器(需要则进)

     `docker exec -it [运行时你起的哪个名字] /bin/bash `

2. #### 访问jenkins

   主机ip:8080, 即可访问，这时会让你输入密码，这时可以在容器内获得：

   没挂载目录：`docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

   挂在目录：`cat [挂载的目录]/secrets/initialAdminPassword`

3. #### 下载插件并创建用户

   按照推荐的来就行，有下载失败的没关系，点击continue进入下一页面去创建用户，以后就可以用你新设置的账号去登录jenkins了

4. #### 给你的jenkins的设置一个域名

   这时候nginx就要闪亮登场了，这里是默认你有备案域名的：

   + 先设置一个二级域名，例如： `jenkins.ruidasir.com`

   + 在nginx中为其配置基于域名的虚拟主机

     ```nginx
     server {
         listen       80;
         server_name  jenkins.ruidasir.com;
     	...
         location / {
         	# 配置反向代理
         	proxy_pass http://127.0.0.1:8080;
         }
       ...
     ```

5. #### 安装所需插件

   Github Plugin（在jenkins中整合github api等）、NodeJS Plugin（在jenkins中配置node环境）、Public Over SSH(用于构建之后的部署到远程服务器)、Generic Webhook Trigger plugin(实现构建触发器，比如当提交代码时，自动触发打包部署)

   `注意： 如果搜不到插件，就到[系统设置]-[插件管理]-[高级]`，将升级站点的url改为http://mirror.xmission.com/jenkins/updates/update-center.json，随后点击submit，check now

6. #### 配置插件

NodeJS Plugin

![](//img.ruidasir.com/images/node.png)

```
name: 随便起，后续自己能识别出来就行,
勾选自动安装，选择一个node版本，根据业务需要，一般最新的即可
```

Public Over SSH

![](http://img.ruidasir.com/images/ssh.png)

```javascript
passphrase: 填写服务器ssh密码
name: 可以随便填
Hostname: 服务器的公网ip
Username: ssh登录名称
Remote Directory: 部署到远程服务器的路径，填写根路径即可
```

7. #### 新建任务

   ![](http://img.ruidasir.com/images/task.png)



![](http://img.ruidasir.com/images/build1.png)

```
勾选Github项目： URL设置成你想部署的git仓库地址
Source Code Management(源码管理)：选择Git
1、Resposittory URL: 想部署的git仓库地址
2、Credentials: 点击Add,设置jenkins凭证，默认是Username With Password 类型，填写github的用户名和密码，用于拉取git仓库，添加后，在下拉框中选择刚刚添加的凭证
往下看，可以指定分支，一般默认master
```

![](http://img.ruidasir.com/images/build2.png)

```
勾选Generic Webhook Trigger
Token： 随便整，到时候和github上对应就行
根据Token输入框下面那堆字儿，可以知道，构建触发器，是通过http: [jenkins_url]/generic-webhook-trigger/invoke?token=[你设置的]请求触发的。如果你有点蒙，继续往下看就会很清晰了。
```

![](http://img.ruidasir.com/images/build3.png)

```
勾选Github hook trigger for GITScm polling 
Build Environment
勾选Provide Node & npm bin/folder to PATH
NodeJS 安装器选择前面你配置的那个node名称
```

![](http://img.ruidasir.com/images/build4.png)

```
用于编译的命令
```

![](http://img.ruidasir.com/images/build5.png)

```
编译后的动作，点击‘add post build action’选择send build artifacts over SSH
Source files: 将谁发送给服务器
Remove prefix: 去掉前缀，直接把压缩包传过去
Remote directory: 发送到服务器的那个目录下
Exec comand: 发送完毕后执行什么操作
```

`写到这，整个任务也就建好了，下面讲一下怎么配置wenhook来触发自动打包构建`

8. #### 关键的关键，实现push代码后，自动打包部署

配置github

![](http://img.ruidasir.com/images/git1.png)

![](http://img.ruidasir.com/images/git2.png)

```
进到项目仓库中，点击settings -> Webhooks -> Add webhook
Payload URL: 还记得在jenkins中配置的Generic webhook trigger吗？ 这填写的就是那个用于触发构建器的请求地址，http: [jenkins_url]/generic-webhook-trigger/invoke?token=[你设置的]
Content type: 选择application/json，默认也可
Secret: 不用填
触发钩子的事件: 按照你的要求来，我这里就选push

流程：push代码到master -> git发送请求 -> jenkins接受请求 -> 触发构建器

```

`如果你以为到这就完事了，你就太幼稚了，哈哈哈哈, 来，醒醒，我们继续`

![](http://img.ruidasir.com/images/git3.png)

![](http://img.ruidasir.com/images/git4.png)

```
进到github账号的settins -> 开发者设置 -> Personal access tokens -> 生成一个token；
然后，给这个token填个note，标识它的用处；
下面，选择这个token能被允许做的操作，说白了，jenkins要调用github的api，要用你的私钥，现在就是在为你的私钥选择权限，这样jenkins就能获取你的提交状态，管理你的hook；
现在我们就能生成token了，生成后先保存起来，一会我们会用到；
接下来，我们看一下jenkins要怎么调api。
```

![](http://img.ruidasir.com/images/webhook.png)

![](http://img.ruidasir.com/images/webhook1.png)

```
名称： 随便填写
Api url：填写默认的就好，如果是企业用户，需要加/api/v3后缀
凭据：选择Secret text, 你应该猜到了，这个Secret就是我们刚刚生成的personal access token，点击添加，下拉框选择它
```

9. #### 终于结尾了

   > 写到这，全部配置就好了，现在进到任务中，点击立即构建试试吧，报错没关系，查看日志哦，如果说是缺少node包，或者你觉得这太慢了，我这提供两种解决方法：
   >
   > 1、在打包阶段，将安装node包、切换npm源的命令写进去
   >
   > 2、进到容器中，找到node安装路径，去做这些工作
   >
   > ```shell
   > cd /var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/
   > cd [node安装目录]
   > # 安装包
   > ./bin/node install [module name]
   > # 切换源
   > ./bin/node npm config set registry https://registry.npm.taobao.org
   > ```

