//
//  SHCCAppDelegate.m
//  Sermon Upload
//
//  Created by Cody Sorgenfrey on 10/25/13.
//  Copyright (c) 2013 South Hill Calvary Chapel. All rights reserved.
//

#import "SHCCAppDelegate.h"
#import "SHCCconstants.h"
#import "SHCCBrain.h"
#import "FTPKit.h"

@interface SHCCAppDelegate () <NSBrowserDelegate>

@property SHCCBrain           *brain;
@property FTPKit              *ftpKit;
@property NSProgressIndicator *serverProgress;
@property NSString            *fileOnServer;

@end

@implementation SHCCAppDelegate

#pragma mark INSTANCE METHODS
-(id)init
{
    if (self = [super init]) {
        self.brain = [[SHCCBrain alloc] init];

        self.ftpKit = [[FTPKit alloc] init];
        [self.ftpKit setDelegate:(id)self];
        [self.ftpKit setErrorMethod:@selector(ftpKitDidEncounterError:)];
        self.serverProgress = [[NSProgressIndicator alloc] init];
        [self.serverProgress setStyle:NSProgressIndicatorSpinningStyle];
        [self.serverProgress setDisplayedWhenStopped:false];
    }
    return self;
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    BOOL previousStateExists = [[NSUserDefaults standardUserDefaults] boolForKey: KpreviousStateExists];
    if (!previousStateExists) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey: KpreviousStateExists];
        [self addNewPreset:nil];
        [self addNewServerPreset:nil];
        [self.typesArrayController addObjects: [NSMutableArray arrayWithObjects:
                      @"Expositional", @"Topical", @"Mans", @"Womens", @"Holiday", @"Marriage", @"Other", nil]];
        [self.servicesArrayController addObjects: [NSMutableArray arrayWithObjects:
                         @"Sunday", @"Wednesday", @"Saturday", @"Retreat", @"Breakfast", @"Jr High", @"High School", @"Other", nil]];
        [self.audioEditingScript selectItemAtIndex:0];
        [self.serverShowFoldersAboveFiles setState: NSOnState];
        [self.serverShowHiddenFiles setState:NSOffState];
        [self.deleteLocalFilesWhenDone setState: NSOffState];
    } else {
        [self.presetsArrayController addObjects: [self.brain mutableStateWithSavedState: [[NSUserDefaults standardUserDefaults] arrayForKey: KsavedPresets]]];
        [self.serversArrayController addObjects: [self.brain mutableStateWithSavedState: [[NSUserDefaults standardUserDefaults] arrayForKey: KsavedServers]]];
        [self.typesArrayController addObjects: [self.brain mutableStateWithSavedState: [[NSUserDefaults standardUserDefaults] arrayForKey: KsavedTypes]]];
        [self.servicesArrayController addObjects: [self.brain mutableStateWithSavedState: [[NSUserDefaults standardUserDefaults] arrayForKey: KsavedServices]]];
        [self.audioEditingScript selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey: KaudioEditingScript]];
        [self.customAppleScript setStringValue: [[NSUserDefaults standardUserDefaults] stringForKey: KcustomApplescript]];
        [self.deleteLocalFilesWhenDone setState: [[NSUserDefaults standardUserDefaults] integerForKey: KdeleteLocalFilesWhenDone]];
        [self.serverShowFoldersAboveFiles setState: [[NSUserDefaults standardUserDefaults] integerForKey: KserverShowFoldersAboveFiles]];
        [self.serverShowHiddenFiles setState: [[NSUserDefaults standardUserDefaults] integerForKey: KserverShowHiddenFiles]];
    }
    [self.bibleBooksArrayController addObjects: [NSArray arrayWithObjects:
                       @"", @"Genesis", @"Exodus", @"Leviticus", @"Numbers", @"Deuteronomy", @"Joshua",
                       @"Judges", @"Ruth", @"1 Samuel", @"2 Samuel", @"1 Kings", @"2 Kings",
                       @"1 Chronicles", @"2 Chronicles", @"Ezra", @"Nehemiah", @"Esther", @"Job",
                       @"Psalm", @"Proverbs", @"Ecclesiastes", @"Song of Solomon", @"Isaiah", @"Jeremiah",
                       @"Lamentations", @"Ezekiel", @"Daniel", @"Hosea", @"Joel", @"Amos", @"Obadiah",
                       @"Jonah", @"Micah", @"Nahum", @"Habakkuk", @"Zephaniah", @"Haggai",
                       @"Zechariah", @"Malachi", @"Matthew", @"Mark", @"Luke", @"John",
                       @"Acts", @"Romans", @"1 Corinthians", @"2 Corinthians", @"Galatians", @"Ephesians",
                       @"Philippians", @"Colossians", @"1 Thessalonians", @"2 Thessalonians", @"1 Timothy", @"2 Timothy",
                       @"Titus", @"Philemon", @"Hebrews", @"James", @"1 Peter", @"2 Peter",
                       @"1 John", @"2 John", @"3 John", @"Jude", @"Revelation", nil]];
    [self.presetsArrayController setSelectionIndex:0];
    [self.serversArrayController setSelectionIndex:0];
    [self.servicesArrayController setSelectionIndex:0];
    [self.typesArrayController setSelectionIndex:0];
    [self.datePicker setDateValue:[NSDate date]];
    [self serverLoginWithCurrentSettings];
    if ([self.serverShowHiddenFiles state] == NSOnState) {
        [self.ftpKit setDirectoryListingShowHiddenFiles: true];
    }
    [self.serverBrowser setDelegate:(id)self];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return TRUE;
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setObject:[self.presetsArrayController arrangedObjects] forKey: KsavedPresets];
    [[NSUserDefaults standardUserDefaults] setObject:[self.serversArrayController arrangedObjects] forKey: KsavedServers];
    [[NSUserDefaults standardUserDefaults] setObject:[self.servicesArrayController arrangedObjects] forKey: KsavedServices];
    [[NSUserDefaults standardUserDefaults] setObject:[self.typesArrayController arrangedObjects] forKey: KsavedTypes];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.audioEditingScript indexOfSelectedItem] forKey: KaudioEditingScript];
    [[NSUserDefaults standardUserDefaults] setObject:[self.customAppleScript stringValue] forKey: KcustomApplescript];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.deleteLocalFilesWhenDone state] forKey: KdeleteLocalFilesWhenDone];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.serverShowFoldersAboveFiles state] forKey:KserverShowFoldersAboveFiles];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.serverShowHiddenFiles state] forKey:KserverShowHiddenFiles];
}

