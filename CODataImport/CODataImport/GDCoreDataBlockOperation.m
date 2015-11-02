//
//  GDCoreDataBlockOperation.m
//  ClickChat
//
//  Created by Gia on 8/4/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import "GDCoreDataBlockOperation.h"

@implementation GDCoreDataBlockOperation


- (void)addExecutionBlock:(void (^)(void))block {
    GDCoreDataBlockOperation __weak *ws = self;
    [super addExecutionBlock:^{
        if (block) {
            CLSNSLog(@"--start-- %@",ws);
            block();
        }
        CLSNSLog(@"--end---- %@",ws);

        void (^completionBlockWithResults)(NSArray *results) = ws.completionBlockWithResults;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlockWithResults) {
                completionBlockWithResults(nil);
            }
        });
    }];
}

@end
