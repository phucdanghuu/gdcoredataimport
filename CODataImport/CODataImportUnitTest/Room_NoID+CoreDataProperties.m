//
//  Room_NoID+CoreDataProperties.m
//  CODataImport
//
//  Created by Tran Kien on 10/16/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import "Room_NoID+CoreDataProperties.h"

@implementation Room_NoID (CoreDataProperties)

+ (NSFetchRequest<Room_NoID *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Room_NoID"];
}

@dynamic name;
@dynamic room_id;

@end
