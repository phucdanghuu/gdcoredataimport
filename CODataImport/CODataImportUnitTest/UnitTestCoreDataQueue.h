//
//  UnitTestCoreDataQueue.h
//  CODataImport
//
//  Created by Tran Kien on 1/14/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "COCoreDataQueue.h"


@interface UnitTestCoreDataQueue : COCoreDataQueue
//@property (nonatomic, strong) COCoreDataQueue *queue;

+ (id) sharedQueue;
@end