- (IBAction)addNewServerPreset:(id)sender
{
    [self.serversArrayController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @"Test Server...", KserverPresetName,
                                            @"nssdcftp.gsfc.nasa.gov/", KserverPresetAddress,
                                            @"", KserverPresetMysqlAddress,
                                            @"", KserverPresetMysqlKey,
                                            @"", KserverPresetPassword,
                                            @"", KserverPresetUserName,
                                            nil]];
}

- (IBAction)removeServerPreset:(id)sender
{
    if ([[self.serversArrayController arrangedObjects] count] > 0) {
        [self.serversArrayController removeObjectAtArrangedObjectIndex:[self.serversArrayController selectionIndex]];
    }
}

- (IBAction)addNewPreset:(id)sender
{
    [self.presetsArrayController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @"New Preset...", KpresetName,
                                            [NSNumber numberWithInteger:0], KpresetServer,
                                            [NSNumber numberWithInteger:0], KpresetBook,
                                            @"/library/", KpresetServerLocation,
                                            @"Sunday", KpresetService,
                                            [NSArray arrayWithObject:@"sunday"], KpresetServiceDays,
                                            @"Expositional", KpresetType,
                                            @"John Appleseed", KpresetPreacher,
                                            @"0", kpresetSeriesID,
                                            nil]];
}

- (IBAction)removeExistingPreset:(id)sender
{
    if ([[self.presetsArrayController arrangedObjects] count] > 0) {
        [self.presetsArrayController removeObjectAtArrangedObjectIndex:[self.presetsArrayController selectionIndex]];
    }
}

- (IBAction)loadPreset:(NSPopUpButton *)sender
{
    NSMutableDictionary *selectedPreset = [[self.presetsArrayController arrangedObjects] objectAtIndex: sender.indexOfSelectedItem];
    [self.postServer selectItemAtIndex:[[selectedPreset objectForKey:KpresetServer] integerValue]];
    [self.postBook selectItemAtIndex:[[selectedPreset objectForKey:KpresetBook] integerValue]];
    self.postService.stringValue = [selectedPreset objectForKey:KpresetService] ? [selectedPreset objectForKey:KpresetService] : @"";
    self.postType.stringValue = [selectedPreset objectForKey:KpresetType] ? [selectedPreset objectForKey:KpresetType] : @"";
    self.postPreacher.stringValue = [selectedPreset objectForKey:KpresetPreacher] ? [selectedPreset objectForKey:KpresetPreacher] : @"";
    self.postSeriesID.stringValue = [selectedPreset objectForKey:kpresetSeriesID] ? [selectedPreset objectForKey:kpresetSeriesID] : @"";
    self.postServerLocation.stringValue = [selectedPreset objectForKey:KpresetServerLocation] ? [selectedPreset objectForKey:KpresetServerLocation] : @"";
    NSArray *likelyDates = [selectedPreset objectForKey:KpresetServiceDays];
    if ([likelyDates count] > 0){
        [self.brain pickLikelyDate:self.datePicker withArray:likelyDates];
    }
    [self serverChanged:sender];
}

