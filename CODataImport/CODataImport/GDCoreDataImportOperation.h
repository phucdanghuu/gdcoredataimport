//
//  GDCoreDataImportOperation.h
//  FlashCard
//
//  Created by Gia on 4/23/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>




@interface GDCoreDataImportOperation : NSOperation

@property (nonatomic, strong, readonly) NSArray *results;
@property (nonatomic, copy) void (^completionBlockWithResults)(NSArray *results);

- (id)initWithClass:(Class)class array:(NSArray *)array;
- (id)initWithClass:(Class)class dictionary:(NSDictionary *)dictionary;
// to create new object without id (so that we will wait for the id to arrive later
- (id)initNoIdObjectWithClass:(Class)class dictionary:(NSDictionary *)dictionary;
- (id)initWithClass:(Class)class array:(NSArray *)array willCleanupEverything:(BOOL)willCleanupEverything;
- (id)initWithClass:(Class)class array:(NSArray *)array isCleanAndCreate:(BOOL)isCleanAndCreate;

// merge a context with the default context
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)willReturnCompletionBlockWithMainThreadObjects:(BOOL)willReturnCompletionBlockWithMainThreadObjects;



+ (NSArray *)objsInContext:(NSManagedObjectContext *)context fromMainThreadObjs:(NSArray *)objs;
+ (NSString *)defaultDateFormat;
+ (NSString *)stringFromDate:(NSDate *)date formatDate:(NSString *)dateFormat;
+ (NSDate *)dateFromString:(NSString *)dateString formatDate:(NSString *)dateFormat;


@end



@interface GDCoreDataMapping : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *destinationKey;

@end
