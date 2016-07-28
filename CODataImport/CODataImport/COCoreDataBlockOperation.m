//
//  GDCoreDataBlockOperation.m
//  ClickChat
//
//  Created by Gia on 8/4/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import "COCoreDataBlockOperation.h"

@implementation COCoreDataBlockOperation


- (void)addExecutionBlock:(void (^)(void))block {
    COCoreDataBlockOperation __weak *ws = self;
    [super addExecutionBlock:^{
        if (block) {
            //GGCDLOG(@"--start-- %@",ws);
            block();
        }
        //GGCDLOG(@"--end---- %@",ws);

        void (^completionBlockWithResults)(NSArray *results) = ws.completionBlockWithResults;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlockWithResults) {
                completionBlockWithResults(nil);
            }
        });
    }];
}

@end
