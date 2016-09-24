//
//  SmallSample.m
//  CODataImport
//
//  Created by Tran Kien on 9/25/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MagicalRecord/MagicalRecord.h>
#import "CODataImport.h"
#import "UnitTestCoreDataQueue.h"
#import "Student.h"
#import "Room.h"
#import "Room_Student.h"
#import "TestingUtils.h"


@interface SmallSample : XCTestCase
@property (nonatomic) NSManagedObjectContext *testingContext;

@end

@implementation SmallSample

- (void)setUp {
    [super setUp];
    
    [TestingUtils setUpTestingDatabase];
    
    self.testingContext = [NSManagedObjectContext MR_defaultContext];
    
}




- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSManagedObjectContext *childContext = [NSManagedObjectContext MR_contextWithParent:self.testingContext];
    
    Student *student1 = [Student MR_createEntityInContext:self.testingContext];
    student1.id = @(1);
    
    Student *student2 = [Student MR_createEntityInContext:childContext];
    student2.id = @(2);
    
    NSArray *students = [Student MR_findAllInContext:childContext];
    
    for (Student *s in students) {
        NSLog(@"%@", s.id);

    }
    
    [childContext MR_saveOnlySelfAndWait];
    NSArray *studentsInParentContext = [Student MR_findAllInContext:self.testingContext];
    
    for (Student *s in studentsInParentContext) {
        NSLog(@"%@", s.id);
    
        s.id = @(s.id.integerValue + 10);
//        [s MR_deleteEntityInContext:self.testingContext];
//        [s MR_deleteEntity];
    }
    
//    [Student MR_truncateAll];
    
    [self.testingContext MR_saveToPersistentStoreAndWait];
    
    NSArray *studentsAfterDelete = [Student MR_findAllInContext:childContext];

    for (Student *s in studentsAfterDelete) {
        NSLog(@"%@", s.id);
        
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
