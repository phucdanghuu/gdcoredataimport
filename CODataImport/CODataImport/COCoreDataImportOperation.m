//
//  GDCoreDataImportOperation.m
//  FlashCard
//
//  Created by Gia on 4/23/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import "COCoreDataImportOperation.h"

NSString *kCOCoreDataImportOperationDidCatchErrorWhenSaveToPersistionStore = @"kCOCoreDataImportOperationDidCatchErrorWhenSaveToPersistionStore";

@interface COCoreDataImportOperation ()

@property (nonatomic, strong) Class dataClass;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSDictionary *dictionary;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectContext *defaultContext;

@property (nonatomic, strong) NSArray *results;

//additional objects and relationship mapping
@property (nonatomic, strong) NSMutableDictionary *additionalDataDictionary;
@property (nonatomic, strong) NSMutableArray *relationshipArray;

@property (nonatomic) BOOL willReturnCompletionBlockWithMainThreadObjects;
@property (nonatomic) BOOL isCleanAndCreate;
@property (nonatomic) BOOL isNoId;

@property (nonatomic, strong) NSDate *date;
@property (atomic, assign)  BOOL waitingForBlock;

@end

@implementation COCoreDataImportOperation

- (id)init {
    self = [super init];
    if (self) {
        self.willReturnCompletionBlockWithMainThreadObjects = YES;
        self.willCleanupEverything = NO;
    }
    return self;
}

- (id)initWithClass:(Class)class {
    self = [self init];
    if (self) {
        self.dataClass = class;
    }
    return self;
}

- (id)initWithClass:(Class)class array:(NSArray *)array willCleanupEverything:(BOOL)willCleanupEverything {
    self = [self initWithClass:class array:array];
    if (self) {
        self.willCleanupEverything = willCleanupEverything;

        self.context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];
        [self.context setUndoManager:nil];

    }
    return self;
}

- (id)initWithClass:(Class)class array:(NSArray *)array {
    self = [self initWithClass:class];
    if (self) {
        self.array = array;

        self.context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];
        [self.context setUndoManager:nil];
    }
    return self;
}
- (id)initWithClass:(Class)class dictionary:(NSDictionary *)dictionary {
    self = [self initWithClass:class];
    if (self) {
        self.dictionary = dictionary;

        self.context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];
        [self.context setUndoManager:nil];
    }
    return self;
}

- (id)initNoIdObjectWithClass:(Class)class dictionary:(NSDictionary *)dictionary {
    self = [self initWithClass:class dictionary:dictionary];
    if (self) {
        self.isNoId = YES;
        self.context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];
        [self.context setUndoManager:nil];
    }
    return self;
}

- (id)initNoIdObjectWithClass:(Class)class array:(NSArray *)array {
    self = [self initWithClass:class array:array];

    if (self) {
        self.isNoId = YES;
        self.context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];
        [self.context setUndoManager:nil];
    }

    return self;
}

