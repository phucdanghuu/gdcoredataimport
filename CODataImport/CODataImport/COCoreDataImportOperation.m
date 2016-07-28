//
//  GDCoreDataImportOperation.m
//  FlashCard
//
//  Created by Gia on 4/23/14.
//  Copyright (c) 2014 cogini. All rights reserved.
//

#import "COCoreDataImportOperation.h"

NSString *kCOCoreDataImportOperationDidCatchErrorWhenSaveToPersistionStore = @"kCOCoreDataImportOperationDidCatchErrorWhenSaveToPersistionStore";


#define DefaultContext [NSManagedObjectContext MR_defaultContext]

@interface COCoreDataImportOperation ()

@property (nonatomic, strong) Class dataClass;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSDictionary *dictionary;

@property (nonatomic, strong) NSManagedObjectContext *dataImportContext;
//@property (nonatomic, strong) NSManagedObjectContext *defaultContext;

@property (nonatomic, strong) NSArray *results;

//additional objects and relationship mapping
@property (nonatomic, strong) NSMutableDictionary *additionalDataDictionary;
@property (nonatomic, strong) NSMutableArray *relationshipArray;

@property (nonatomic) BOOL willReturnCompletionBlockWithMainThreadObjects;
@property (nonatomic) BOOL isCleanAndCreate;
@property (nonatomic) BOOL isNoId;

//@property (nonatomic, strong) NSDate *date;
//@property (atomic, assign)  BOOL waitingForBlock;

@end

@implementation COCoreDataImportOperation

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    
    if (self) {
        self.shouldSaveToPersistentStore = YES;
        self.willReturnCompletionBlockWithMainThreadObjects = YES;
        self.willCleanupEverything = NO;
        
        self.dataImportContext = [self contextWithParentContext:[NSManagedObjectContext MR_defaultContext]];
    }
    
    return self;
}

- (id)initWithClass:(Class)class context:(NSManagedObjectContext *)context {
    self = [self initWithContext:context];
    if (self) {
        self.dataClass = class;
    }
    return self;
}

- (id)initWithClass:(Class)class array:(NSArray *)array context:(NSManagedObjectContext *)context {
    self = [self initWithClass:class context:context];
    if (self) {
        self.array = array;
    }
    return self;
}

- (id)initWithClass:(Class)class array:(NSArray *)array context:(NSManagedObjectContext *)context willCleanupEverything:(BOOL)willCleanupEverything    {
    self = [self initWithClass:class array:array context:context];
    if (self) {
        self.willCleanupEverything = willCleanupEverything;



    }
    return self;
}

- (id)initWithClass:(Class)class dictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context{
    self = [self initWithClass:class context:context];
    
    if (self) {
        self.dictionary = dictionary;
    }
    
    return self;
}

- (id)initNoIdObjectWithContext:(NSManagedObjectContext *)context {
    self = [self initWithContext:context];
    if (self) {
        self.isNoId = YES;
    }
    return self;
}

- (id)initNoIdObjectWithClass:(Class)class context:(NSManagedObjectContext *)context {
    self = [self initNoIdObjectWithContext:context];
    if (self) {
        self.dataClass = class;
    }
    return self;
}

- (id)initNoIdObjectWithClass:(Class)class dictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
    self = [self initNoIdObjectWithClass:class context:context];
    if (self) {
        self.dictionary = dictionary;

    }
    return self;
}
- (id)initNoIdObjectWithClass:(Class)class array:(NSArray *)array context:(NSManagedObjectContext *)context {
    self = [self initNoIdObjectWithClass:class context:context];
    if (self) {
        self.array = array;
        
    }
    return self;
}

- (id)initWithClass:(Class)class array:(NSArray *)array context:(NSManagedObjectContext *)context isCleanAndCreate:(BOOL)isCleanAndCreate {
    self = [self initWithClass:class array:array context:context];
    if (self) {
        self.isCleanAndCreate = isCleanAndCreate;
//        self.array = array;
    }
    return self;
}

