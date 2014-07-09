//
//  TRBoxWindow.h
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragDropTableView.h"

// use default application open it.
// [[NSWorkspace sharedWorkspace] openFile:filePath];

@interface TRBoxWindow : NSWindow<CustomMenuDataSource,NSTableViewDelegate>
{
    NSMutableArray *finderFiles;
    NSMutableArray *windowsArray;
}
@property (assign) IBOutlet DragDropTableView *filesTableView;
@property (assign) IBOutlet NSProgressIndicator *activity;
@property (assign) IBOutlet NSButton *grayConvertButton;
@property (assign) IBOutlet NSButton *boxConvertButton;
@property (assign) IBOutlet NSButton *combineConvertButton;

- (IBAction)grayConvert:(id)sender;
- (IBAction)combineConvert:(id)sender;
- (IBAction)boxConvert:(id)sender;

@end