- (IBAction)selectCustomScript:(id)sender
{
    NSOpenPanel *select = [[NSOpenPanel alloc] init];
    [select setAllowsMultipleSelection:false];
    [select setAllowedFileTypes:[NSArray arrayWithObject:@"applescript"]];
    
    if ([select runModal] == NSFileHandlingPanelOKButton) {
        [self.customAppleScript setStringValue:[[select URL] absoluteString]];
    }
}

- (IBAction)chooseRawFile:(NSButton *)sender
{
    NSOpenPanel* openDialog = [[NSOpenPanel alloc] init];
    [openDialog setCanChooseFiles:TRUE];
    [openDialog setCanCreateDirectories:FALSE];
    [openDialog setAllowsMultipleSelection:FALSE];
    [openDialog beginSheetModalForWindow:self.mainWindow completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            NSString* file = [[[openDialog URLs] objectAtIndex:0] path];
            [self.postRawLocation setStringValue:file];
        }
    }];
}

- (IBAction)postSermon:(id)sender
{
    NSString *pathToScript;
    
    [self.postProgress startAnimation:sender];
    
    NSString *sermonFileName = [self.brain createFileNameForSermonType:[self.postType stringValue]
                                                              withBook:[self.postBook titleOfSelectedItem]
                                                               atIndex:[self.postBook indexOfSelectedItem]
                                                         withReference:[self.postReference stringValue]
                                                          withPreacher:[self.postPreacher stringValue]
                                                              withDate:[self.datePicker dateValue]];
    
    NSString *serverFile = [[self.postServerLocation stringValue] stringByAppendingPathComponent:sermonFileName];
    
    NSArray *directoryListing = [self.ftpKit getDirectoryListingForPathSync:[serverFile stringByDeletingLastPathComponent]];
    
    BOOL exists = [self.brain fileExists:serverFile inDirectoryListing: directoryListing];
    if (exists) {
        while (exists) {
            serverFile = [serverFile stringByAppendingString:@"_copy"];
            exists = [self.brain fileExists:serverFile inDirectoryListing:[self.ftpKit getDirectoryListingForPathSync:[serverFile stringByDeletingLastPathComponent]]];
        }
    }
    
    if ([self.audioEditingScript indexOfSelectedItem] == 0) {
        pathToScript = [[NSBundle mainBundle] pathForResource:@"logicPro9" ofType:@"applescript"];
    } else if ([self.audioEditingScript indexOfSelectedItem] == 1){
        pathToScript = [[NSBundle mainBundle] pathForResource:@"audacity" ofType:@"applescript"];
    } else {
        pathToScript = [self.customAppleScript stringValue];
    }
    
    NSInteger sermonCount = ([directoryListing count] - 1); //remove ../ and ./ and then increment it by 1
    if ([[self.postType stringValue] isNotEqualTo: @"Expositional"]) {
        sermonCount = 1;
    }
    //script arguments (in order): localPathToRawFile, localPathToWorkspace, sermonFileName, sermonTitle, sermonPreacher, sermonBook, sermonCount
    NSArray *parameters = [NSArray arrayWithObjects: pathToScript,
                           [self.postRawLocation stringValue],
                           [[self.postRawLocation stringValue] stringByDeletingLastPathComponent],
                           [serverFile lastPathComponent],
                           [self.postTitle stringValue],
                           [self.postPreacher stringValue],
                           [self.postBook titleOfSelectedItem],
                           [[NSNumber numberWithInteger:sermonCount] stringValue],
                           nil];
    id fileExtension = [self.brain runScript:pathToScript withParameters:parameters];
    
    if ([fileExtension isNotEqualTo: nil]) {
         NSString *localEditedFile = [[[self.postRawLocation stringValue] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[[serverFile lastPathComponent] stringByAppendingPathExtension:fileExtension]];
        
        [self.mainWindow beginSheet:self.uploadingSheet completionHandler:NULL];
        [self.uploadingLabel setStringValue:@"Uploading..."];
        [self.ftpKit uploadFile:localEditedFile toServerPath:[serverFile stringByDeletingLastPathComponent] onUpdate:@selector(ftpKitDidUpload:fileSize:) onComplete:@selector(ftpKitDidFinishUploadingFile)];
        self.fileOnServer = [serverFile stringByAppendingPathExtension:fileExtension];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Unknown Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Check applescript if you are using a custom applescript."];
        [alert beginSheetModalForWindow:self.mainWindow completionHandler:NULL];
    }
    
    [self.postProgress stopAnimation:sender];
}

#pragma mark Server Browser Functions

-(IBAction)browseServer:(NSButton *)sender
{
    [self.mainWindow beginSheet:self.serverBrowserWindow completionHandler:NULL];
}

- (IBAction)userCanceledBrowseServer:(id)sender
{
    [self.mainWindow endSheet:self.serverBrowserWindow];
}

- (IBAction)serverBrowserSelectLocation:(id)sender
{
    NSString *path = [self serverGetCurrentPathNotIncludingSelectedfile];
    
    if (![[sender title] isEqualToString:@"Select"]) { //They hit select and make preset
        NSMutableDictionary *currentPreset = [[self.presetsArrayController arrangedObjects] objectAtIndex:[self.selectedPreset indexOfSelectedItem]];
        [currentPreset setObject:path forKey:KpresetServerLocation];
    }
    [self.postServerLocation setStringValue: path];
    [self userCanceledBrowseServer:sender];
}

- (IBAction)serverMakeNewFolder:(id)sender
{
    NSAlert *alert = [NSAlert alertWithMessageText: @"Name the new folder."
                                     defaultButton: @"Create"
                                   alternateButton: @"Cancel"
                                       otherButton: nil
                         informativeTextWithFormat: @""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:@"Folder Name"];
    [alert setAccessoryView:input];
    [alert beginSheetModalForWindow:self.serverBrowserWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertDefaultReturn) {
            [input validateEditing];

            NSString *path = [self serverGetCurrentPathNotIncludingSelectedfile];
            NSInteger selectedColumn = [self.serverBrowser selectedColumn];

            if ([[self.serverBrowser selectedCell] isLeaf]) {
                path = [path stringByDeletingLastPathComponent];
            } else {
                selectedColumn += 1;
            }
            path = [path stringByAppendingPathComponent: [input stringValue]];
            
            BOOL exists = [self.brain fileExists:[path lastPathComponent] inDirectoryListing: [self.ftpKit getDirectoryListingForPathSync:[path stringByDeletingLastPathComponent]]];
            if (exists) {
                while (exists) {
                    path = [path stringByAppendingString:@"_copy"];
                    exists = [self.brain fileExists:[path lastPathComponent] inDirectoryListing: [self.ftpKit getDirectoryListingForPathSync:[path stringByDeletingLastPathComponent]]];
                }
            }
            
            [self.ftpKit makeNewDirectoryAtPath:path onComplete:@selector(ftpKitDidFinishMakingNewDirectory)];
            [self startProgressInColumn:[self.serverBrowser frameOfColumn:selectedColumn]];
        }
    }];
}

