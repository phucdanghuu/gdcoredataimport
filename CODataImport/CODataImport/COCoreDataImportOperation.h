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

@protocol NSDictionaryConvertible <NSObject>

//- (void)setValue:(nullable id)value forKey:(NSString *)key;

- (NSDictionary *)asDictionary;

@end

@interface NSDictionary (NSDictionaryConvertible)<NSDictionaryConvertible>

@end


@protocol CODateFormatter <NSObject>

- (NSDate *)dateFromString:(NSString *)dateString;

@end



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

- (void)setCustomizedDataBeforeCreateOrUpdateAnManagedObjectBlock:(NSDictionary *(^)(__unsafe_unretained Class, NSDictionary *))customizedDataBeforeCreateOrUpdateAnManagedObjectBlock;
- (void)setCompletionBlockWithResults:(void (^)(NSArray *, NSError *))completionBlockWithResults;

- (id)initWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary context:(NSManagedObjectContext *)context;
- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array context:(NSManagedObjectContext *)context;

//- (id)initNoIdObjectWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary context:(NSManagedObjectContext *)context;
// to create new object without id (so that we will wait for the id to arrive later
//- (id)initNoIdObjectWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array context:(NSManagedObjectContext *)context;

// to create new object without id (so that we will wait for the id to arrive later
- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array context:(NSManagedObjectContext *)context
        willCleanupEverything:(BOOL)willCleanupEverything;

- (void)willReturnCompletionBlockWithMainThreadObjects:(BOOL)willReturnCompletionBlockWithMainThreadObjects __attribute__((deprecated("Should use function willReturnCompletionBlockWithObjectsInParentContext:")));

- (void)willReturnCompletionBlockWithObjectsInParentContext:(BOOL)willReturnCompletionBlockWithObjectsInParentContext;


+ (NSString *)defaultDateFormat;
+ (void) setDefaultDateFormat:(NSString *)dateFormat;

//+ (NSString *)stringFromDate:(NSDate *)date formatDate:(NSString *)dateFormat;
+ (NSDate *)dateFromString:(NSString *)dateString formatDate:(NSString *)dateFormat;

+ (id)mapping;
+ (void)setShowLog:(BOOL)show;
@end



@interface COCoreDataImportOperation (MR_defaultContext)
- (id)initWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary;
- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array;

//- (id)initNoIdObjectWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary;
// to create new object without id (so that we will wait for the id to arrive later
//- (id)initNoIdObjectWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array;

// to create new object without id (so that we will wait for the id to arrive later
- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array willCleanupEverything:(BOOL)willCleanupEverything;
@end

@interface COCoreDataMapping : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *destinationKey;

@end
