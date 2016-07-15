//
//  Student+CoreDataProperties.h
//  CODataImport
//
//  Created by Tran Kien on 1/18/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Student.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *name;

@property (nullable, nonatomic, retain) NSManagedObject *room;

@end

NS_ASSUME_NONNULL_END