- (id)initWithClass:(Class)class array:(NSArray *)array isCleanAndCreate:(BOOL)isCleanAndCreate {
    self = [self initWithClass:class];
    if (self) {
        self.isCleanAndCreate = isCleanAndCreate;
        self.array = array;

        self.context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];
        [self.context setUndoManager:nil];
    }
    return self;
}


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    self = [self init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (id)initToSaveDefaultContext {
    self = [self init];
    if (self) {

    }
    return self;
}

- (void)main {
    @autoreleasepool {
        self.date = [NSDate date];
        GGCDLOG(@"--start-- %@",self);
        self.defaultContext = [NSManagedObjectContext MR_defaultContext];

        if (self.willCleanupEverything||self.isCleanAndCreate) {
            [self.dataClass MR_truncateAllInContext:self.context];
        }

        if (self.dataClass) {
            if (self.isCleanAndCreate) {
                self.results = [self createObjectsOfClass:self.dataClass fromArray:self.array];
            }else {

                if (self.isNoId) {
                    if(self.dictionary) {
                        self.results = @[[self importNoIdObjectOfClass:self.dataClass fromData:self.dictionary]];
                    } else if (self.array) {
                        self.results = [self importNoIdObjectOfClass:self.dataClass fromArray:self.array];
                    }
                }else {
                    if (self.array) {
                        self.results = [self importObjectsOfClass:self.dataClass fromArray:self.array];
                    }else if(self.dictionary) {
                        self.results = @[[self importObjectOfClass:self.dataClass fromData:self.dictionary]];
                    }
                }
            }

            if (!self.isCancelled) {
                NSDate *date = [NSDate date];
//                [self.context MR_saveToPersistentStoreAndWait];
                [self saveToPersistentStore:self.context];
                if (self.willReturnCompletionBlockWithMainThreadObjects) {
                    self.results = [self objsInMainThreadWithObjs:self.results];
                }
                GGCDLOG(@"save context with time %f",[[NSDate date] timeIntervalSinceDate:date]);
            }else {
                self.results = nil;
            }
        }else if (self.context) {
            // merge the context only
            if (!self.isCancelled) {
                NSDate *date = [NSDate date];
//                [self.context MR_saveToPersistentStoreAndWait];
                [self saveToPersistentStore:self.context];

                GGCDLOG(@"save context with time %f",[[NSDate date] timeIntervalSinceDate:date]);
            }
        }else {
            if (!self.isCancelled && self.shouldNotSaveToPersistentStore) {
                NSDate *date = [NSDate date];


//                [self.defaultContext MR_saveToPersistentStoreAndWait];
                [self saveToPersistentStore:self.defaultContext];

                GGCDLOG(@"save defaul context with time %f",[[NSDate date] timeIntervalSinceDate:date]);
            }
        }
    }
    GGCDLOG(@"--end---- %@",self);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isCancelled) {
            if (self.completionBlockWithResults) {

                if (self.willReturnCompletionBlockWithMainThreadObjects) {
                    self.completionBlockWithResults(self.results);
                }else {
                    self.completionBlockWithResults(nil);
                }
            }
        }
    });
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (self.isCancelled) {
            *stop =YES;
        }
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

- (NSArray *)createObjectsOfClass:(Class)class fromArray:(NSArray *)array {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:array.count];

    for (NSDictionary *data in array) {
        if (self.isCancelled) {
            break;
        }
        NSManagedObject *newObject = [class MR_createInContext:self.context];
        [self updateManagedObject:newObject withRecord:data];
        [results addObject:newObject];
    }

    return results;
}

- (NSArray *)importObjectsOfClass:(Class)class fromArray:(NSArray *)array {

    NSMutableArray *sortedResults = [NSMutableArray arrayWithCapacity:array.count];

    //create sort descriptor with ascending of pimary key
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:[COCoreDataImportOperation primaryKeyFromClass:class]
                                                                 ascending:YES];

    NSArray *sortedArray = nil;
    if (array != nil && array.count != 0) {
        sortedArray = [array sortedArrayUsingDescriptors:@[descriptor]];

        //Array of primary key
        NSArray *ids = [sortedArray valueForKey:[COCoreDataImportOperation primaryKeyFromClass:class]];

        //Managed Object Context Object in database with ids
        NSArray *objectWithIds = [self managedObjectsForClass:class inArrayOfIds:ids];

        NSString *primaryKey = [COCoreDataImportOperation primaryKeyFromClass:class];

        NSInteger objectCounter = 0;
        for (NSDictionary *data in sortedArray) {
            if (self.isCancelled) {
                break;
            }

            //The value of primary key
            id valueOfPrimaryKey = [data valueForKey:primaryKey];
            BOOL willCreate = NO;

            if (objectCounter < objectWithIds.count) {
                NSManagedObject *object = objectWithIds[objectCounter];

                if ([object isDeleted]) {
                    GGCDLOG(@"object %@ has been deleted", object);
                    willCreate = YES;
                } else {

                    if ([valueOfPrimaryKey isEqual:[object valueForKey:primaryKey]]) {
                        // do an update
                        [self updateManagedObject:object withRecord:data];
                        [sortedResults addObject:object];
                        objectCounter++;
                    }else {
                        willCreate = YES;
                    }
                }
            }else {
                willCreate = YES;
            }

            if (willCreate) {
                // create object with id objectId
                
                GGCDLOG(@"will create %@", data);
                NSManagedObject *newObject = [self importObjectOfClass:class fromData:data];
                [sortedResults addObject:newObject];
            }
        }
    }


    //load object with order by array
    NSMutableArray *results = [NSMutableArray array];

    for (NSDictionary *obj in array) {

        id primaryValue = [obj objectForKey:[COCoreDataImportOperation primaryKeyFromClass:class]];
        NSArray *objects = [self managedObjectsForClass:class inArrayOfIds:@[primaryValue]];

        if (objects) {
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:objects];

            // If the number of objects with primary key is greater than 1, removed all objects except the last object
            while (mutableArray.count > 1) {
                NSManagedObject *managedObject = mutableArray[0];
                [managedObject MR_deleteEntity];
                [mutableArray removeObjectAtIndex:0];
            }

            if (mutableArray.firstObject) {
                [results addObject:mutableArray.firstObject];
            }
        }
    }

    return results;
}

