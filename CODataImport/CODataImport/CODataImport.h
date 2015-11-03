//
//  DataImport.h
//  DataImport
//
//  Created by Tran Kien on 10/1/15.
//  Copyright (c) 2015 Tran Kien. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for DataImport.
FOUNDATION_EXPORT double DataImportVersionNumber;

//! Project version string for DataImport.
FOUNDATION_EXPORT const unsigned char DataImportVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DataImport/PublicHeader.h>

#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>
#import "COCoreDataBlockOperation.h"
#import "COCoreDataImportOperation.h"
#import "COCoreDataQueue.h"


#define kIS_SHOW_ERROR NO


#ifdef CLSNSLog
  #define GGCDLOG(__FORMAT__, ...) CLSNSLog((@"%s line %d $ " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define GGCDLOG(__FORMAT__, ...) 
#endif


