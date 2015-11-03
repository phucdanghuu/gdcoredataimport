//
//  GDCoreDataQueue.m
//  ClickChat
//
//  Created by Gia on 8/4/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import "COCoreDataQueue.h"

@implementation COCoreDataQueue

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"CoreDataQueue";
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

@end