- (void)saveToPersistentStore:(NSManagedObjectContext *)context {
    
    self.waitingForBlock = YES;
    
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCOCoreDataImportOperationDidCatchErrorWhenSaveToPersistionStore object:error];
        }
        
        self.waitingForBlock = NO;
    }];
    
    while(self.waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
        
    }
    
}

/**
 *  Check the object existing in context by the value of primary key
 *  If existed, load the object and update new data
 *  if not existed, create new object in this context and update new date
 *
 *  @param class <#class description#>
 *  @param data  <#data description#>
 *
 *  @return <#return value description#>
 */
- (NSManagedObject *)importObjectOfClass:(Class)class fromData:(NSDictionary *)data {
    id objectId = [data valueForKey:[COCoreDataImportOperation primaryKeyFromClass:class]];

    NSManagedObject *object = nil;
    if (objectId != nil) {
        object = [class MR_findFirstByAttribute:[COCoreDataImportOperation primaryKeyFromClass:class]
                                      withValue:objectId
                                      inContext:self.context];
    }

    if (!object) {

        object = [class MR_createInContext:self.context];

        if (objectId) {
            //Set primary key
            [object setValue:objectId forKey:[COCoreDataImportOperation primaryKeyFromClass:class]];
        }

    }

    [self updateManagedObject:object withRecord:data];
    return object;
}
- (NSManagedObject *)importNoIdObjectOfClass:(Class)class fromData:(NSDictionary *)data {
    NSManagedObject *object = [class MR_createInContext:self.context];
    [self updateManagedObject:object withRecord:data];
    return object;
}

- (NSArray *)importNoIdObjectOfClass:(Class)class fromArray:(NSArray *)array {

    NSMutableArray *arrayOfObject = [NSMutableArray array];

    for (NSDictionary *data in array) {
        NSManagedObject *object = [class MR_createInContext:self.context];
        [self updateManagedObject:object withRecord:data];

        [arrayOfObject addObject:object];
    }

    return arrayOfObject;
}

- (NSArray *)objectsAfterAssignedIds:(NSArray *)ids forObjects:(NSArray *)objects {
    Class class = [objects[0] class];
    NSString *primaryId = [COCoreDataImportOperation primaryKeyFromClass:class];
    NSArray *alreadyAssignedIds = [[self managedObjectsForClass:class inArrayOfIds:ids] valueForKey:primaryId];

    NSMutableArray *willBeAssignedIds = [NSMutableArray arrayWithArray:ids];
    [willBeAssignedIds removeObjectsInArray:alreadyAssignedIds];

    for (id idObject in willBeAssignedIds) {
        if (self.isCancelled) {
            break;
        }
        NSUInteger index = [ids indexOfObject:idObject];
        if (index != NSNotFound && index < objects.count) {
            NSManagedObject *object = objects[index];
            [object setValue:idObject forKey:primaryId];
        }
    }
    return objects;
}

