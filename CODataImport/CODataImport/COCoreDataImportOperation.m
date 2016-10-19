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


@interface CODefaultDateFormatter : NSObject<CODateFormatter>



@end

@implementation CODefaultDateFormatter


- (NSDate *)dateFromString:(NSString *)dateString {
    return [COCoreDataImportOperation dateFromString:dateString formatDate:[COCoreDataImportOperation defaultDateFormat]];
}

@end

@implementation NSDictionary (NSDictionaryConvertible)

- (NSDictionary *)asDictionary {
    return self;
}

@end

@interface COCoreDataImportOperation ()

@property (nonatomic, strong) Class dataClass;
@property (nonatomic, strong) NSArray<NSDictionary *> *array;
@property (nonatomic, strong) NSDictionary* dictionary;

@property (nonatomic, strong) NSManagedObjectContext *dataImportContext;

//@property (nonatomic, strong) NSArray *results;

//additional objects and relationship mapping
@property (nonatomic, strong) NSMutableDictionary *additionalDataDictionary;
@property (nonatomic, strong) NSMutableArray *relationshipArray;

@property (nonatomic) BOOL willReturnCompletionBlockWithObjectsInParentContext;
@property (nonatomic) BOOL isCleanAndCreate;
//@property (nonatomic) BOOL isNoId;

@property (nonatomic, copy) void (^completionBlockWithResults)(NSArray *results, NSError *error);
@property (nonatomic, copy) NSDictionary* (^customizedDataBeforeCreateOrUpdateAnManagedObjectBlock)(Class dataClass, NSDictionary *data);

@end

@implementation COCoreDataImportOperation

