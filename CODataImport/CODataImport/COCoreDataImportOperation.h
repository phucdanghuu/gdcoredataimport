//
//  GDCoreDataImportOperation.h
//  FlashCard
//
//  Created by Gia on 4/23/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CODataImport.h"
#import <CoreData/CoreData.h>

/**
 *  Did notification will be posted if saveToPersistenStore has any problems
 */
extern NSString *kCOCoreDataImportOperationDidCatchErrorWhenSaveToPersistionStore;


@interface COCoreDataImportOperation : NSOperation

@property (nonatomic, strong, readonly) NSArray *results;

/**
 *  If shouldSaveToPersistentStore is NO, just save to MR_defaultContext. Else, save to persistent Store
 */
@property (nonatomic, assign) BOOL shouldSaveToPersistentStore;
@property (nonatomic) BOOL willCleanupEverything;
@property (nonatomic, copy) void (^completionBlockWithResults)(NSArray *results, NSError *error);


- (id)initWithClass:(Class)class dictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;
- (id)initWithClass:(Class)class array:(NSArray *)array context:(NSManagedObjectContext *)context;

- (id)initNoIdObjectWithClass:(Class)class dictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;
// to create new object without id (so that we will wait for the id to arrive later
- (id)initNoIdObjectWithClass:(Class)class array:(NSArray *)array context:(NSManagedObjectContext *)context;

// to create new object without id (so that we will wait for the id to arrive later
- (id)initWithClass:(Class)class array:(NSArray *)array context:(NSManagedObjectContext *)context
        willCleanupEverything:(BOOL)willCleanupEverything;

- (void)willReturnCompletionBlockWithMainThreadObjects:(BOOL)willReturnCompletionBlockWithMainThreadObjects __attribute__((deprecated("Should use function willReturnCompletionBlockWithObjectsInParentContext:")));

- (void)willReturnCompletionBlockWithObjectsInParentContext:(BOOL)willReturnCompletionBlockWithObjectsInParentContext;


+ (NSString *)defaultDateFormat;
+ (void) setDefaultDateFormat:(NSString *)dateFormat;

+ (NSString *)stringFromDate:(NSDate *)date formatDate:(NSString *)dateFormat;
+ (NSDate *)dateFromString:(NSString *)dateString formatDate:(NSString *)dateFormat;

+ (id)mapping;
+ (void)setShowLog:(BOOL)show;
@end



@interface COCoreDataImportOperation (MR_defaultContext)
- (id)initWithClass:(Class)class dictionary:(NSDictionary *)dictionary;
- (id)initWithClass:(Class)class array:(NSArray *)array;

- (id)initNoIdObjectWithClass:(Class)class dictionary:(NSDictionary *)dictionary;
// to create new object without id (so that we will wait for the id to arrive later
- (id)initNoIdObjectWithClass:(Class)class array:(NSArray *)array;

// to create new object without id (so that we will wait for the id to arrive later
- (id)initWithClass:(Class)class array:(NSArray *)array willCleanupEverything:(BOOL)willCleanupEverything;
@end

@interface COCoreDataMapping : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *destinationKey;

@end
