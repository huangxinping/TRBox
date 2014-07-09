//
//  SettingWindowController.h
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TRBoxSettting.h"

@interface SettingWindowController : NSWindowController
@property (assign) IBOutlet NSTextField *langTextField;
@property (assign) IBOutlet NSTextField *fontTextField;
@property (assign) IBOutlet NSMatrix *defaultLang;
@property (assign) IBOutlet NSMatrix *isDigtis;
@property (assign) IBOutlet NSMatrix *isConvertGray;
@property (assign) IBOutlet NSButton *sureSettingButton;
- (IBAction)sureButton:(id)sender;

@end