- (id<CODateFormatter>)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[CODefaultDateFormatter alloc] init];
    }
    
    return _dateFormatter;
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    
    if (self) {
        self.shouldSaveToPersistentStore = YES;
        self.willReturnCompletionBlockWithObjectsInParentContext = YES;
        self.willCleanupEverything = NO;
        
        self.dataImportContext = [self contextWithParentContext:context];
        
        self.dateFormatter = [[CODefaultDateFormatter alloc] init];
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

- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array context:(NSManagedObjectContext *)context {
    self = [self initWithClass:class context:context];
    if (self) {
        self.array = [self convertToArrayOfDictionary:array];
    }
    return self;
}

- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array context:(NSManagedObjectContext *)context willCleanupEverything:(BOOL)willCleanupEverything    {
    self = [self initWithClass:class array:array context:context];
    if (self) {
        self.willCleanupEverything = willCleanupEverything;
    }
    return self;
}

- (id)initWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary context:(NSManagedObjectContext *)context{
    self = [self initWithClass:class context:context];
    
    if (self) {
        self.dictionary = [dictionary asDictionary];
    }
    
    return self;
}

//- (id)initNoIdObjectWithContext:(NSManagedObjectContext *)context {
//    self = [self initWithContext:context];
//    
//    if (self) {
//        self.isNoId = YES;
//    }
//    
//    return self;
//}
//
//- (id)initNoIdObjectWithClass:(Class)class context:(NSManagedObjectContext *)context {
//    self = [self initNoIdObjectWithContext:context];
//    
//    if (self) {
//        self.dataClass = class;
//    }
//    
//    return self;
//}
//
//- (id)initNoIdObjectWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary context:(NSManagedObjectContext *)context {
//    self = [self initNoIdObjectWithClass:class context:context];
//    
//    if (self) {
//        self.dictionary = [dictionary asDictionary];
//
//    }
//    
//    return self;
//}
//- (id)initNoIdObjectWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array context:(NSManagedObjectContext *)context {
//    self = [self initNoIdObjectWithClass:class context:context];
//    
//    if (self) {
//      
//        
//        self.array = [self convertToArrayOfDictionary:array];
//        
//    }
//    
//    return self;
//}

    - (NSArray<NSDictionary *> *)convertToArrayOfDictionary:(NSArray<id<NSDictionaryConvertible>> *)array {
        NSMutableArray *arr = [NSMutableArray array];
        
        for (id<NSDictionaryConvertible> object in array) {
            [arr addObject:[object asDictionary]];
        }
        
        return arr;
    }
    
- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array context:(NSManagedObjectContext *)context isCleanAndCreate:(BOOL)isCleanAndCreate {
    self = [self initWithClass:class array:array context:context];
   
    if (self) {
        self.isCleanAndCreate = isCleanAndCreate;
    }
    
    return self;
}


/**
 Create a NSManagedObjectContext with parentContext.
 Note: If parentContext is nil, get defaultContext is [NSManagedObjectContext MR_rootSavingContext]

 @param parentContext <#parentContext description#>

 @return <#return value description#>
 */
- (NSManagedObjectContext *)contextWithParentContext:(NSManagedObjectContext *)parentContext {
    if (parentContext == nil) {
        parentContext = [NSManagedObjectContext MR_rootSavingContext];
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextWithParent:parentContext];
    [context setUndoManager:nil];
    [context setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
    
    return context;
}

- (BOOL)isNoId:(Class)class {
    return [COCoreDataImportOperation primaryKeyFromClass:class] == nil;
}

- (void)main {
    NSDate *startDate = [NSDate date];
    [COCoreDataImportOperation log:[NSString stringWithFormat:@"--start-- %@", self]];

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


    if (self.willCleanupEverything || self.isCleanAndCreate) {
        [self.dataClass MR_truncateAllInContext:self.dataImportContext];
    }


    NSArray<NSManagedObject *> *importedObjectInLocalContext;

    NSArray *results = nil;
    
    if (self.dataClass) {
        
        if ([self isNoId:self.dataClass]) {
            if(self.dictionary) {
                importedObjectInLocalContext = @[[self importNoIdObjectOfClass:self.dataClass fromData:self.dictionary shouldCustomizeData:YES]];
            } else if (self.array) {
                importedObjectInLocalContext = [self importNoIdObjectOfClass:self.dataClass fromArray:self.array];
            }
        }
        else {
            if (self.array) {
                importedObjectInLocalContext = [self importObjectsOfClass:self.dataClass fromArray:self.array];
            }else if(self.dictionary) {
                importedObjectInLocalContext = @[[self importObjectOfClass:self.dataClass fromData:self.dictionary shouldCustomizeData:YES]];
            }
        }
        
        if (!self.isCancelled) {
            
            if (self.completionBlockWithResults) {
                /**
                 *  Save data into persistentStore ore onlySelf
                 */
                if (self.shouldSaveToPersistentStore) {
                    [self.dataImportContext MR_saveToPersistentStoreAndWait];
                }
                else {
                    [self.dataImportContext MR_saveOnlySelfAndWait];
                }
                
                /**
                 * Return data by passing to block
                 **/
                if (self.willReturnCompletionBlockWithObjectsInParentContext && self.completionBlockWithResults) {
                    results = [self arrayOfManagedObjects:importedObjectInLocalContext
                                                inContext:self.dataImportContext.parentContext];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.completionBlockWithResults(results, nil);
                    });
                    
                }
                else {
                    results = nil;
                }
                
            } else {
                
                //To updated object to parent context
                [self.dataImportContext MR_saveToPersistentStoreAndWait];
            }
            
            [COCoreDataImportOperation log:[NSString stringWithFormat:@"save context with time %f",[[NSDate date] timeIntervalSinceDate:startDate]]];
            [COCoreDataImportOperation log:[NSString stringWithFormat:@"--end-- %@",self]];
            
        }
        else {
            [COCoreDataImportOperation log:[NSString stringWithFormat:@"--end-- because has been cancelled %@",self]];
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


- (void)setCustomizedDataBeforeCreateOrUpdateAnManagedObjectBlock:(NSDictionary *(^)(__unsafe_unretained Class, NSDictionary *))willCreateOrUpdateAnManagedObject {
    if (willCreateOrUpdateAnManagedObject) {
        _customizedDataBeforeCreateOrUpdateAnManagedObjectBlock = [willCreateOrUpdateAnManagedObject copy];
    } else {
        _customizedDataBeforeCreateOrUpdateAnManagedObjectBlock = nil;
    }
    
}
- (void)setCompletionBlockWithResults:(void (^)(NSArray *, NSError *))completionBlockWithResults {
    if (completionBlockWithResults) {
        _completionBlockWithResults = [completionBlockWithResults copy];
    } else {
        _completionBlockWithResults = nil;
    }
    
}


- (void)dealloc {
    [COCoreDataImportOperation log:[NSString stringWithFormat:@"dealloc operation %@",self]];
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (self.isCancelled) {
            *stop =YES;
        }
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

//- (NSArray<NSManagedObject *> *)createObjectsOfClass:(Class)class fromArray:(NSArray *)array {
//    NSMutableArray *results = [NSMutableArray arrayWithCapacity:array.count];
//
//    for (NSDictionary *data in array) {
//        if (self.isCancelled) {
//            break;
//        }
//        NSManagedObject *newObject = [class MR_createInContext:self.dataImportContext];
//        [self updateManagedObject:newObject withRecord:data];
//        [results addObject:newObject];
//    }
//
//    return results;
//}
- (NSArray<NSDictionary *> *)customizedArrayOfClass:(Class)class fromArray:(NSArray<NSDictionary *> *)array {
    NSMutableArray *customizedArray = [NSMutableArray arrayWithCapacity:array.count];
    
    if (self.customizedDataBeforeCreateOrUpdateAnManagedObjectBlock) {
        for (NSDictionary *dic in array) {
            NSDictionary *customizedDic = self.customizedDataBeforeCreateOrUpdateAnManagedObjectBlock(class, dic);
            
            [customizedArray addObject:customizedDic];
        }
        
        return [customizedArray copy];
    } else {
        return array;
    }

}

- (NSArray<NSManagedObject *> *)importObjectsOfClass:(Class)class fromArray:(NSArray<NSDictionary *> *)array {

    NSArray<NSDictionary *> *customizedArray = [self customizedArrayOfClass:class fromArray:array];
    
    NSMutableArray *sortedResults = [NSMutableArray arrayWithCapacity:customizedArray.count];

    //create sort descriptor with ascending of pimary key
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:[COCoreDataImportOperation primaryKeyFromClass:class]
                                                                 ascending:YES];

    NSArray *sortedArray = nil;
    if (customizedArray != nil && customizedArray.count != 0) {
        sortedArray = [customizedArray sortedArrayUsingDescriptors:@[descriptor]];

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
                    [COCoreDataImportOperation log:[NSString stringWithFormat:@"object %@ has been deleted", object]];

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
                [COCoreDataImportOperation log:[NSString stringWithFormat:@"will create %@", data]];

                NSManagedObject *newObject = [self importObjectOfClass:class fromData:data shouldCustomizeData:NO];
                [sortedResults addObject:newObject];
            }
        }
    }


    //load object with order by array
    NSMutableArray *results = [NSMutableArray array];

    for (NSDictionary *obj in customizedArray) {

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
- (NSManagedObject *)importObjectOfClass:(Class)class fromData:(NSDictionary *)data shouldCustomizeData:(BOOL)shouldCustomizeData {
    
    NSDictionary *updatedData = data;
    
    if (shouldCustomizeData && self.customizedDataBeforeCreateOrUpdateAnManagedObjectBlock) {
        updatedData = self.customizedDataBeforeCreateOrUpdateAnManagedObjectBlock(class, data);
    }
    
    id objectId = [updatedData valueForKey:[COCoreDataImportOperation primaryKeyFromClass:class]];

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

    [self updateManagedObject:object withRecord:updatedData];
    return object;
}
- (NSManagedObject *)importNoIdObjectOfClass:(Class)class fromData:(NSDictionary *)data shouldCustomizeData:(BOOL)shouldCustomizeData {
    NSDictionary *updatedData = data;
    
    if (shouldCustomizeData && self.customizedDataBeforeCreateOrUpdateAnManagedObjectBlock) {
        updatedData = self.customizedDataBeforeCreateOrUpdateAnManagedObjectBlock(class, data);
    }
    
    NSManagedObject *object = [class MR_createInContext:self.dataImportContext];
    [self updateManagedObject:object withRecord:updatedData];
    return object;
}

- (NSArray<NSManagedObject *> *)importNoIdObjectOfClass:(Class)class fromArray:(NSArray<NSDictionary *> *)array {

    NSArray<NSDictionary *> *customizedArray = [self customizedArrayOfClass:class fromArray:array];
    
    NSMutableArray *arrayOfObject = [NSMutableArray array];

    for (NSDictionary *data in customizedArray) {
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
            NSManagedObject *object = nil;
            Class class = NSClassFromString(classNameOfRelationship);

            if ([COCoreDataImportOperation primaryKeyFromClass:class] != nil) {
                object = [self importObjectOfClass:NSClassFromString(classNameOfRelationship) fromData:value shouldCustomizeData:YES];
                
            } else {
                object = [self importNoIdObjectOfClass:class fromData:value shouldCustomizeData:YES];
            }
            
            
            [managedObject setValue:object forKey:key];
        }else if([value isKindOfClass:[NSArray class]]) {
            Class class = NSClassFromString(classNameOfRelationship);
            
            NSArray *array = [NSArray array];
            if ([COCoreDataImportOperation primaryKeyFromClass:class] != nil) {
                array = [self importObjectsOfClass:class fromArray:value];
                
            } else {
                array = [self importNoIdObjectOfClass:class fromArray:value];
            }
            
            NSSet *set = [NSSet setWithArray:array];
            [managedObject setValue:set forKey:key];

        }
    }else if (classNameOfMappingRelationship.length != 0) {
        NSDictionary *idDic = @{[COCoreDataImportOperation primaryKeyFromClass:NSClassFromString(classNameOfMappingRelationship)]: value};
        NSManagedObject *object = [self importObjectOfClass:NSClassFromString(classNameOfMappingRelationship) fromData:idDic shouldCustomizeData:YES];
        if (object) {
            [managedObject setValue:object forKey:[COCoreDataImportOperation destinationKeyFromMappingKey:key object:managedObject]];
        }
    }else if (classNameOfAttribute.length != 0) {
        if ([classNameOfAttribute isEqualToString:@"NSDate"]) {
            NSDate *date = [self.dateFormatter dateFromString:value];
            [managedObject setValue:date forKey:key];
        }else if([classNameOfAttribute isEqualToString:@"NSNumber"] &&
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
    self.willReturnCompletionBlockWithObjectsInParentContext = willReturnCompletionBlockWithMainThreadObjects;
}

- (void)willReturnCompletionBlockWithObjectsInParentContext:(BOOL)willReturnCompletionBlockWithObjectsInParentContext {
    self.willReturnCompletionBlockWithObjectsInParentContext = willReturnCompletionBlockWithObjectsInParentContext;
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

        [COCoreDataImportOperation log:[NSString stringWithFormat:@"fetch main thread objs in %f",[[NSDate date] timeIntervalSinceDate:date]]];

        return results;
    } else {
        [COCoreDataImportOperation log:[NSString stringWithFormat:@"%@",error]];
    }

    return nil;
}

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
    return nil;
}

+ (id)mapping {
    return @{};
}

#pragma mark - Data Conversion

+ (NSString *)defaultDateFormat {

    return _dateFormat ? _dateFormat : @"yyyy-MM-dd'T'HH:mm:ssZZZ";

}


//+ (NSString *)stringFromDate:(NSDate *)date formatDate:(NSString *)dateFormat {
//
//    NSDateFormatter *formatter = [self dateFormatter];
//    //    formatter.locale = [NSLocale currentLocale];
//    //    formatter.timeZone = [NSTimeZone systemTimeZone];
//    formatter.dateFormat = dateFormat;
//    return [formatter stringFromDate:date];
//}


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

static BOOL showLog = YES;

+ (void)setShowLog:(BOOL)show {
    
    showLog = show;
}


+ (void)log:(NSString *)log {
    if (showLog) {
        NSLog(@"%@", log);
    }
}

@end

@implementation COCoreDataImportOperation (MR_defaultContext)

- (id)initWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary {
    self = [self initWithClass:class dictionary:dictionary context:DefaultContext];
    
    if (self) {
        
    }
    
    return self;
}
- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array {
    self = [self initWithClass:class array:array context:DefaultContext];
    
    if (self) {
        
    }
    
    return self;
}
//
//- (id)initNoIdObjectWithClass:(Class)class dictionary:(id<NSDictionaryConvertible>)dictionary {
//    self = [self initNoIdObjectWithClass:class dictionary:dictionary context:DefaultContext];
//    
//    if (self) {
//        
//    }
//    
//    return self;
//}
//// to create new object without id (so that we will wait for the id to arrive later
//- (id)initNoIdObjectWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array {
//    self = [self initNoIdObjectWithClass:class array:array context:DefaultContext];
//    
//    if (self) {
//        
//    }
//    
//    return self;
//}

// to create new object without id (so that we will wait for the id to arrive later
- (id)initWithClass:(Class)class array:(NSArray<id<NSDictionaryConvertible>> *)array willCleanupEverything:(BOOL)willCleanupEverything {
    self = [self initWithClass:class array:array context:DefaultContext willCleanupEverything:willCleanupEverything];
    
    if (self) {
        
    }
    
    return self;
}

@end
