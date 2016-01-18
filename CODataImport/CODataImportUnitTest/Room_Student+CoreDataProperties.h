//
//  Room_Student+CoreDataProperties.h
//  CODataImport
//
//  Created by Tran Kien on 1/18/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Room_Student.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room_Student (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *room_id;
@property (nullable, nonatomic, retain) NSNumber *student_id;
@property (nullable, nonatomic, retain) Room *room;
@property (nullable, nonatomic, retain) Student *student;

@end

NS_ASSUME_NONNULL_END
