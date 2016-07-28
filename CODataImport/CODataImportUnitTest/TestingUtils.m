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


+ (void)setUpTestingDatabase {
  // Put setup code here. This method is called before the invocation of each test method in the class.

  NSLog(@"%@",[TestingUtils applicationDocumentsDirectory]);


  [MagicalRecord setDefaultModelFromClass:[self class]];

  [MagicalRecord setupCoreDataStackWithStoreNamed:@"test.sqlite"];

  [Student MR_truncateAll];
  [Room MR_truncateAll];

    NSLog(@"url %@",   [NSPersistentStore MR_defaultPersistentStore].URL.absoluteString);
  [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


+ (void)cleanUpTestingDatabase {
  [MagicalRecord cleanUp];
}

+ (NSString *) applicationDocumentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = paths.firstObject;
  return basePath;
}

+ (NSArray *)arrayOfManagedObjects:(NSArray<NSManagedObject *> *)objs inContext:(NSManagedObjectContext *)context{
    if (objs.count == 0) {
        return [NSArray array];
    }
    
    //    NSDate *date = [NSDate date];
    //    NSError *error;
    Class class = [objs.lastObject class];
    //    if ([self.dataImportContext obtainPermanentIDsForObjects:objs error:&error]) {
    //        NSArray *newObjs = [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@", [objs valueForKey:@"objectID"]] inContext:self.defaultContext];
    
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSManagedObject *obj in objs) {
        id primaryValue = [obj valueForKey:@"objectID"];
        
        NSArray *arr = [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self = %@", primaryValue] inContext:context];
        
        [results addObjectsFromArray:arr];
        
    }
    
    //        GGCDLOG(@"fetch main thread objs in %f",[[NSDate date] timeIntervalSinceDate:date]);
    return results;
    //    }else {
    //        GGCDLOG(@"%@",error);
    //    }
    
    //    return nil;
}

+ (BOOL)isObjsIsEqualToObjInPersistenstore:(NSArray<Student *> *)objs matching:(BOOL(^)(NSManagedObject *obj1, NSManagedObject *obj2)) matching {
    

    NSManagedObjectContext *newContext = [NSManagedObjectContext MR_rootSavingContext];
    
    NSArray *objsInPersistenStore = [self arrayOfManagedObjects:objs inContext:newContext];
    
    if (objs.count == objsInPersistenStore.count) {
        NSInteger count = objs.count;
        
        BOOL isEqual = YES;
        
        for (int i = 0; i < count; i++) {
//            Student *student = objs[i];
//            Student *studentInPersistentStore = objs[i];
            
            if (matching && matching(objs[i], objsInPersistenStore[i]) == YES) {
                
            } else {
                isEqual = NO;
            }
        }
        
        return isEqual;
    } else {
        return NO;
    }
    
    
}
@end