- (NSManagedObjectContext *)contextWithParentContext:(NSManagedObjectContext *)parentContext {
    if (parentContext == nil) {
        parentContext = [NSManagedObjectContext MR_rootSavingContext];
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextWithParent:parentContext];
    [context setUndoManager:nil];
    [context setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
    
    return context;
}

- (void)main {
    NSDate *startDate = [NSDate date];
    GGCDLOG(@"--start-- %@",self);
//    self.defaultContext = [NSManagedObjectContext MR_defaultContext];

    if (self.dataClass && [self.dataClass isSubclassOfClass:[NSManagedObject class]] == NO) {
        NSError *error = [NSError errorWithDomain:@"CODataImport"
                                             code:0x1
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Class must be an NSManagedObject"
                                                    }];

        if (self.completionBlockWithResults) {
            self.completionBlockWithResults(nil, error);
        }

        return;
    }


    if (self.willCleanupEverything||self.isCleanAndCreate) {
        [self.dataClass MR_truncateAllInContext:self.dataImportContext];
    }


    NSArray<NSManagedObject *> *importedObjectInLocalContext;

    if (self.dataClass) {
        if (self.isCleanAndCreate) {
            self.results = [self createObjectsOfClass:self.dataClass fromArray:self.array];
        }else {

            if (self.isNoId) {
                if(self.dictionary) {
                    importedObjectInLocalContext = @[[self importNoIdObjectOfClass:self.dataClass fromData:self.dictionary]];
                } else if (self.array) {
                    importedObjectInLocalContext = [self importNoIdObjectOfClass:self.dataClass fromArray:self.array];
                }
            }else {
                if (self.array) {
                    importedObjectInLocalContext = [self importObjectsOfClass:self.dataClass fromArray:self.array];
                }else if(self.dictionary) {
                    importedObjectInLocalContext = @[[self importObjectOfClass:self.dataClass fromData:self.dictionary]];
                }
            }
        }

        if (!self.isCancelled) {
            
            if (self.completionBlockWithResults) {
                /**
                 *  MR_saveToPersistentStoreWithCompletion will return on main thread
                 */
//                self.context MR_save
            
                if (self.shouldSaveToPersistentStore) {
                    [self.dataImportContext MR_saveToPersistentStoreAndWait];
                    //                    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
              
                } else {
                    [self.dataImportContext MR_saveOnlySelfAndWait];
//                    [self.context.parentContext MR_saveOnlySelfAndWait];
                }
                    if (self.willReturnCompletionBlockWithMainThreadObjects) {
                        self.results = [self arrayOfManagedObjects:importedObjectInLocalContext inContext:self.dataImportContext.parentContext];
                    } else {
                        self.results = nil;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.completionBlockWithResults(self.results, nil);
                    });
                    
                    //                    [self.context MR_saveOnlySelfWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    //                        if (self.willReturnCompletionBlockWithMainThreadObjects) {
                    //                            self.results = [self objsInMainThreadWithObjs:importedObjectInLocalContext];
                    //                        } else {
                    //                            self.results = nil;
                    //                        }
                    //                        
                    //                        self.completionBlockWithResults(self.results, error);
                    //                    }];
//                }
                
            } else {
                
                //To updated object to parent context
                [self.dataImportContext MR_saveToPersistentStoreAndWait];
            }
            
            GGCDLOG(@"save context with time %f",[[NSDate date] timeIntervalSinceDate:startDate]);
            GGCDLOG(@"--end-- %@",self);
            
        } else {
            self.results = nil;
        }
    }
}

- (void)setShouldSaveToPersistentStore:(BOOL)shouldSaveToPersistentStore {
    
    _shouldSaveToPersistentStore = shouldSaveToPersistentStore;
    
//    if (_shouldSaveToPersistentStore) {
//        
//    } else {
//        
//    }
}


- (void)dealloc {
    GGCDLOG(@"dealloc operation %@",self);

}
- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (self.isCancelled) {
            *stop =YES;
        }
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

- (NSArray<NSManagedObject *> *)createObjectsOfClass:(Class)class fromArray:(NSArray *)array {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:array.count];

    for (NSDictionary *data in array) {
        if (self.isCancelled) {
            break;
        }
        NSManagedObject *newObject = [class MR_createInContext:self.dataImportContext];
        [self updateManagedObject:newObject withRecord:data];
        [results addObject:newObject];
    }

    return results;
}

