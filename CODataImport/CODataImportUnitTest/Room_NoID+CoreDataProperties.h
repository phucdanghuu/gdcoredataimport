//
//  Room_NoID+CoreDataProperties.h
//  CODataImport
//
//  Created by Tran Kien on 10/16/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import "Room_NoID+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Room_NoID (CoreDataProperties)

+ (NSFetchRequest<Room_NoID *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *room_id;

@end

NS_ASSUME_NONNULL_END
