//
//  UnitTestCoreDataQueue.m
//  CODataImport
//
//  Created by Tran Kien on 1/14/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import "UnitTestCoreDataQueue.h"

@interface UnitTestCoreDataQueue ()

@end

@implementation UnitTestCoreDataQueue

+ (id) sharedQueue {
  static UnitTestCoreDataQueue *_sharedQueue = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedQueue = [[UnitTestCoreDataQueue alloc] init];
  });

  return _sharedQueue;
}

- (instancetype)init {
  if (self = [super init]) {

//    self.queue = [[COCoreDataQueue alloc] init];
  }

  return self;
}
@end