- (IBAction)serverRefreshCurrentDirectory:(id)sender
{
    NSInteger currentColumn = [self serverGetCurrentColumn];
    
    if ([self.brain.serverColumns count] != 0) {
        [[self.brain.serverColumns objectAtIndex:currentColumn] setObject:@FALSE forKey:KserverColumnIsLoaded];
    }
    [self.serverBrowser reloadColumn: currentColumn];
}

- (IBAction)serverChanged:(id)sender
{
    [self.brain resetColumnCache];
    [self serverLoginWithCurrentSettings];
    [self.serverBrowser loadColumnZero];
}

- (IBAction)resortServerFiles:(id)sender
{
    [self.brain sortServerColumns: [self.serverShowFoldersAboveFiles state]];
    [self.serverBrowser loadColumnZero];
}

- (IBAction)serverToggleShowsHiddenFiles:(id)sender
{
    if ([self.serverShowHiddenFiles state] == NSOnState) {
        [self.ftpKit setDirectoryListingShowHiddenFiles:true];
    } else {
        [self.ftpKit setDirectoryListingShowHiddenFiles:false];
    }
    [self serverRefreshCurrentDirectory:sender];
}

- (NSDictionary *)getSelectedServer
{
    return [[self.serversArrayController arrangedObjects] objectAtIndex: [self.postServer indexOfSelectedItem]];
}

