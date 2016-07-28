//
//  TestingUtils.h
//  CODataImport
//
//  Created by Tran Kien on 1/19/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TestingUtils : NSObject
+ (void)setUpTestingDatabase;
+ (void)cleanUpTestingDatabase;
+ (NSString *) applicationDocumentsDirectory;
+ (BOOL)isObjsIsEqualToObjInPersistenstore:(NSArray<NSManagedObject *> *)objs matching:(BOOL(^)(NSManagedObject *obj1, NSManagedObject *obj2)) matching;
+ (NSArray *)arrayOfManagedObjects:(NSArray<NSManagedObject *> *)objs inContext:(NSManagedObjectContext *)context;

@end
