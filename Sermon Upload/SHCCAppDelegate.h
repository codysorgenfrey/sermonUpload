//
//  SHCCAppDelegate.h
//  Sermon Upload
//
//  Created by Cody Sorgenfrey on 10/25/13.
//  Copyright (c) 2013 South Hill Calvary Chapel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SHCCAppDelegate : NSObject <NSApplicationDelegate>

@property (unsafe_unretained)   IBOutlet NSWindow                         *mainWindow;
@property (weak)                IBOutlet NSArrayController                *serversArrayController;
@property (weak)                IBOutlet NSArrayController                *presetsArrayController;
@property (weak)                IBOutlet NSArrayController                *typesArrayController;
@property (weak)                IBOutlet NSArrayController                *servicesArrayController;
@property (weak)                IBOutlet NSArrayController                *bibleBooksArrayController;
@property (weak)                IBOutlet NSPopUpButton                    *selectedPreset;
@property (weak)                IBOutlet NSDatePicker                     *datePicker;
@property (weak)                IBOutlet NSPopUpButton                    *postServer;
@property (weak)                IBOutlet NSComboBox                       *postService;
@property (weak)                IBOutlet NSComboBox                       *postType;
@property (weak)                IBOutlet NSPopUpButton                    *postBook;
@property (weak)                IBOutlet NSTextField                      *postReference;
@property (weak)                IBOutlet NSTextField                      *postPreacher;
@property (weak)                IBOutlet NSTextField                      *postTitle;
@property (weak)                IBOutlet NSTextField                      *postSeriesID;
@property (weak)                IBOutlet NSTextField                      *postServerLocation;
@property (weak)                IBOutlet NSTextField                      *postRawLocation;
@property (weak)                IBOutlet NSProgressIndicator              *postProgress;

@property (weak)                IBOutlet NSButton                         *serverShowHiddenFiles;
@property (weak)                IBOutlet NSButton                         *serverShowFoldersAboveFiles;
@property (unsafe_unretained)   IBOutlet NSPanel                          *serverBrowserWindow;
@property (weak)                IBOutlet NSBrowser                        *serverBrowser;
@property (weak)                IBOutlet NSButton                         *serverSelect;

@property (weak)                IBOutlet NSButton                         *deleteLocalFilesWhenDone;
@property (weak)                IBOutlet NSTextField                      *customAppleScript;
@property (weak)                IBOutlet NSPopUpButton                    *audioEditingScript;

@property (unsafe_unretained)   IBOutlet NSPanel                          *uploadingSheet;
@property (weak)                IBOutlet NSProgressIndicator              *uploadingProgress;
@property (weak)                IBOutlet NSTextField                      *uploadingLabel;

- (IBAction)addNewServerPreset:(id)sender;
- (IBAction)removeServerPreset:(id)sender;
- (IBAction)addNewPreset:(id)sender;
- (IBAction)removeExistingPreset:(id)sender;
- (IBAction)loadPreset:(NSPopUpButton *)sender;
- (IBAction)selectCustomScript:(id)sender;
- (IBAction)chooseRawFile:(NSButton *)sender;
- (IBAction)postSermon:(id)sender;

- (IBAction)browseServer:(NSButton *)sender;
- (IBAction)userCanceledBrowseServer:(id)sender;
- (IBAction)serverBrowserSelectLocation:(id)sender;
- (IBAction)serverMakeNewFolder:(id)sender;
- (IBAction)serverRefreshCurrentDirectory:(id)sender;
- (IBAction)serverChanged:(id)sender;
- (IBAction)resortServerFiles:(id)sender;
- (IBAction)serverToggleShowsHiddenFiles:(id)sender;

@end