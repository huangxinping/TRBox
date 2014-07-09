//
//  TRBoxEditController.h
//  TRBox
//
//  Created by hxp on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TRBoxEditController : NSWindowController<NSWindowDelegate,NSTextViewDelegate>
{
    NSMutableArray *lineBuffer;
    int oldSeletedLine;
    
    NSImage *imageBox; 
    
    NSImage *imageRect;
    
    NSRange nowSelectedRange;
}
@property(nonatomic,retain)NSString *boxPath;
@property (assign) IBOutlet NSScrollView *imageView;
@property (assign) IBOutlet NSTextView *boxInfoTextView;
@property (assign) IBOutlet NSProgressIndicator *activity;

- (id)initWithBoxPath:(NSString*)box;


- (IBAction)saveBox:(id)sender;
- (IBAction)mergeBoxItem:(id)sender;
- (IBAction)splitBoxItem:(id)sender;
- (IBAction)deleteBoxItem:(id)sender;

@end
