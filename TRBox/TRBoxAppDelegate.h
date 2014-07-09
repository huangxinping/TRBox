//
//  TRBoxAppDelegate.h
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SettingWindowController.h"

@interface TRBoxAppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>
{
    SettingWindowController *settingWindow;   
}
@property (assign) IBOutlet NSWindow *window;

@end
