# OCEval

### already supported

* [x] if..else..,do..while..
* [x] for..in,for
* [x] @() @[] @{}
* [x] array[0] or dic[@""]
* [x] block
* [x] call C external function
* [x] support Mac
* [ ] Memory management: 声明在作用域里的变量，作用域结束的时候才被释放; 因为都是堆变量，block不会强引用self，所以strong-weak dance 没有意义?
* [x] i++,++i,i+=1
* [x] if(a)
* [ ] 解引用和取地址。
* [ ] C struct: frame.origin.x  look at YYModel。

### harder part

* [ ] @interface @property @implementation
* [ ] -(void)foo
* [ ] K线demo。如果性能不行，就开源。
* [ ] call C inline function
* [ ] macro like #define xx or typedef.
* [ ] performance: CPU time/Memory:  普通遍历很慢，远远慢于native和js，需要优化。字符串拼接和表达式都很慢。单个方法调用比js快一点，比native慢很多。 多个重复调用因为没有缓存，也比较慢。后期考虑采用msgsend而不是invocation。
* [ ] 表达式计算引擎: if(!a)等等，都还没支持。
* [ ] [super dosth]; NSInvocation 全转成ObjcMsgsend才好。关键是parse的时候拿不到methodsignature。不知道返回值的类型。必须要依赖全局编译器，知道每个返回值的类型才好办。不然就只有runtime时再判断返回值的类型。
* [ ] 内存管理，非常复杂。尤其是block的内存管理。

### easy part


* [ ] ((YES)&&(NO)) : use `(YES && NO)` instead
* [ ] [stringformat:@"%d",aInt] : use `[stringformat:@"%@",[NSNumber numberWithInt:aInt]]` instead
* [ ] ?:   :  use `if else` instead
* [ ] _propertyName :  use `self.propertyName` instead
* [ ] demo 做一个60fps的K线的列表出来。


### Can't support
* [ ] macro like #define xx or typedef:  use original word/value instead
