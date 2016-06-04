//
//  CODataImportUnitTest.m
//  CODataImportUnitTest
//
//  Created by Tran Kien on 1/14/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CODataImport.h"
#import "UnitTestCoreDataQueue.h"
#import "Student.h"
#import "Room.h"
#import "Room_Student.h"
#import "TestingUtils.h"

@interface CODataImportUnitTest : XCTestCase

@end

@implementation CODataImportUnitTest


- (void)setUp {
  [super setUp];
  [TestingUtils setUpTestingDatabase];
}




- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  [TestingUtils cleanUpTestingDatabase];
}

- (void)testExample {
  // This is an example of a functional test case.
  // Use XCTAssert and related functions to verify your tests produce the correct results.
}


/**
 *  Test case: Import array items, have distinct primary key values and without set default primary key for class Student
 */
- (void)testImportArrayStudentDataWithDistinctPrimaryKeyValues{


  NSDictionary *dic  = [self studentsDictionary];

  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Student class] array:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 2);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }

}

- (NSDictionary *)studentsDictionary {
  NSDictionary *dic  = @{
                         @"data": @[
                             @{
                               @"id"     : @1,
                               @"name"   : @"name 1",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               },
                             @{
                               @"id"     : @2,
                               @"name"   : @"name 2",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               }

                             ]
                         };
  return dic;
}

/**
 *  Test case: Import array items, have distinct primary key values
 */

- (void)testImportArrayRoomDataWithDistinctPrimaryKeyValues {

  NSDictionary *dic  = @{
                         @"data": @[
                             @{
                               @"room_id"     : @"1",
                               @"name"   : @"name 1",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               },
                             @{
                               @"room_id"     : @"2",
                               @"name"   : @"name 2",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               }

                             ]
                         };


  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Room class] array:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 2);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }
}

/**
 * Test case: Import Student array items with have the same primary key value
 */

- (void)testImportArrayStudentDataWithoutDistinctPrimaryKeyValues {

  NSDictionary *dic  = @{
                         @"data": @[
                             @{
                               @"id"     : @1,
                               @"name"   : @"name 1",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               },
                             @{
                               @"id"     : @1,
                               @"name"   : @"name 2",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               }

                             ]
                         };


  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Student class] array:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 2);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }
}

/**
 * Test case: Import Student array items with have the same primary key value
 */

- (void)testImportArrayStudentDataWithoutDistinctPrimaryKeyValuesAndOneObjectHasInsertedBefore {

    NSDictionary *dic  = @{
                           @"data": @[
                                   @{
                                       @"id"     : @1,
                                       @"name"   : @"name 1",
                                       @"create_date"  : @"1990-12-30T12:00:00+07:00"
                                       },
                                   @{
                                       @"id"     : @1,
                                       @"name"   : @"name 2",
                                       @"create_date"  : @"1990-12-30T12:00:00+07:00"
                                       }

                                   ]
                           };

    Student *student = [Student MR_createEntity];
    student.id = [dic[@"data"] firstObject][@"id"];
    [student.managedObjectContext MR_saveOnlySelfAndWait];

    // Set the flag to YES
    __block BOOL waitingForBlock = YES;

    static BOOL done = NO;

    COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Student class] array:dic[@"data"]];

    operation.completionBlockWithResults = ^(NSArray *results) {


        XCTAssertEqual(results.count, 2);
        XCTAssertEqual(results[0], results[1]);
        done = YES;

    };


    [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        
        if (done) {
            break;
        }
    }
}

/**
 * Test case: Import Student array items with have the same primary key value
 */

- (void)testImportArrayRoomDataWithoutDistinctPrimaryKeyValues {

  NSDictionary *dic  = @{
                         @"data": @[
                             @{
                               @"room_id"     : @"1",
                               @"name"   : @"name 1",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               },
                             @{
                               @"room_id"     : @"1",
                               @"name"   : @"name 2",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               }

                             ]
                         };



  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Room class] array:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {

    XCTAssertEqual(results.count, 2);
    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }
}

/**
 * Test case: Import Student array items with have the same primary key value
 */

- (void)testImportEmptyArrayOfStudentData {

  NSDictionary *dic  = @{
                         @"data": @[
                             ]
                         };


  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Student class] array:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 0);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }
}

/**
 * Test case: Import Student array items with have the same primary key value
 */

- (void)testImportEmptyArrayOfRoomData {

  NSDictionary *dic  = @{
                         @"data": @[
                             ]
                         };



  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Room class] array:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {

    XCTAssertEqual(results.count, 0);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }
}

