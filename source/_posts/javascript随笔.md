---
title: javascript随笔(一)
date: 2019-06-05 22:59:22
tags: [javascript]
---

#### new到底对构造函数做了什么？

这个问题非常经典，对js的面向对象熟悉的人张口就能回答出来，但是，让你用代码该怎么展示这个过程呢？先文字描述一下实例化对象的特征：

```javascript
1、能够调用构造函数中的方法或属性
2、能够调用构造函数原型中的方法和属性
3、当构造函数本身存在返回值时，若返回值类型是非null的对象，实例对象指向返回的那个对象，否则正常返回实例对象
```

new的作用：

```javascript
1、创建一个空对象object
2、将object的__proto__指向构造函数的原型
3、运行构造函数，并将this指向object
4、返回对象，主要看构造函数返回值是否是非null的对象，是则返回该对象，不是就正常返回object
```

模拟new的过程

```javascript
function factory (Constructor) {
  // 创建空对象
  var object = new Object()
  // 将object的__proto__指向构造函数的原型
  object.__proto__ = Constructor.prototype
  // 运行构造函数，并将this指向object
  const returnObj = Constructor.apply(object, Array.prototype.slice.call(arguments, 1))
  // 根据构造函数的返回值判断返回什么
  return  returnObj && typeof returnObj === 'object' ? returnObj : object
}

// 对比一下我们自己写的工厂函数和new是否能达到相同的效果
// 1.构造函数没有返回值
function Person (name, age) {
  this.name = name
  this.age = age
}
Person.prototype.run = function() {
  return '会跑步'
}
// 2.构造函数返回值为对象
function Person1 (name, age) {
  this.name = name
  this.age = age
  return {
    name: 'hello world'
  }
}
Person1.prototype.run = function() {
  return '会跑步'
}

var p1 = new Person('hrd', 26)
var p2 = factory(Person, 'hrd', 26)

var p3 = new Person1('hrd', 26)
var p4 = factory(Person1, 'hrd', 26)

console.log('p1.name:%c%s%c, p2.name:%c%s', 'color: blue;', p1.name, 'color:#000;', 'color:blue;', p2.name)
console.log('p1.run:%c%s%c, p2.run:%c%s', 'color: blue;', p1.run(), 'color:#000;', 'color:blue;', p2.run())
console.log('p3.name:%c%s%c, p4.name:%c%s', 'color: blue;', p3.name, 'color:#000;', 'color:blue;', p4.name)
console.log('p3.run:%c%s%c, p4.run:%c%s', 'color: blue;', p3.run, 'color:#000;', 'color:blue;', p4.run)

```

结果如下：

![](/images/blog/console.png)

 