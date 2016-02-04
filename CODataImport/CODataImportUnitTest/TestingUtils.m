//
//  TestingUtils.m
//  CODataImport
//
//  Created by Tran Kien on 1/19/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import "TestingUtils.h"
#import "CODataImport.h"
#import "UnitTestCoreDataQueue.h"
#import "Student.h"
#import "Room.h"
#import "Room_Student.h"

@implementation TestingUtils


- (void)setUpTestingDatabase {
  // Put setup code here. This method is called before the invocation of each test method in the class.

  NSLog(@"%@",[TestingUtils applicationDocumentsDirectory]);


  [MagicalRecord setDefaultModelFromClass:[self class]];

  [MagicalRecord setupCoreDataStackWithInMemoryStore];

  [Student MR_truncateAll];
  [Room MR_truncateAll];

  [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


- (void)cleanUpTestingDatabase {
  [MagicalRecord cleanUp];
}

+ (NSString *) applicationDocumentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = paths.firstObject;
  return basePath;
}
@end
