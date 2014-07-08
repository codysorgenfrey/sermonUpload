//
//  SHCCBrain.h
//  Sermon Upload
//
//  Created by Cody Sorgenfrey on 10/29/13.
//  Copyright (c) 2013 South Hill Calvary Chapel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCCBrain : NSObject

@property NSMutableArray *serverColumns;

-(id)init;
-(NSMutableArray *) mutableStateWithSavedState:(NSArray *)rawState;
-(void)pickLikelyDate: (NSDatePicker *)datePicker withArray: (NSArray *)days;
-(NSString *)createFileNameForSermonType:(NSString *)type withBook:(NSString *)book atIndex:(NSInteger)indexOfBook withReference:(NSString *)reference withPreacher:(NSString *)preacher withDate:(NSDate *)date;

#pragma mark FTP Browser Functions

-(void)addNewColumnToCache;
-(void)resetColumnCache;
-(BOOL)fileExists:(NSString *)fileName inDirectoryListing:(NSArray *)directoryListing;
-(void)sortServerColumns:(NSInteger)showFoldersAboveFiles;
-(id)runScript:(NSString *)pathToScript withParameters:(NSArray *)parameters;

@end
