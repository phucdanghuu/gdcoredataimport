//
//  GDCoreDataImportOperation.h
//  FlashCard
//
//  Created by Gia on 4/23/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CODataImport.h"


/**
 *  Did notification will be posted if saveToPersistenStore has any problems
 */
extern NSString *kCOCoreDataImportOperationDidCatchErrorWhenSaveToPersistionStore;


@interface COCoreDataImportOperation : NSOperation

@property (nonatomic, strong, readonly) NSArray *results;
@property (nonatomic, assign) BOOL shouldNotSaveToPersistentStore;
@property (nonatomic) BOOL willCleanupEverything;

@property (nonatomic, copy) void (^completionBlockWithResults)(NSArray *results);

- (id)initWithClass:(Class)class array:(NSArray *)array;
- (id)initWithClass:(Class)class dictionary:(NSDictionary *)dictionary;
// to create new object without id (so that we will wait for the id to arrive later
- (id)initNoIdObjectWithClass:(Class)class dictionary:(NSDictionary *)dictionary;
- (id)initNoIdObjectWithClass:(Class)class array:(NSArray *)array;

- (id)initWithClass:(Class)class array:(NSArray *)array willCleanupEverything:(BOOL)willCleanupEverything;
- (id)initWithClass:(Class)class array:(NSArray *)array isCleanAndCreate:(BOOL)isCleanAndCreate;
- (id)importNoIdObjectOfClass:(Class)class fromArray:(NSArray *)array;

// merge a context with the default context
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)willReturnCompletionBlockWithMainThreadObjects:(BOOL)willReturnCompletionBlockWithMainThreadObjects;



+ (NSArray *)objsInContext:(NSManagedObjectContext *)context fromMainThreadObjs:(NSArray *)objs;
+ (NSString *)defaultDateFormat;
+ (void) setDefaultDateFormat:(NSString *)dateFormat;

+ (NSString *)stringFromDate:(NSDate *)date formatDate:(NSString *)dateFormat;
+ (NSDate *)dateFromString:(NSString *)dateString formatDate:(NSString *)dateFormat;

+ (id)mapping;

@end



@interface COCoreDataMapping : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *destinationKey;

@end
