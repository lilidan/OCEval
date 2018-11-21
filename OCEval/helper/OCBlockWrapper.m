//
//  JPBlockWrapper.m
//  JSPatch
//
//  Created by bang on 1/19/17.
//  Copyright © 2017 bang. All rights reserved.
//

#import "OCBlockWrapper.h"
#import "ffi.h"
#import "OCMethodSignature.h"
#import "OCBlockNode.h"
#import "OCScopeNode.h"
#import "OCMethodNode+invoke.h"

enum {
    BLOCK_DEALLOCATING =      (0x0001),
    BLOCK_REFCOUNT_MASK =     (0xfffe),
    BLOCK_NEEDS_FREE =        (1 << 24),
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26),
    BLOCK_IS_GC =             (1 << 27),
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_USE_STRET =         (1 << 29),
    BLOCK_HAS_SIGNATURE  =    (1 << 30)
};

struct JPSimulateBlock {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct JPSimulateBlockDescriptor *descriptor;
    void *wrapper;
};

struct JPSimulateBlockDescriptor {
    //Block_descriptor_1
    struct {
        unsigned long int reserved;
        unsigned long int size;
    };

    //Block_descriptor_2
    struct {
        // requires BLOCK_HAS_COPY_DISPOSE
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
    };

    //Block_descriptor_3
    struct {
        // requires BLOCK_HAS_SIGNATURE
        const char *signature;
    };
};

void copy_helper(struct JPSimulateBlock *dst, struct JPSimulateBlock *src)
{
    // do not copy anything is this funcion! just retain if need.
    CFRetain(dst->wrapper);
}

void dispose_helper(struct JPSimulateBlock *src)
{
    CFRelease(src->wrapper);
}


@interface OCBlockWrapper ()
{
    ffi_cif *_cifPtr;
    ffi_type **_args;
    ffi_closure *_closure;
    BOOL _generatedPtr;
    void *_blockPtr;
    struct JPSimulateBlockDescriptor *_descriptor;
}

@property (nonatomic,strong) OCMethodSignature *signature;
@property (nonatomic,strong) OCScopeNode *node;
@property (nonatomic,strong) NSArray *varableNames;
@property (nonatomic,strong) NSDictionary *ctx;

@end

void JPBlockInterpreter(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    OCBlockWrapper *blockObj = (__bridge OCBlockWrapper*)userdata;

    NSMutableDictionary *params = (NSMutableDictionary *)(blockObj.ctx);
    
    for (int i = 1; i < blockObj.signature.argumentTypes.count; i ++) {
        NSString *key = blockObj.varableNames[i - 1];
        id param;
        void *argumentPtr = args[i];
        const char *typeEncoding = [blockObj.signature.argumentTypes[i] UTF8String];
        switch (typeEncoding[0]) {
        
        #define JP_BLOCK_PARAM_CASE(_typeString, _type, _selector) \
            case _typeString: {                              \
                _type returnValue = *(_type *)argumentPtr;                     \
                param = [NSNumber _selector:returnValue];\
                break; \
            }
            JP_BLOCK_PARAM_CASE('c', char, numberWithChar)
            JP_BLOCK_PARAM_CASE('C', unsigned char, numberWithUnsignedChar)
            JP_BLOCK_PARAM_CASE('s', short, numberWithShort)
            JP_BLOCK_PARAM_CASE('S', unsigned short, numberWithUnsignedShort)
            JP_BLOCK_PARAM_CASE('i', int, numberWithInt)
            JP_BLOCK_PARAM_CASE('I', unsigned int, numberWithUnsignedInt)
            JP_BLOCK_PARAM_CASE('l', long, numberWithLong)
            JP_BLOCK_PARAM_CASE('L', unsigned long, numberWithUnsignedLong)
            JP_BLOCK_PARAM_CASE('q', long long, numberWithLongLong)
            JP_BLOCK_PARAM_CASE('Q', unsigned long long, numberWithUnsignedLongLong)
            JP_BLOCK_PARAM_CASE('f', float, numberWithFloat)
            JP_BLOCK_PARAM_CASE('d', double, numberWithDouble)
            JP_BLOCK_PARAM_CASE('B', BOOL, numberWithBool)
                
            case '@': {
                param = (__bridge id)(*(void**)argumentPtr);
                break;
            }
        }
        [params setValue:param forKey:key];
    }
    
    id result = [blockObj.node excuteWithCtx:params];

    switch ([blockObj.signature.returnType UTF8String][0]) {

    #define JP_BLOCK_RET_CASE(_typeString, _type, _selector) \
        case _typeString: {                              \
            _type *retPtr = ret; \
            *retPtr = [(NSNumber *)result _selector];   \
            break; \
        }

        JP_BLOCK_RET_CASE('c', char, charValue)
        JP_BLOCK_RET_CASE('C', unsigned char, unsignedCharValue)
        JP_BLOCK_RET_CASE('s', short, shortValue)
        JP_BLOCK_RET_CASE('S', unsigned short, unsignedShortValue)
        JP_BLOCK_RET_CASE('i', int, intValue)
        JP_BLOCK_RET_CASE('I', unsigned int, unsignedIntValue)
        JP_BLOCK_RET_CASE('l', long, longValue)
        JP_BLOCK_RET_CASE('L', unsigned long, unsignedLongValue)
        JP_BLOCK_RET_CASE('q', long long, longLongValue)
        JP_BLOCK_RET_CASE('Q', unsigned long long, unsignedLongLongValue)
        JP_BLOCK_RET_CASE('f', float, floatValue)
        JP_BLOCK_RET_CASE('d', double, doubleValue)
        JP_BLOCK_RET_CASE('B', BOOL, boolValue)

        case '@':
        case '#': {
            id retObj = result;
            void **retPtrPtr = ret;
            *retPtrPtr = (__bridge void *)retObj;
            break;
        }
    }
    
}