-(NSString *)serverGetCurrentPathNotIncludingSelectedfile
{
    NSString *path = @"/";
    
    if ([self serverGetCurrentColumn] != 0) {
        path = [self.serverBrowser path];
    }
    if ([[self.serverBrowser selectedCell] isLeaf]) {
        path = [path stringByDeletingLastPathComponent];
    }
    
    return path;
}

-(NSInteger)serverGetCurrentColumn
{
    NSInteger currentDirectory = [self.serverBrowser selectedColumn];
    
    if (! [[self.serverBrowser selectedCell] isLeaf]) {
        currentDirectory++;
    }
    return currentDirectory;
}

-(void)serverLoginWithCurrentSettings
{
    NSDictionary *selectedServer = [self getSelectedServer];
    
    [self.ftpKit setServerAddress: [selectedServer objectForKey:KserverPresetAddress]];
    if ([[selectedServer objectForKey:KserverPresetUserName] isNotEqualTo: @""]) {
        [self.ftpKit setUserName: [selectedServer objectForKey:KserverPresetUserName]];
    } else {
        [self.ftpKit setUserName:nil];
    }
    if ([[selectedServer objectForKey:KserverPresetPassword] isNotEqualTo: @""]) {
        [self.ftpKit setPassword: [selectedServer objectForKey:KserverPresetPassword]];
    } else {
        [self.ftpKit setPassword:nil];
    }
}

-(void)startProgressInColumn:(CGRect)columnRect
{
    [self.serverBrowser addSubview:self.serverProgress];
    
    float xSize = 25;
    float ySize = 25;
    
    float xPos = (columnRect.size.width / 2) - (xSize / 2) + (columnRect.origin.x);
    float yPos = (columnRect.size.height / 2) - (ySize / 2);
    
    [self.serverProgress setFrame:CGRectMake(xPos, yPos, xSize, ySize)];
    [self.serverProgress startAnimation:nil];

}

#pragma mark FTPKit Delegate Functions

