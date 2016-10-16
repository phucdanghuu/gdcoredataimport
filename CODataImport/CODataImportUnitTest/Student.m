//
//  Student.m
//  CODataImport
//
//  Created by Tran Kien on 1/14/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import "Student.h"

@implementation Student

// Insert code here to add functionality to your managed object subclass
//- (BOOL)isEqual:(Student *)object {
//    return [self.id isEqual:object.id] && [self.name isEqual:object.name];
//}
+ (NSString *)primaryKey {
    return @"id";
}
@end
