//
//  TRBoxAppDelegate.m
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TRBoxAppDelegate.h"

@implementation TRBoxAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [settingWindow release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    
    settingWindow = [[SettingWindowController alloc] initWithWindowNibName:@"SettingWindowController"];
    
    
}

- (void)windowDidEnd:(id)alert returnCode:(NSInteger)returnCode contextInfo:(id)contextInfo
{
    if (returnCode != NSOKButton) 
        return;
    //[[NSApplication sharedApplication] presentError:nil modalForWindow:self delegate:nil didPresentSelector:nil contextInfo:NULL];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [NSApp beginSheet:settingWindow.window
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(windowDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
} 

- (void)windowDidExpose:(NSNotification *)notification
{
    
} 

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate:self]; 
    return YES;
}

@end