-(void)ftpKitDidEncounterError:(NSError *)error
{
    [self.serverProgress stopAnimation:nil];
    [self.postProgress stopAnimation:nil];
    [self.mainWindow endSheet:self.uploadingSheet];
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

-(void)ftpKitDidFinishGettingDirectoryListing:(NSArray *)directoryListing
{
    NSInteger currentColumn = [self serverGetCurrentColumn];
    NSString *previouslySelectedItem = [[self serverGetCurrentPathNotIncludingSelectedfile] lastPathComponent];
    
    [[self.brain.serverColumns objectAtIndex:currentColumn] setObject:[NSArray arrayWithArray:directoryListing] forKey:KserverColumnDirectoryEntries];
    [[self.brain.serverColumns objectAtIndex:currentColumn] setObject:@TRUE forKey:KserverColumnIsLoaded];
    [[self.brain.serverColumns objectAtIndex:currentColumn] setObject:previouslySelectedItem forKey:KserverColumnPreviouslySelectedItem];
    
    [self.serverBrowser reloadColumn: currentColumn];
    [self.serverProgress stopAnimation:nil];
}

-(void)ftpKitDidFinishMakingNewDirectory
{
    [self.serverProgress stopAnimation:nil];
    [self serverRefreshCurrentDirectory:nil];
}

-(void)ftpKitDidUpload:(NSNumber *)fileOffset fileSize:(NSNumber *)fileSize
{
    double percent = ([fileOffset doubleValue] * 100 / [fileSize doubleValue]);
    [self.uploadingProgress setDoubleValue:percent];
}

-(void)ftpKitDidFinishUploadingFile
{
    [self.uploadingProgress setDoubleValue:100];
    [self.uploadingLabel setStringValue:@"Running MySql script..."];
    NSDictionary *selectedServer = [self getSelectedServer];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    // %@?key=%@&sermonPreacher=%@&sermonDate=%@&sermonService=%@&sermonBook=%@&sermonReference=%@&sermonTitle=%@&sermonType=%@&file=%@&seriesID=%@
    NSString *scriptURL = [NSString stringWithFormat:@"%@?key=%@&sermonPreacher=%@&sermonDate=%@&sermonService=%@&sermonBook=%@&sermonReference=%@&sermonTitle=%@&sermonType=%@&file=%@&seriesID=%@",
                                             [selectedServer objectForKey:KserverPresetMysqlAddress],
                                             [selectedServer objectForKey:KserverPresetMysqlKey],
                                             [self.postPreacher stringValue],
                                             [dateFormatter stringFromDate:[self.datePicker dateValue]],
                                             [self.postService stringValue],
                                             [self.postBook titleOfSelectedItem],
                                             [self.postReference stringValue],
                                             [self.postTitle stringValue],
                                             [self.postType stringValue],
                                             self.fileOnServer,
                                             [self.postSeriesID stringValue]
                                             ];
    if (! [scriptURL hasPrefix:@"http://"]) {
        scriptURL = [@"http://" stringByAppendingString:scriptURL];
    }
    scriptURL = [scriptURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *reply = [[NSString stringWithContentsOfURL:[NSURL URLWithString:scriptURL] encoding:NSUTF8StringEncoding error:nil] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.mainWindow endSheet:self.uploadingSheet];
    if ([reply isNotEqualTo:@"Error"]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Sermon Successfully Posted." defaultButton:@"OK" alternateButton:@"View Page" otherButton:nil informativeTextWithFormat:@""];
        [alert beginSheetModalForWindow:self.mainWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertAlternateReturn) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:reply]];
        }
    }];
        if ([self.deleteLocalFilesWhenDone state] == NSOnState) {
            NSURL *rawFile = [NSURL fileURLWithPath: [self.postRawLocation stringValue]];
            NSURL *rawFileAif = [NSURL fileURLWithPath: [[[self.postRawLocation stringValue] stringByDeletingPathExtension] stringByAppendingPathExtension:@"aif"]];
            NSURL *editedFile = [[rawFile URLByDeletingLastPathComponent] URLByAppendingPathComponent:[self.fileOnServer lastPathComponent]];
            NSMutableArray *files = [NSMutableArray arrayWithObjects:rawFile, rawFileAif, editedFile, nil];
            NSMutableArray *filesToRemove = [NSMutableArray array];
            
            for (NSInteger i=0; i<[files count]; i++) {
                if (! [[files objectAtIndex:i] checkResourceIsReachableAndReturnError:nil]) {
                    [filesToRemove addObject:[files objectAtIndex:i]];
                }
            }
            [files removeObjectsInArray:filesToRemove];
            [[NSWorkspace sharedWorkspace] recycleURLs:files completionHandler:NULL];
        }
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error Adding Sermon to Database." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check MySql script.\n%@", reply];
        [alert beginSheetModalForWindow:self.mainWindow completionHandler:NULL];
    }
}


#pragma mark NSBrowser Delegate Functions

-(void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix *)matrix
{
    if ([self.brain.serverColumns count] <= column) {
        [self.brain addNewColumnToCache];
    }
    [matrix setIntercellSpacing:NSMakeSize(0, 2)];
    
    NSDictionary *curColumn = [self.brain.serverColumns objectAtIndex:column];
    NSString *path = [self serverGetCurrentPathNotIncludingSelectedfile];
    
    if ([[curColumn objectForKey:KserverColumnIsLoaded] boolValue]) {
        if ([[curColumn objectForKey:KserverColumnPreviouslySelectedItem]  isEqualToString: [path lastPathComponent]]) {
            [self.brain sortServerColumns:[self.serverShowFoldersAboveFiles state]];
            for (NSInteger i=0; i<[[curColumn objectForKey:KserverColumnDirectoryEntries] count]; i++) {
                [matrix addRow];
            }
        }
    }

    [self.ftpKit getDirectoryListingForPath:path onComplete:@selector(ftpKitDidFinishGettingDirectoryListing:)];
    [self startProgressInColumn: [self.serverBrowser frameOfColumn:column]];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    
    NSDictionary *myCell = [[[self.brain.serverColumns objectAtIndex:column] objectForKey:KserverColumnDirectoryEntries] objectAtIndex:row];
    NSNumber *type = [myCell objectForKey:(id)kCFFTPResourceType];
    NSString *fileType = [[myCell objectForKey:(id)kCFFTPResourceName] pathExtension];
    
    if ([type isEqualTo: [NSNumber numberWithInteger:4]]) {
        [cell setLeaf: false];
        fileType = NSFileTypeForHFSTypeCode(kGenericFolderIcon);
    } else {
        [cell setLeaf: true];
    }
     NSImage *img = [[NSWorkspace sharedWorkspace] iconForFileType: fileType];
    [img setSize: NSMakeSize(15, 15)];
    [cell setImage: img];
    [cell setStringValue: [myCell objectForKey:(id)kCFFTPResourceName]];
}
@end