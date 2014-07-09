//
//  DragDropTableView.h
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSInteger IndexFromIdentifier(NSString *identifier);

// menu delegate
@protocol CustomMenuDataSource <NSObject>
@optional

- (NSMenu*)tableView:(NSTableView*)tableView menuForEvent:(NSEvent*)event;    

@end

@interface DragDropTableView : NSTableView
{
}
@property(nonatomic,strong)id<CustomMenuDataSource> menuDataSource;
@end
