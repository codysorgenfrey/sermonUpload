//
//  SHCCBrain.m
//  Sermon Upload
//
//  Created by Cody Sorgenfrey on 10/29/13.
//  Copyright (c) 2013 South Hill Calvary Chapel. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "SHCCBrain.h"
#import "SHCCconstants.h"

@interface SHCCBrain ()

@end

@implementation SHCCBrain

-(id)init
{
    if (self = [super init]) {
        self.serverColumns = [NSMutableArray array];
    }
    return self;
}

-(NSMutableArray *) mutableStateWithSavedState:(NSArray *)rawState
{
    NSMutableArray *mutablePresetContents = [NSMutableArray array];
    for (int i=0; i<[rawState count]; i++) {
        [mutablePresetContents addObject:[[rawState objectAtIndex:i] mutableCopy]];
    }
    return mutablePresetContents;
}
- (void)pickLikelyDate: (NSDatePicker *)datePicker
                 withArray: (NSArray *)days{
    NSString *dateString = [@"last " stringByAppendingString:[days objectAtIndex:0]];
    NSDate *lattestDate = [NSDate dateWithNaturalLanguageString: dateString];
    for (int x=1; x<[days count]; x++) {
        NSString *date1String = [@"last " stringByAppendingString:[days objectAtIndex:x]];
        NSDate *date1 = [NSDate dateWithNaturalLanguageString: date1String];
        lattestDate = [lattestDate laterDate:date1];
    }
    [datePicker setDateValue:lattestDate];
}

-(NSString *)createFileNameForSermonType:(NSString *)type withBook:(NSString *)book atIndex:(NSInteger)indexOfBook withReference:(NSString *)reference withPreacher:(NSString *)preacher withDate:(NSDate *)date
{
    NSString *fileName;
    
    if ([type isEqualToString:@"Expositional"]) {
        NSString* capsBookName = [[[book stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:3] uppercaseString];
        NSRange range = [reference rangeOfString:@":"];
        NSArray* referenceComponents;
        
        if (range.location != NSNotFound) {
            referenceComponents = [reference componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":-"]];
        } else {
            referenceComponents = [NSArray arrayWithObjects:reference, @"1", nil];
        }
        
        fileName = [NSString stringWithFormat:@"%02ld-%@-%03ld-%03ld", (long)indexOfBook, capsBookName, [[referenceComponents objectAtIndex:0] integerValue], [[referenceComponents objectAtIndex:1] integerValue]];
    } else {
        NSDateFormatter *formattedDate = [[NSDateFormatter alloc] init];
        [formattedDate setDateFormat:@"Y-MM-dd"];
        NSArray *nameComponents = [preacher componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *preacherName = [nameComponents componentsJoinedByString:@""];
        fileName = [NSString stringWithFormat:@"%@-%@", [formattedDate stringFromDate:date], preacherName];
    }
    return fileName;
}

#pragma mark FTP Browser Functions

-(void)addNewColumnToCache
{
    [self.serverColumns addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@FALSE, KserverColumnIsLoaded, nil]];
}

-(void)resetColumnCache
{
    [self.serverColumns removeAllObjects];
}

-(BOOL)fileExists:(NSString *)fileOrFolderName inDirectoryListing:(NSArray *)directoryListing
{
    fileOrFolderName = [fileOrFolderName stringByDeletingPathExtension];
    
    for (NSDictionary *entry in directoryListing) {
        NSString *entryName = [[entry objectForKey:(id)kCFFTPResourceName] stringByDeletingPathExtension];
        if ([entryName isEqualToString: fileOrFolderName]) {
            return true;
        }
    }
    return false;
}

-(void)sortServerColumns: (NSInteger)showFoldersAboveFiles
{
    for (NSInteger column = 0; column < [self.serverColumns count]; column++) {
        NSArray *array = [[self.serverColumns objectAtIndex:column] objectForKey:KserverColumnDirectoryEntries];
        array = [array sortedArrayUsingComparator: ^(NSDictionary *obj1, NSDictionary *obj2) {
            NSString *str1 = [obj1 objectForKey:(id)kCFFTPResourceName];
            NSString *str2 = [obj2 objectForKey:(id)kCFFTPResourceName];
            return [str1 caseInsensitiveCompare:str2];
        }];
        if (showFoldersAboveFiles == NSOnState) {
            array = [array sortedArrayUsingComparator: ^(NSDictionary *obj1, NSDictionary *obj2) {
                NSNumber *num1 = [obj1 objectForKey:(id)kCFFTPResourceType];
                NSNumber *num2 = [obj2 objectForKey:(id)kCFFTPResourceType];
                return [num1 compare:num2];
            }];
        }
        if ([array isNotEqualTo:nil]) {
            [[self.serverColumns objectAtIndex:column] setObject:array forKey:KserverColumnDirectoryEntries];
        }
    }
}

-(id)runScript:(NSString *)pathToScript withParameters:(NSArray *)parameters
{
    //script arguments (in order): localPathToRawFile, localPathToWorkspace, sermonFileName, sermonTitle, sermonPreacher, sermonBook, sermonCount
    
    NSURL *url = [NSURL fileURLWithPath:pathToScript];
    NSDictionary *errors = [[NSDictionary alloc] init];
    if (url) {
        NSAppleScript *myScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
        if (myScript) {
            NSAppleEventDescriptor *scriptParameters = [NSAppleEventDescriptor listDescriptor];
            for (NSInteger i=0; i<[parameters count]; i++) {
                [scriptParameters insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[parameters objectAtIndex:i]] atIndex:i];
            }
            
            ProcessSerialNumber psn = {0, kCurrentProcess};
            NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(psn)];
            
            NSAppleEventDescriptor *handler = [NSAppleEventDescriptor descriptorWithString:[@"do_script" lowercaseString]];
            
            NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
                                                                                     eventID:kASSubroutineEvent
                                                                            targetDescriptor:target
                                                                                    returnID:kAutoGenerateReturnID
                                                                               transactionID:kAnyTransactionID];
            [event setParamDescriptor:handler forKeyword:keyASSubroutineName];
            [event setParamDescriptor:scriptParameters forKeyword:keyDirectObject];
            
            NSAppleEventDescriptor *reply = [myScript executeAppleEvent:event error:&errors];
            
            if ([errors count] == 0) {
                return [reply stringValue];
            }
        }
    }
    return nil;
}








@end