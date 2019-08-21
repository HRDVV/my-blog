---
title: Taro在小程序中的应用
date: 2019-08-20 07:25:47
tags: [typescript, react]
---

> 写在前面：开发前务必浏览一遍[taro规范](http://taro-docs.jd.com/taro/docs/spec-for-taro.html)，这一点非常重要，后面的编码规范也是在这个基础上进行修改的

#### 1. 安装脚手架

```shell
# 使用 npm 安装 CLI
$ npm install -g @tarojs/cli
# OR 使用 yarn 安装 CLI
$ yarn global add @tarojs/cli
```

#### 2. 初始化项目

```shell
# 初始化，可根据提示选择使用的模块，这里选择的typescript，sass，redux官方模板
$ taro init [projectName]
# 自定义模板，后续我们的模板稳定后上传到自己的仓库，并根据暴露的参数定制动态模板
$ taro config set templateSource [value ?: git地址或zip包地址]
# 如果安装过程出现sass相关的安装错误，请在安装mirror-config-china后重试
$ npm install -g mirror-config-china
```

#### 3. 项目结构

```typescript
	// src目录结构
  ├── apis                    // 接口按模块管理 
  │   ├── index.ts
  │   └── news.ts
  ├── app.scss                // 入口样式, 可以在此处引入全局样式
  ├── app.tsx                 // 程序的入口
  ├── assets                  // 静态资源文件
  │   ├── fonts								
  │   ├── images
  │   └── styles
  ├── components              // 公共组件 
  │   └── NewsList
  ├── config                  // 全局配置文件
  │   └── index.ts
  ├── global                  // 通用工具类
  │   ├── decorators          // 装饰器，用于改变类型、方法行为
  │   ├── enums               // 枚举类，比如HTTP_CODE等
  │   └── utils.ts            // 工具函数
  ├── index.html
  ├── packages                // 分包目录，当小程序业务复杂，担心包体积过大，可以配置分包
  ├── pages                   // 页面目录
  │   ├── index	
  │   └── mine
  ├── service                 // 服务，存放http请求工具和拦截器
  │   ├── interceptor.ts
  │   ├── request.d.ts
  │   └── request.ts
  └── store                   // 全局的状态管理
      ├── actions             // 要派发的动作
      ├── constants           // 常量，用于存放actionType
      ├── index.ts            // store入口
      └── reducers            // 改变state的途径， 类似vue里的mutations
```

#### 4.编译的基本配置 

```typescript
// config/index.js
  ...
/*sass配置*/
plugins: {
    sass: {
      // 默认导入variable，mixins
      data: `@import '@/assets/styles/_variable.scss';@import '@/assets/styles/_mixins.scss';`,
      // taro不支持在样式文件中使用别名，做如下处理兼容一下，否则上边的data配置也会报错
      importer: function(url) {
        const reg = /^@\/assets\/styles\/(.*)/
        return {
          file: reg.test(url) ? path.resolve(__dirname, '..', 'src/assets/styles', url.match(reg)[1]) : url
        }
      }
    },
 ...
 }
 
/*alias,别名配置*/
 
// 第一步
alias: {
  '@': path.resolve(__dirname, '..', 'src')
}
// 第二步：tsconfig.json中compilerOptions字段，防止vscode标红
"paths": {
  "@/*": ["./src/*"]
}
// 使用
import api from '@/apis'
```

#### 5. 编码规范

```json
// .eslintrc
// 带🔧的是可以自动修复的

{
  // 继承与taro规范，所以务必读一遍
  "extends": ["taro"],
  // 这些规则后期稳定了，会发npm包，eslint-config-yp
  "rules": {
    /*
    	含义：禁止出现未使用过的变量。taro默认是error级别的，这里关闭掉
    	原因是在ts下taro很多类型会报no-unused-vars，而且关闭并不影响ts的语法检查(xxx is declared but 			its value is never read.) 
    */
    "no-unused-vars": ["off", { "varsIgnorePattern": "Taro|Config|Chain" }],
    // 哪些后缀的可以包含jsx语法
    "react/jsx-filename-extension": [1, { "extensions": [".js", ".jsx", ".tsx"] }],
    /*
    	react组件生命周期排序，默认是开启的，这里关闭掉,
    	原因是小程序有config的属性，如果开启，就只能把它放后面，否则会有警告，
    	但是除了它，在编写代码时还是要按照生命周期的顺序来，顺序看taro规范
    */
    "react/sort-comp": 0,
    // 关闭不能使用common模块方式导入的规则
    "import/no-commonjs": 0,
    // 不能在代码里写debugger
    "no-debugger": 2,
    // 🔧必须使用单引号
    "quotes": [2, "single"],
    // 🔧禁止分号
    "semi": [2, "never"],
    // 🔧强制在大括号中使用一致的空格
    "object-curly-spacing": [2, "always"],
    // 禁止在循环中出现 await
    "no-await-in-loop": 2,
    /*
    	强制 “for” 循环中更新子句的计数器朝着正确的方向移动
    	❌ for (var i = 0; i < 10; i--) {}
    */
    "for-direction": 2,
    // 禁止在常规字符串中出现模板字面量占位符语法
    "no-template-curly-in-string": 2,
    // 强制把变量的使用限制在其定义的作用域范围内
    /* ❌
      function doIf() {
        if (true) {
            var build = true;
        }
        console.log(build);
      }
    */
    "block-scoped-var": 2,
    // 🔧禁止不必要的 .bind() 调用
    "no-extra-bind": 2,
    // 要求使用 Error 对象作为 Promise 拒绝的原因
    "prefer-promise-reject-errors": 2,
    // 禁止使用不带 await 表达式的 async 函数
    "require-await": 2,
    // 🔧匿名函数自调用，必须用括号包裹在外层
    "wrap-iife": [2, "outside"],
    // 禁止变量声明与外层作用域的变量同名
    "no-shadow": 2,
    // 禁止在变量定义之前使用它们
    "no-use-before-define": 2,
    // 🔧强制数组方括号中使用一致的空格
    "array-bracket-spacing": [2, "never"],
    // 🔧强制在代码块中开括号前和闭括号后有空格
    "block-spacing": [2, "always"],
    // 🔧强制在代码块中使用一致的大括号风格
    "brace-style": [2, "1tbs", { "allowSingleLine": true }],
    // 🔧禁止在函数标识符和其调用之间有空格
    "func-call-spacing": [2, "never"],
    // 🔧强制使用一致的缩进
    "indent": [2, 2, { "SwitchCase": 1 }],
    // 🔧jsx语法引号强制单引号，Taro要求
    "jsx-quotes": [2, "prefer-single"],
    // 🔧强制在对象字面量的属性中键和值之间使用一致的间距
    "key-spacing": 2,
    // 🔧强制在块之前使用一致的空格
    "space-before-blocks": 2,
    // 🔧强制 generator 函数中 * 号周围使用一致的空格
    "generator-star-spacing": [2, { "before": false, "after": true }],
    // 禁止重复模块导入
    "no-duplicate-imports": 2,
    // 🔧要求模板字符串中的嵌入表达式周围空格的使用
    "template-curly-spacing": [2, "always"],
    // 禁止多次声明同一变量
    "no-redeclare": 2,
    // 🔧要求操作符周围有空格
    "space-infix-ops": 2,
    // 🔧强制在一元操作符前后使用一致的空格
    "space-unary-ops": 2,
    // 🔧强制箭头函数的箭头前后使用一致的空格
    "arrow-spacing": 2,
    // 🔧强制在逗号前后使用一致的空格
    "comma-spacing": 2,
    // 🔧要求文件末尾存在空行
    "eol-last": ["error", "always"],
    // 🔧要求文件末尾空行最多1行
    "no-multiple-empty-lines": ["error", { "max": 1, "maxEOF": 0 }],
    // 关闭只能用export default导出的限制
    "import/prefer-default-export": 0
  },
...
  
  // .eslintignore
  config/
  dist/
  node_modules/
  *.html
  global.d.ts
  
// vscode配置（如果使用其他编辑器或ide下载相应的eslint插件）
  // "eslint.validate": [
    // "javascript",
    // "javascriptreact",
    // "html",
    // "vue",
    // {
    //     "language": "typescript",
    //     "autoFix": true
    // },
    // {
    //     "language": "typescriptreact",
    //     "autoFix": true
    // },
    // "typescript",
    // "typescriptreact"
// ],
// "eslint.autoFixOnSave": true


```

#### 6. 工程规范

+ 代码开头要加作者注释

+ 公共方法上方要加注释

  ```typescript
  /**
   * request
   * @param options
   */
  function ajax(options: RequestConfig): Promise<any> {...}
  ```

+ 样式命名和vue项目的保持一致，组件cp-*，页面pg-* 等

+ 页面和组件使用tsx后缀，普通文件使用ts

+ 普通 JS/TS 文件以小写字母命名，多个单词以**中划线**连接，例如 `util.js`、`util-helper.js`

+ 组件文件命名遵循 Pascal 命名法，例如 `ReservationCard.jsx`，或者文件命名为ReservationCard，里面写个index.tsx

+ 和业务相关的代码按照模块拆分，如redux，api等

+ 自定义组件设置addGlobalClass: true，使组件可以受外界样式操控

+ 要给组件设置defaultProps

+ 组件传递函数属性名以`on`开头

+ 在 Taro 中，JS 代码里必须书写单引号，特别是 JSX 中，如果出现双引号，可能会导致编译错误

+ 不要以解构的方式来获取通过 `env` 配置的 `process.env` 环境变量，请直接以完整书写的方式 `process.env.NODE_ENV` 来进行使用

+ 尺寸使用：px在taro会被自动转换，如果不需要转换要写成Px或PX，例如边框、app一般nav和tabbar都是固定高度

+ 组件和页面文件夹写*.d.ts类型声明文件，用于提供state，props等一些类型的提示

  ```tsx
  └── NewsList
      ├── List.scss
      ├── List.tsx
      ├── index.d.ts  // 类型声明
      └── index.tsx
  
  export type ListItem = {
    time: string,
    content: string,
    category: string,
    pic: string,
    title: string,
    src: string
  }
  export type PageOwnProps = {
    newsList: Array<ListItem>
  }
  export type Item = {
    item: ListItem,
    playing: any,
    onPlay: Function
  }
  // 使用
  import { PageOwnProps, ListItem } from './index.d'
  ```

+ 页面class组件泛型使用

  ```typescript
  // 没使用状态管理的页面
  class Index extends Component<PageOwnProps, PageState> {...}
  // 使用状态管理的页面
  // index.d.ts
  export type PageOwnProps = {}
  export type PageOwnState = {}
  export type PageStateToProps = {}
  export type IProps = PageOwnProps & PageStateToProps
  
  //index.tsx
  import { ComponentClass } from 'react'
  import { IProps, PageOwnState } from './index.d'
  @connect(mapStateToProps, mapDispatchToProps)
  class Index extends Component<IProps, PageOwnState> {...}
  export default Index as ComponentClass<PageOwnProps, PageState>
  
  // or 
    
  import { ComponentClass } from 'react'
  import { IProps, PageOwnState } from './index.d'
  
  class Index extends Component<IProps, PageOwnState> {...}
  export default connect(mapStateToProps, mapDispatchToProps)(Index) as ComponentClass<PageOwnProps, PageState>
  
  ```

+ 无状态组件尽量使用FunctionComponent

+ 容器组件也可以使用FunctionComponent + hooks，但是页面组件还是用class吧，taro的hooks在小程序中还不太完善，小程序特有的生命周期没有一个合理的实现

  ```tsx
  // hooks 举个🌰
  
  // 还是比较整洁，据说vue3.0的functional灵感也来源于他，早点入坑早登极乐😁~~
  import Taro, { useCallback, useState } from '@tarojs/taro'
  
  const NewsList = (props: PageOwnProps): JSX.Element => {
    const { newsList } = props
    const [playing, setPlay] = useState({})
    const onPlay = useCallback((newsItem) => {
      setPlay(newsItem)
    }, [])
    return (
      <View className="cp-news-list">
        {
          newsList.map((newsItem: ListItem) => {
            return (
              <View key={newsItem.title}>
                <List 
                  item={newsItem}
                  playing={playing}
                  onPlay={() => { onPlay(newsItem) }}
                />
              </View>
            )
          })
        }
      </View>
    )
  }
  ```

+ 全局类型声明

  ```typescript
  // global.d.ts
  
  //举栗子
  ...
  
  interface ResponseModel {
    success: boolean
    data: any
    message: string | null
    code: string
  }
  interface pagingResult {
    success: boolean
    list: Array<any>
    message: string | null
    code: string
    [props: string]: any
  }
  ...
  ```

#### 7.  可以优化的地方

+ taro官方文档好好看一遍

+ 推荐使用async-await方式进行同步代码的体验

+ 避免多次setState，尽量合并更新

+ 组件需要避免多次更新带来的额外开销时，继承PureComponent，但是PureComponent只是帮你做了shouldComponentUpdate，并且只是浅比较，也就是说如果是引用类型你只改变内部的值这时就会出问题，页面不会render，解决问题办法如下：

  1、 继承Component，手动shouldComponentUpdate，自己写一个深比较抽离成公共方法，写成注解的形式，给shouldComponentUpdate加上这个注解

  ```typescript
  // 方案一：
  function Compared(target, propertyKey, descriptor) {
    descriptor.value = function(nextProps, nextState): boolbean {
      let preState = this.state
  		// 这里写比较的具体方法
    }
  }
  @Compared
  shouldComponentUpdate(){ return true }
  
  ```

  2、继承PureComponent，引用类型更新时不要只更新其中一个下标的值，可以用解构等用新的引用去更新

  3、使用immutable进行比较，说实话，虽然强大，但是代码侵入性较强

  ```typescript
  // class 组件
  import Taro, { PureComponent } from '@tarojs/taro'
  class Index extends PureComponent<Props, State> {...}
  
  // function 组件
  function Index(props: Props): JSX.Element {...}
  function areEqual(prevProps, nextProps) {
    /*
    如果把 nextProps 传入 render 方法的返回结果与
    将 prevProps 传入 render 方法的返回结果一致则返回 true，
    否则返回 false
    */
  }
  export default Taro.memo(Index, areEqual)
                    
  /*注意 与 class 组件中 shouldComponentUpdate() 方法不同的是，如果 props 相等，areEqual 会返回 true；如果 props 不相等，则返回 false。这与 shouldComponentUpdate 方法的返回值相反。*/
  ```

  
