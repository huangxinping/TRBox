//
//  DragDropTableView.m
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DragDropTableView.h"

NSInteger IndexFromIdentifier(NSString *identifier)
{
    if ([identifier isEqualToString:@"zero"])
    {
        return 0;
    }
    else if ([identifier isEqualToString:@"one"])
    {
        return 1;
    }
    else if ([identifier isEqualToString:@"two"])
    {
        return 2;
    }
    else if ([identifier isEqualToString:@"three"])
    {
        return 3;
    }
    else if ([identifier isEqualToString:@"four"])
    {
        return 4;
    }
    else if ([identifier isEqualToString:@"five"])
    {
        return 5;
    }
    else if ([identifier isEqualToString:@"six"])
    {
        return 6;
    }
    else if ([identifier isEqualToString:@"seven"])
    {
        return 7;
    }
    else if ([identifier isEqualToString:@"eight"])
    {
        return 8;
    }
    else if ([identifier isEqualToString:@"nine"])
    {
        return 9;
    }
    return -1;
}

@implementation DragDropTableView
@synthesize menuDataSource;

- (void)awakeFromNib
{
    menuDataSource = nil;
    
	// Register to accept filename drag/drop
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (void)dealloc
{
    [menuDataSource release];
    [super dealloc];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    // 计算行数
    NSInteger selectedRow = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
    // 计算列数
    NSTableColumn *selectedColumn = [[self tableColumns] objectAtIndex:[self columnAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]]];
    NSInteger selectedCol = IndexFromIdentifier(selectedColumn.identifier);
    if (selectedRow == -1)
    {
        [super rightMouseDown:theEvent];
        return;
    }
    
    if ([self.menuDataSource respondsToSelector:@selector(tableView:menuForEvent:)])
    {
        NSMenu *menu = [self.menuDataSource performSelector:@selector(tableView:menuForEvent:) withObject:self withObject:theEvent];
        [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
    }
    
    [super rightMouseDown:theEvent];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	// Need the delegate hooked up to accept the dragged item(s) into the model
	if ([self delegate] == nil)
	{
		return NSDragOperationNone;
	}
	
	if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType])
	{
		return NSDragOperationCopy;
	}
	
	return NSDragOperationNone;
}

// Work around a bug from 10.2 onwards
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationEvery;
}

// Stop the NSTableView implementation getting in the way
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	int i;
	NSPasteboard *pboard;
	pboard = [sender draggingPasteboard];
	if ([[pboard types] containsObject:NSFilenamesPboardType])
	{
		id delegate = [self delegate];
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		if ([delegate respondsToSelector:@selector(acceptFilenameDrag:)])
		{
			for (i = 0; i < [filenames count]; i++)
			{
				[delegate performSelector:@selector(acceptFilenameDrag:) withObject:[filenames objectAtIndex:i]];
			}
		}
		return YES;
	}
	return NO;
}	

@end
