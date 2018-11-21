//
//  OCNode.h
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTokenReader.h"

#define EXCUTE(node,ctx)         id result = [node excuteWithCtx:ctx];\
if (result) {\
    return result;\
}

@interface OCNode : NSObject

@property (nonatomic,strong) OCTokenReader *reader;
@property (nonatomic,assign,getter=isFinished) BOOL finished;

- (instancetype)initWithReader:(OCTokenReader *)reader;

- (void)read;

- (void)addChild:(OCNode *)node;
- (void)replaceLastChild:(OCNode *)node;

- (NSArray *)children;

- (id)excuteWithCtx:(NSDictionary *)ctx;

@end

@interface OCSimpleNode : OCNode

@property (nonatomic,strong) OCToken *token;

@end

@interface OCSymbolNode : OCSimpleNode

@end
