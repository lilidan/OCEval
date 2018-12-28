# OCEval

 [![Travis](https://travis-ci.org/lilidan/OCEval.svg?branch=master)](https://travis-ci.org/lilidan/OCEval)
 ![support](https://img.shields.io/badge/support-macOS%20%7C%20iOS-orange.svg)

一个Objective-C解释器, 能够像 `eval()` 一样动态执行OC代码.

[English README](https://github.com/lilidan/OCEval/blob/master/README-EN.md)


### Features

- 动态执行OC代码
- 支持 iOS & OS X.
- 用 Objective-C 编写的.
- 集成单元测试
- 支持 block 和 C 函数调用.

# Usage

### 动态执行OC代码

```Objective-C
//Example 1
NSString *inputStr = @"return 1 + 3 <= 4 && [NSString string] != nil;";
NSNumber *result = [OCEval eval:inputStr];
NSAssert([result boolValue] == YES, nil);
```
```Objective-C
//Example 2
NSString *inputStr = @"{NSArray *content = @[@6,@7,@8,@9,@1,@2,@3,@4];\
NSComparisonResult (^comparison)(id obj1, id obj2) = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {\
return [obj1 doubleValue] > [obj2 doubleValue];\
};\
content = [content sortedArrayUsingComparator:comparison];\
return content;\
}";
NSArray *result = [OCEval eval:inputStr];
NSAssert([result[6] intValue] == 8, nil);
```

### 替换现有的OC方法

通过Aspect的帮助可以替换现有的OC方法。(从而可以实现类似热修复)

```Objective-C

//new implementation code,just call originalInvocation
NSString *viewDidLoad2 = @"{\
[originalInvocation invoke];\
";

[OCEval hookClass:@"ViewController"
         selector:@"viewDidLoad"
         argNames:@[]
          isClass:NO
   implementation:viewDidLoad2];
```

### 甚至编写一个完全动态的App

理论上可以编写一个完全动态的Objective-C的App，然后通过网络下发。当然目前还需要做很多工作。

# Installation

### Cocoapods

```
pod 'OCEval'
```

# TO-DO List

### 已经支持的语法


* [x] if..else..,do..while..
* [x] for..in,for
* [x] @() @[] @{}
* [x] array[0] or dic[@""]
* [x] block 的定义和调用
* [x] call C external function
* [x] i++,++i,i+=1 等
* [x] C struct: 包括CGRect,CGPoint,CGSize,NSRange等常用结构体。
* [x] if(a){}:支持直接判断a是否为nil的简写
* [x] [super doSth]: 支持调用super

部分语法糖的支持尤其是C结构体的支持不太完善。

### 目前不支持的语法(持续改善中)

* [ ] call C inline function 暂不支持C内联函数调用。
* [ ] macro like #define xx or typedef: use original value instead.  暂不支持宏定义,用原本的值替代。
* [ ] ((YES)&&(NO)) : use `(YES && NO)` instead 。 使用条件与/或的时候注意一下括号。
* [ ] [stringformat:@"%d",aInt] : use `[stringformat:@"%@",[NSNumber numberWithInt:aInt]]` instead。 stringWithFormat暂不支持非id对象的类型。
* [ ] ?:   :  use `if else` instead 。 暂不支持三元运算符。
* [ ] _propertyName :  use `self.propertyName` instead 。 暂不支持下划线获取property。
* [ ] if (!a): use `if(a == nil)` instead  。暂不支持if(!a)的简写，需要用if(a == nil)来替代

# Warning

仅作为研究学习使用，提交AppStore审核可能会被拒绝。

# Dependency

- libffi
- Aspect
