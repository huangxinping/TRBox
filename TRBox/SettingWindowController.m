//
//  SettingWindowController.m
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingWindowController.h"

BOOL isNilAndEmpty(NSTextField *tf)
{
    if (tf.stringValue == nil || [tf.stringValue isEqualToString:@""])
    {
        return YES;
    }
    return NO;
}

@interface SettingWindowController ()

@end

@implementation SettingWindowController
@synthesize langTextField;
@synthesize fontTextField;
@synthesize defaultLang;
@synthesize isDigtis;
@synthesize isConvertGray;
@synthesize sureSettingButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) 
    {
        [sureSettingButton setEnabled:NO];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)sureButton:(id)sender 
{
    if (isNilAndEmpty(langTextField) || isNilAndEmpty(fontTextField))
    {
        NSAlert *alert =[NSAlert alertWithMessageText:@"警告" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"请完善内容"];
        [alert runModal];
        return;
    }
    [TRBoxSettting sharedTRBoxSetting].lang = langTextField.stringValue;
    [TRBoxSettting sharedTRBoxSetting].font = fontTextField.stringValue;
    switch (defaultLang.selectedColumn)
    {
        case 0:
            [TRBoxSettting sharedTRBoxSetting].ocr = OCR_ENG;
            break;
        case 1:
            [TRBoxSettting sharedTRBoxSetting].ocr = OCR_SIM;
            break;
        case 2:
            [TRBoxSettting sharedTRBoxSetting].ocr = OCR_TRA;
            break;
        case 3:
            [TRBoxSettting sharedTRBoxSetting].ocr = OCR_CUSTOM;
            break;
        default:
            break;
    }
    switch (isDigtis.selectedColumn)
    {
        case 0:
            [TRBoxSettting sharedTRBoxSetting].isDigits = NO;
            break;
        case 1:
            [TRBoxSettting sharedTRBoxSetting].isDigits = YES;
            break;
        default:
            break;
    }
    switch (isConvertGray.selectedColumn)
    {
        case 0:
            [TRBoxSettting sharedTRBoxSetting].isConvertGray = NO;
            break;
        case 1:
            [TRBoxSettting sharedTRBoxSetting].isConvertGray = YES;
            break;
        default:
            break;
    }
    //NSLog(@"%@",[TRBoxSettting sharedTRBoxSetting]);
    [[NSApplication sharedApplication] endSheet:self.window returnCode:NSOKButton];
    [self.window orderOut:nil];  
    [self.window close];
}
@end
