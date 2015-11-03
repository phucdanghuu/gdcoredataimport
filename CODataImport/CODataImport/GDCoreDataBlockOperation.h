//
//  GDCoreDataBlockOperation.h
//  ClickChat
//
//  Created by Gia on 8/4/14.
//  Copyright (c) 2014 cogini. All rights reserved.
// version 0.2

#import <Foundation/Foundation.h>

@interface GDCoreDataBlockOperation : NSBlockOperation

@property (nonatomic, copy) void (^completionBlockWithResults)(NSArray *results);

- (void)addExecutionBlock:(void (^)(void))block;


@end