//this is use for all core data object, and there are condition for each class, so this is a bit hard code, but work so far, and easy to change
- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
    if (value == [NSNull null]) {
        return;
    }

    NSString *classNameOfAttribute = [COCoreDataImportOperation classNameOfAttribute:key object:managedObject];
    NSString *classNameOfRelationship = [COCoreDataImportOperation classNameOfRelationship:key object:managedObject];
    NSString *classNameOfMappingRelationship = [COCoreDataImportOperation classNameOfMappingRelationship:key object:managedObject];
    if (classNameOfRelationship.length != 0) {

        // relationship
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSManagedObject *object = [self importObjectOfClass:NSClassFromString(classNameOfRelationship) fromData:value];

            [managedObject setValue:object forKey:key];
        }else if([value isKindOfClass:[NSArray class]]) {
            NSSet *set = [NSSet setWithArray:[self importObjectsOfClass:NSClassFromString(classNameOfRelationship) fromArray:value]];

            [managedObject setValue:set forKey:key];

        }
    }else if (classNameOfMappingRelationship.length != 0) {
        NSDictionary *idDic = @{[COCoreDataImportOperation primaryKeyFromClass:NSClassFromString(classNameOfMappingRelationship)]: value};
        NSManagedObject *object = [self importObjectOfClass:NSClassFromString(classNameOfMappingRelationship) fromData:idDic];
        if (object) {
            [managedObject setValue:object forKey:[COCoreDataImportOperation destinationKeyFromMappingKey:key object:managedObject]];
        }
    }else if (classNameOfAttribute.length != 0) {
        if ([classNameOfAttribute isEqualToString:@"NSDate"]) {
            NSDate *date = [COCoreDataImportOperation dateFromString:value formatDate:[COCoreDataImportOperation defaultDateFormat]];
            [managedObject setValue:date forKey:key];
        }else if([classNameOfAttribute isEqualToString:@"NSNumber"]&&
                 ![value isEqual:[NSNull null]]) {
            NSNumber *number = nil;
            if ([value isKindOfClass:[NSNumber class]]) {
                number = value;
            }else if([value isKindOfClass:[NSString class]]) {
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                nf.numberStyle = NSNumberFormatterDecimalStyle;
                number = [nf numberFromString:value];
            }
            @try{
                [managedObject setValue:number forKey:key];
            }@catch(id anException) {
            }
        }else {
            if ([[managedObject.entity propertiesByName] objectForKey:key] != nil&&
                ![value isEqual:[NSNull null]]) {
                @try{
                    [managedObject setValue:value forKey:key];
                }@catch(id anException) {
                }
            }
        }
    }else {// transformable type
        if ([[managedObject.entity propertiesByName] objectForKey:key] != nil) {
            @try{
                [managedObject setValue:value forKey:key];
            }@catch(id anException) {
            }
        }
    }

}

- (void)addAdditionalObjectsArray:(NSArray *)dataArray forClass:(NSString *)className {
    if (!self.additionalDataDictionary) {
        self.additionalDataDictionary = [NSMutableDictionary dictionary];
    }
    NSMutableArray *array = [self.additionalDataDictionary valueForKey:className];
    if (!array) {
        array = [NSMutableArray array];
        [self.additionalDataDictionary setValue:array forKey:className];
    }
    [array addObjectsFromArray:dataArray];
}

- (void)addAdditionalObjectData:(NSDictionary *)data forClass:(NSString *)className {
    if (!self.additionalDataDictionary) {
        self.additionalDataDictionary = [NSMutableDictionary dictionary];
    }
    NSMutableArray *array = [self.additionalDataDictionary valueForKey:className];
    if (!array) {
        array = [NSMutableArray array];
        [self.additionalDataDictionary setValue:array forKey:className];
    }
    [array addObject:data];
}

#pragma mark - Config


- (void)willReturnCompletionBlockWithMainThreadObjects:(BOOL)willReturnCompletionBlockWithMainThreadObjects {
    self.willReturnCompletionBlockWithMainThreadObjects = willReturnCompletionBlockWithMainThreadObjects;
}
#pragma mark - Get Class Name

+ (NSString *)classNameOfAttribute:(NSString *)attributeName object:(NSManagedObject *)object {
    NSEntityDescription *enDes = object.entity;
    return [[[enDes attributesByName] valueForKey:attributeName] attributeValueClassName];
}

+ (NSString *)classNameOfRelationship:(NSString *)relationshipName object:(NSManagedObject *)object {
    NSEntityDescription *enDes = object.entity;
    return [[[[enDes relationshipsByName] valueForKey:relationshipName] destinationEntity] name];

}

+ (NSString *)destinationKeyFromMappingKey:(NSString *)key object:(NSManagedObject *)object {
    NSDictionary *mapping = [COCoreDataImportOperation additionalMappingFromClass:object.class];
    NSString *destinationKey = mapping[key];
    return destinationKey;
}