static const char *__BlockSignature__(id blockObj)
{
    struct JPSimulateBlock *block = (__bridge void *)blockObj;
    struct JPSimulateBlockDescriptor *descriptor = block->descriptor;
    assert(block->flags & BLOCK_HAS_SIGNATURE);
    return descriptor->signature;
}


@implementation OCBlockWrapper

+ (instancetype)blockWrapperWithNode:(OCBlockNode *)node
{
    OCBlockWrapper *wrapper = [[OCBlockWrapper alloc] init];
    wrapper.signature = [[OCMethodSignature alloc] initWithBlockTypeNames:node.typeNames];
    wrapper.node = node.children[0];
    wrapper.varableNames = node.paramNames;
    return wrapper;
}


- (void *)blockPtrWithCtx:(NSDictionary *)ctx
{
    if (_generatedPtr) {
        return _blockPtr;
    }
    
    _ctx = ctx;
    _generatedPtr = YES;
    
    ffi_type *returnType = [OCMethodSignature ffiTypeWithEncodingChar:[self.signature.returnType UTF8String]];
    
    NSUInteger argumentCount = self.signature.argumentTypes.count;
    
    _cifPtr = malloc(sizeof(ffi_cif));
    
    void *blockImp = NULL;
    
    _args = malloc(sizeof(ffi_type *) *argumentCount) ;
    
    for (int i = 0; i < argumentCount; i++){
        ffi_type* current_ffi_type = [OCMethodSignature ffiTypeWithEncodingChar:[self.signature.argumentTypes[i] UTF8String]];
        _args[i] = current_ffi_type;
    }
    
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&blockImp);
    
    if(ffi_prep_cif(_cifPtr, FFI_DEFAULT_ABI, (unsigned int)argumentCount, returnType, _args) == FFI_OK) {
        if (ffi_prep_closure_loc(_closure, _cifPtr, JPBlockInterpreter, (__bridge void *)self, blockImp) != FFI_OK) {
            NSAssert(NO, @"generate block error");
        }
    }

    struct JPSimulateBlockDescriptor descriptor = {
        0,
        sizeof(struct JPSimulateBlock),
        (void (*)(void *dst, const void *src))copy_helper,
        (void (*)(const void *src))dispose_helper,
        [self.signature.types cStringUsingEncoding:NSASCIIStringEncoding]
    };
    
    _descriptor = malloc(sizeof(struct JPSimulateBlockDescriptor));
    memcpy(_descriptor, &descriptor, sizeof(struct JPSimulateBlockDescriptor));

    struct JPSimulateBlock simulateBlock = {
        &_NSConcreteStackBlock,
        (BLOCK_HAS_COPY_DISPOSE | BLOCK_HAS_SIGNATURE),
        0,
        blockImp,
        _descriptor,
        (__bridge void*)self
    };

    _blockPtr = Block_copy(&simulateBlock);
    return _blockPtr;
}

+ (id)excuteBlock:(id)block withParams:(NSArray *)params
{
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:__BlockSignature__(block)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.target = block;
    return [OCMethodNode invokeWithInvocation:invocation argments:params];
}

- (void)dealloc
{
    ffi_closure_free(_closure);
    free(_args);
    free(_cifPtr);
    free(_descriptor);
    return;
}

@end
