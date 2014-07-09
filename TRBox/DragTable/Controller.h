//
//  Controller.h
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define USE_CHANGED_DRAG 1
#if USE_CHANGED_DRAG
    #define CHANGEDA_NOTIFICATION_DRAG_NAME @"ChangedNotificationDragName"
#endif

@interface Controller : NSObject
{
	NSMutableArray *filenames;
    IBOutlet NSArrayController *arrayController;
}
- (void)clear;
- (void)resetFromArray:(NSArray*)array;
@end
