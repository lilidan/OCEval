//
//  FuntionSearch.h
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/23.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#ifndef FuntionSearch_h
#define FuntionSearch_h

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus
    

    struct Function {
        const char *name;
        void **pointer;
    };

    int find_function(struct Function functions[], size_t fcuntion_nel);

    
#ifdef __cplusplus
}
#endif //__cplusplus
#endif //fishhook_h