+ (NSString *)classNameOfMappingRelationship:(NSString *)key object:(NSManagedObject *)object {
    NSString *destinationKey = [COCoreDataImportOperation destinationKeyFromMappingKey:key object:object];
    if (destinationKey.length > 0) {
        return [self classNameOfRelationship:destinationKey object:object];
    }else {
        return nil;
    }
}

+ (BOOL)containKey:(NSString *)key object:(NSManagedObject *)object {
    NSEntityDescription *enDes = object.entity;
    return [[enDes attributesByName] valueForKey:key]||[[enDes relationshipsByName] valueForKey:key];
}

#pragma mark - Helper Method

- (NSArray *)objsInMainThreadWithObjs:(NSArray *)objs {
//    NSDate *date = [NSDate date];
    NSError *error;
    Class class = [objs.lastObject class];
    if ([self.context obtainPermanentIDsForObjects:objs error:&error]) {
        //        NSArray *newObjs = [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@", [objs valueForKey:@"objectID"]] inContext:self.defaultContext];

        NSMutableArray *results = [NSMutableArray array];

        for (NSManagedObject *obj in objs) {
            id primaryValue = [obj valueForKey:@"objectID"];

            NSArray *arr = [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self = %@", primaryValue] inContext:self.defaultContext];

            //            NSAssert([arr count] == 1, @"arr count must be equal 1");

            [results addObjectsFromArray:arr];

        }

        GGCDLOG(@"fetch main thread objs in %f",[[NSDate date] timeIntervalSinceDate:date]);
        return results;
    }else {
        GGCDLOG(@"%@",error);
    }

    return nil;
}

+ (NSArray *)objsInContext:(NSManagedObjectContext *)context fromMainThreadObjs:(NSArray *)objs {
    NSManagedObject *object = objs.lastObject;
    if (object.managedObjectContext != [NSManagedObjectContext MR_defaultContext]) {
        return nil;
    }
    Class class = [objs.lastObject class];
    return [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@", [objs valueForKey:@"objectID"]] inContext:context];
}

- (NSArray *)managedObjectsForClass:(Class)class inArrayOfIds:(NSArray *)idArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@",
                              [COCoreDataImportOperation primaryKeyFromClass:class],
                              idArray];
    NSArray *results = [class MR_findAllSortedBy:[COCoreDataImportOperation primaryKeyFromClass:class]
                                       ascending:YES
                                   withPredicate:predicate
                                       inContext:self.context];
    return results;
}

+ (NSString *)primaryKeyFromClass:(Class)class {
    if ([(NSObject *)class respondsToSelector:@selector(primaryKey)]) {
        return [(id)class primaryKey];
    }else {
        return [COCoreDataImportOperation primaryKey];
    }
}

+ (NSDictionary *)additionalMappingFromClass:(Class)class {
    if ([(NSObject *)class respondsToSelector:@selector(mapping)]) {
        return [(id)class mapping];
    }else {
        return nil;
    }
}

+ (NSString *)primaryKey {
    return @"id";
}

+ (id)mapping {
    return @{};
}

#pragma mark - Data Conversion

+ (NSString *)defaultDateFormat {

    return _dateFormat ? _dateFormat : @"yyyy-MM-dd'T'HH:mm:ssZZZ";

}


+ (NSString *)stringFromDate:(NSDate *)date formatDate:(NSString *)dateFormat {
    
    NSDateFormatter *formatter = [self dateFormatter];
//    formatter.locale = [NSLocale currentLocale];
//    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateFormat = dateFormat;
    return [formatter stringFromDate:date];
}


+ (NSDate *)dateFromString:(NSString *)dateString formatDate:(NSString *)dateFormat {
    NSDateFormatter *formatter = [self dateFormatter];
//    formatter.locale = [NSLocale currentLocale];
//    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateFormat = dateFormat;
    return [formatter dateFromString:dateString];
}

static NSString *_dateFormat = nil;

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *_dateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    return _dateFormatter;
}

+ (void) setDefaultDateFormat:(NSString *)dateFormat {
    
    _dateFormat = dateFormat;
}


@end
