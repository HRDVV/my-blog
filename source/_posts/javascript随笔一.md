---
title: javascript随笔(一)
date: 2019-06-05 22:59:22
tags: [javascript]
---

#### new到底对构造函数做了什么？

这个问题非常经典，对js的面向对象熟悉的人张口就能回答出来，但是，让你用代码该怎么展示这个过程呢？先文字描述一下实例化对象的特征：

```javascript
能够调用构造函数中的方法或属性
能够调用构造函数原型中的方法和属性
当构造函数本身存在返回值时，若返回值类型是非null的对象，实例对象指向返回的那个对象，否则正常返回实例对象
```

new的作用：

```javascript
创建一个空对象object
将object的__proto__指向构造函数的原型
运行构造函数，并将this指向object
返回对象，主要看构造函数返回值是否是非null的对象，是则返回该对象，不是就正常返回object
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

#### typeof、instanceof区别

typeof一般用于判断js的基本类型，如string, number, boolean, undefined, function, object, symbol

```javascript
var str = 'hello world'
var num = 2019
var bool = true
var undef
var func = function () {}
var arr = [1, 2, 3]
var obj = { name: 'hrd', age: '26' }
var sym = Symbol('hi')
var nu = null
console.log(typeof str)      // string
console.log(typeof num)      // number 
console.log(typeof undef)    // undefined
console.log(typeof func)     // function
console.log(typeof arr)      // object
console.log(typeof obj)      // object
console.log(typeof sym)      // symbol
console.log(typeof nu)       // object
```

分析：从以上打印结果能够看出，判断简单类型和function都没什么问题，但是引用类型（函数除外）的判断就不是那么清晰了，都会返回'object'。变量的都是以二进制进行存储的，类型标志位是0的都会返回对象，那这个null是怎么回事呢？null在大多数编程语言中都是表示空指针0x00，正好符合对象的判断，其实这是一个js的bug，曾经有人提出要修复这个问题，但是被拒绝了，并一直延续至今，竟成了js的feature。最后，问题来了，要想判断对象的类型怎么办？下面一起来看一下instanceof这个运算符。

```javascript
class Animal {}
class Dog extends Animal {}
var dog = new Dog()

console.log(arr instanceof Array)     // true
console.log(arr instanceof Object)    // true
console.log(obj instanceof Object)    // true
console.log(func instanceof Object)   // true
console.log(func instanceof Function) // true
console.log(dog instanceof Dog)       // true
console.log(dog instanceof Animal)    // true
```

分析： 其实呢？instanceof是用来判断运算符右侧是否出现在左侧的原型链中，说到原型链就盗个图贴上吧！😁

![](/images/blog/prototype.jpg)

下面用代码表达一下instanceof的运行过程

```javascript
function hasInstance (ins, constructor) {
  if (ins === null &&  constructor !== null) {
    return false
  } else if (constructor === null) {
    throw(new TypeError('Right-hand side of 'instanceof' is not an object'))
  }
  var proto = ins.__proto__
  var prototype = constructor.prototype
  while (proto !== prototype) {
    if (proto === null) return false
    proto = proto.__proto__
  }
  return true
}

// test 
console.log(hasInstance(arr, Array))      // true
console.log(hasInstance(arr, Object))     // true
console.log(hasInstance(obj, Object))     // true
console.log(hasInstance(func, Object))    // true
console.log(hasInstance(func, Function))  // true
console.log(hasInstance(dog, Dog))        // true
console.log(hasInstance(dog, Animal))     // true
console.log(hasInstance(obj, Animal))     // false
console.log(hasInstance(null, Animal))    // false
console.log(hasInstance(null, null))      // TypeError
```

其实，最后你发现还是不能那么清楚明白的判断类型，比如arr，func，那么到底怎么才能判断变量类型呢？

```javascript
// Object.prototype.toString.call(target)
console.log(Object.prototype.toString.call(arr))  // [object Array]
console.log(Object.prototype.toString.call(obj))  // [object Object]
console.log(Object.prototype.toString.call(func)) // [object Function]
console.log(Object.prototype.toString.call(dog))  // [object Object]
console.log(Object.prototype.toString.call(null)) // [object Null]
```



