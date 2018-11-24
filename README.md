# OCEval

### already supported

* [x] if..else..,do..while..
* [x] for..in,for
* [x] @() @[] @{}
* [x] array[0] or dic[@""]
* [x] block
* [x] call C external function

### harder part

* [ ] support Mac
* [ ] C struct: frame.origin.x  look at YYModel
* [ ] [super dosth];
* [ ] @interface @property @implementation
* [ ] -(void)foo
* [ ] Memory management
* [ ] macro like #define xx or typedef
* [ ] call C inline function

### easy parter

* [ ] i++,++i,i+=1 : use `i = i + 1` instead
* [ ] ((YES)&&(NO)) : use `(YES && NO)` instead
* [ ] if(a) : use `if(a != nil)` instead
* [ ] [stringformat:@"%d",aInt] : use `[stringformat:@"%@",[NSNumber numberWithInt:aInt]]` instead
* [ ] ?:   :  use `if else` instead
* [ ] _propertyName :  use `self.propertyName` instead


### Can't support
* [ ] macro like #define xx or typedef:  use original word/value instead