- (void)testImportArrayRoomDataWithCleanUp {

  NSDictionary *dic1  = @{
                          @"data": @[
                              @{
                                @"room_id"     : @"1",
                                @"name"   : @"name 1",
                                @"create_date"  : @"1990-12-30T12:00:00+07:00"
                                },
                              @{
                                @"room_id"     : @"1",
                                @"name"   : @"name 2",
                                @"create_date"  : @"1990-12-30T12:00:00+07:00"
                                }

                              ]
                          };


  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Room class] array:dic1[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 2);



    NSDictionary *dic2  = @{
                            @"data": @[
                                @{
                                  @"room_id"     : @"3",
                                  @"name"   : @"name 1",
                                  @"create_date"  : @"1990-12-30T12:00:00+07:00"
                                  },
                                @{
                                  @"room_id"     : @"4",
                                  @"name"   : @"name 2",
                                  @"create_date"  : @"1990-12-30T12:00:00+07:00"
                                  }

                                ]
                            };

    COCoreDataImportOperation *operation2 = [[COCoreDataImportOperation alloc] initWithClass:[Room class] array:dic2[@"data"]];


    operation2.willCleanupEverything = true;
    operation2.completionBlockWithResults = ^(NSArray *results) {
      XCTAssertEqual(results.count, 2);

      done = YES;

    };

    [[UnitTestCoreDataQueue sharedQueue] addOperation:operation2];



  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }
}

/**
 * Test case: Import Student array items with have the same primary key value
 */

- (void)testImportArrayRoomDataWithObjectsNoPrimaryKey {

  NSDictionary *dic  = @{
                         @"data":
                           @[@{
                               @"room_id"     : @"1",
                               @"student_id"   : @1
                               },
                             @{
                               @"room_id"     : @"1",
                               @"student_id"   : @1
                               }]
                         };


  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initNoIdObjectWithClass:[Room_Student class] array:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {

    XCTAssertEqual(results.count, 2);

    Room_Student *roomStudent1 = results.firstObject;
    Room_Student *roomStudent2 = results.lastObject;

    XCTAssertTrue(roomStudent1.student_id.integerValue == 1);
    XCTAssertTrue([roomStudent1.room_id isEqualToString:@"1"]);

    XCTAssertTrue(roomStudent2.student_id.integerValue == 1);
    XCTAssertTrue([roomStudent2.room_id isEqualToString:@"1"]);

    XCTAssertNotEqual(roomStudent1, roomStudent2);
    
    done = YES;
    
  };
  
  
  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];
  
  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    if (done) {
      break;
    }
  }
}

- (void)testImportStudentDictionaryWithDistinctPrimaryKeyValues {


  NSDictionary *dic  = @{
                         @"data":
                           @{
                             @"id"     : @1,
                             @"name"   : @"name 1",
                             @"create_date"  : @"1990-12-30T12:00:00+07:00"
                             }
                         };

  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Student class] dictionary:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 1);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }

}

- (void)testImportRoomDictionaryWithDistinctPrimaryKeyValues {

  NSDictionary *dic  = @{
                         @"data":                              @{
                               @"room_id"     : @"1",
                               @"name"   : @"name 1",
                               @"create_date"  : @"1990-12-30T12:00:00+07:00"
                               }
                         };


  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Room class] dictionary:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 1);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    if (done) {
      break;
    }
  }
}


- (void)testImportEmptyDicOfStudentData {

  NSDictionary *dic  = @{
                         @"data": @{}
                         };


  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Student class] dictionary:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {


    XCTAssertEqual(results.count, 1);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (done) {
      break;
    }
  }
}

/**
 * Test case: Import Student array items with have the same primary key value
 */

- (void)testImportEmptyDicOfRoomData {

  NSDictionary *dic  = @{
                         @"data": @{}
                         };



  // Set the flag to YES
  __block BOOL waitingForBlock = YES;

  static BOOL done = NO;

  COCoreDataImportOperation *operation = [[COCoreDataImportOperation alloc] initWithClass:[Room class] dictionary:dic[@"data"]];

  operation.completionBlockWithResults = ^(NSArray *results) {

    XCTAssertEqual(results.count, 1);

    done = YES;

  };


  [[UnitTestCoreDataQueue sharedQueue] addOperation:operation];

  while(waitingForBlock) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    if (done) {
      break;
    }
  }
}


- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
    // Put the code you want to measure the time of here.
  }];
}

@end
