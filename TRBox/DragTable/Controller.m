//
//  Controller.m
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"

@implementation Controller

- (void)awakeFromNib
{
	filenames = [[NSMutableArray alloc] init];
}

- (void)dealloc
{
    [filenames release];
    [super dealloc];
}

- (void)acceptFilenameDrag:(NSString*)filename
{
    if ([filename hasSuffix:@"png"] || 
        [filename hasSuffix:@"jpg"] || 
        [filename hasSuffix:@"jpeg"] ||
        [filename hasSuffix:@"gif"] ||
        [filename hasSuffix:@"bmp"] ||
        [filename hasSuffix:@"tif"] ||
        [filename hasSuffix:@"tiff"] )
    {
        [arrayController addObject:filename];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:CHANGEDA_NOTIFICATION_DRAG_NAME object:filename];
    }
    else
    {
        NSAlert *alert =[NSAlert alertWithMessageText:@"警告" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"只接受图像格式(%@)",filename]];
        [alert runModal];
    }
}

- (void)clear
{
    [arrayController removeObjects:arrayController.arrangedObjects];
}

- (void)resetFromArray:(NSArray *)array
{
    [arrayController addObjects:array];
}

@end