- (NSArray<NSManagedObject *> *)importObjectsOfClass:(Class)class fromArray:(NSArray *)array {

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

//- (void)save:(NSManagedObjectContext *)context block:(void(^)(NSError * _Nullable error)) block {
//
//    if (self.shouldSaveToPersistentStore) {
//
//        [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
//            block(error);
//        }];
//
//    } else {
//        [self.context MR_saveOnlySelfWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
//            block(error);
//        }];
//    }
//}

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
                                      inContext:self.dataImportContext];
    }

    if (!object) {

        object = [class MR_createInContext:self.dataImportContext];

        if (objectId) {
            //Set primary key
            [object setValue:objectId forKey:[COCoreDataImportOperation primaryKeyFromClass:class]];
        }

    }

    [self updateManagedObject:object withRecord:data];
    return object;
}
- (NSManagedObject *)importNoIdObjectOfClass:(Class)class fromData:(NSDictionary *)data {
    NSManagedObject *object = [class MR_createInContext:self.dataImportContext];
    [self updateManagedObject:object withRecord:data];
    return object;
}

- (NSArray<NSManagedObject *> *)importNoIdObjectOfClass:(Class)class fromArray:(NSArray *)array {

    NSMutableArray *arrayOfObject = [NSMutableArray array];

    for (NSDictionary *data in array) {
        NSManagedObject *object = [class MR_createInContext:self.dataImportContext];
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

- (NSArray *)arrayOfManagedObjects:(NSArray<NSManagedObject *> *)objs inContext:(NSManagedObjectContext *)context{
        NSDate *date = [NSDate date];
    NSError *error;
    Class class = [objs.lastObject class];
    if ([self.dataImportContext obtainPermanentIDsForObjects:objs error:&error]) {
        //        NSArray *newObjs = [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@", [objs valueForKey:@"objectID"]] inContext:self.defaultContext];

        NSMutableArray *results = [NSMutableArray array];

        for (NSManagedObject *obj in objs) {
            id primaryValue = [obj valueForKey:@"objectID"];

            NSArray *arr = [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self = %@", primaryValue] inContext:context];

            [results addObjectsFromArray:arr];

        }

        GGCDLOG(@"fetch main thread objs in %f",[[NSDate date] timeIntervalSinceDate:date]);
        return results;
    }else {
        GGCDLOG(@"%@",error);
    }

    return nil;
}

//+ (NSArray *)objsInContext:(NSManagedObjectContext *)context fromMainThreadObjs:(NSArray *)objs {
//    NSManagedObject *object = objs.lastObject;
//    if (object.managedObjectContext != [NSManagedObjectContext MR_defaultContext]) {
//        return nil;
//    }
//    Class class = [objs.lastObject class];
//    return [class MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@", [objs valueForKey:@"objectID"]] inContext:context];
//}

- (NSArray *)managedObjectsForClass:(Class)class inArrayOfIds:(NSArray *)idArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@",
                              [COCoreDataImportOperation primaryKeyFromClass:class],
                              idArray];
    NSArray *results = [class MR_findAllSortedBy:[COCoreDataImportOperation primaryKeyFromClass:class]
                                       ascending:YES
                                   withPredicate:predicate
                                       inContext:self.dataImportContext];
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

@implementation COCoreDataImportOperation (MR_defaultContext)

- (id)initWithClass:(Class)class dictionary:(NSDictionary *)dictionary {
    self = [self initWithClass:class dictionary:dictionary context:DefaultContext];
    
    if (self) {
        
    }
    
    return self;
}
- (id)initWithClass:(Class)class array:(NSArray *)array {
    self = [self initWithClass:class array:array context:DefaultContext];
    
    if (self) {
        
    }
    
    return self;
}

- (id)initNoIdObjectWithClass:(Class)class dictionary:(NSDictionary *)dictionary {
    self = [self initNoIdObjectWithClass:class dictionary:dictionary context:DefaultContext];
    
    if (self) {
        
    }
    
    return self;
}
// to create new object without id (so that we will wait for the id to arrive later
- (id)initNoIdObjectWithClass:(Class)class array:(NSArray *)array {
    self = [self initNoIdObjectWithClass:class array:array context:DefaultContext];
    
    if (self) {
        
    }
    
    return self;
}

// to create new object without id (so that we will wait for the id to arrive later
- (id)initWithClass:(Class)class array:(NSArray *)array willCleanupEverything:(BOOL)willCleanupEverything {
    self = [self initWithClass:class array:array context:DefaultContext willCleanupEverything:willCleanupEverything];
    
    if (self) {
        
    }
    
    return self;
}

@end
