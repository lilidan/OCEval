# OCEval

### already supported

* [x] if..else..,do..while..
* [x] for..in,for
* [x] @() @[] @{}
* [x] array[0] or dic[@""]
* [x] block
* [x] call C external function
* [x] support Mac

### harder part

* [ ] Memory management: 声明在作用域里的变量，作用域结束的时候才被释放; 解引用和取地址。因为都是堆变量，block不会强引用self，所以strong-weak dance 没有意义。
* [ ] performance: CPU time/Memory
* [ ] [super dosth];
* [ ] C struct: frame.origin.x  look at YYModel
* [ ] @interface @property @implementation
* [ ] -(void)foo
* [ ] macro like #define xx or typedef
* [ ] call C inline function
* [ ] strong weak dance

### easy parter

* [ ] i++,++i,i+=1 : use `i = i + 1` instead
* [ ] ((YES)&&(NO)) : use `(YES && NO)` instead
* [ ] if(a) : use `if(a != nil)` instead
* [ ] [stringformat:@"%d",aInt] : use `[stringformat:@"%@",[NSNumber numberWithInt:aInt]]` instead
* [ ] ?:   :  use `if else` instead
* [ ] _propertyName :  use `self.propertyName` instead


### Can't support
* [ ] macro like #define xx or typedef:  use original word/value instead
