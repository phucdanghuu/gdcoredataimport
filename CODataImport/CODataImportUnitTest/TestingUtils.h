//
//  TestingUtils.h
//  CODataImport
//
//  Created by Tran Kien on 1/19/16.
//  Copyright © 2016 Tran Kien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestingUtils : NSObject
+ (void)setUpTestingDatabase;
+ (void)cleanUpTestingDatabase;
+ (NSString *) applicationDocumentsDirectory;
@end
