# OCEval

A tiny JIT Interpreter of Objective-C, dynamically run your code like `eval()`.

### Features

- Run Objective-C code dynamically.
- Support iOS & OS X.
- Written by Objective-C.
- Driven By Unit Tests.
- Support part of Low-level APIs like block and C funtion.

# Usage

### Dynamically call Objective-C method
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

### Replace method implementation dynamically

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

### Even make a dynamical app

 Theoretically we could make a whole application written by Objective-C and deliver it through the network. You could read the iOS demo for details.

# Installation

### Cocoapods

```
pod 'OCEval'
```

# TO-DO List

### Already supported syntax

* [x] if..else..,do..while..
* [x] for..in,for
* [x] @() @[] @{}
* [x] array[0] or dic[@""]
* [x] block
* [x] call C external function
* [x] mac application
* [x] i++,++i,i+=1
* [x] if(a){}
* [x] C struct: frame.origin.x  look at YYModel。

### Not support yet

* [ ] call C inline function
* [ ] macro like #define xx or typedef: use original value instead.
* [ ] ((YES)&&(NO)) : use `(YES && NO)` instead
* [ ] [stringformat:@"%d",aInt] : use `[stringformat:@"%@",[NSNumber numberWithInt:aInt]]` instead
* [ ] ?:   :  use `if else` instead
* [ ] _propertyName :  use `self.propertyName` instead
* [ ] if (!a): use `if(a == nil)` instead

# Warning

An app submission to Appstore including this framework will likely be rejected.

# Dependency

- libffi
- Aspect
