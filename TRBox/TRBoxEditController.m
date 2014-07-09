//
//  TRBoxEditController.m
//  TRBox
//
//  Created by hxp on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TRBoxEditController.h"

@interface TRBoxEditController ()
- (void)drawSelectedChar:(NSInteger)line;
- (NSInteger)lineIndexFromSelectedCharRande:(NSRange)range;
- (void)loadResources;
@end

@implementation TRBoxEditController
@synthesize boxPath;
@synthesize imageView;
@synthesize boxInfoTextView;
@synthesize activity;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) 
    {
    }
    return self;
}

- (void)dealloc
{
    self.boxPath = nil;
    [lineBuffer release];
    [imageBox release];
    [super dealloc];
}

- (id)initWithBoxPath:(NSString *)box
{
    self.boxPath = box;
    return [self initWithWindowNibName:@"TRBoxEditController"];
}

- (IBAction)saveBox:(id)sender 
{    
    NSString *saveBuffer = boxInfoTextView.string;
    NSArray *array = [self.boxPath componentsSeparatedByString:@"."];
    [saveBuffer writeToFile:[NSString stringWithFormat:@"%@.%@.%@.box",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSAlert *alert =[NSAlert alertWithMessageText:@"提示" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"保存成功"];
    [alert runModal];
}

- (IBAction)mergeBoxItem:(id)sender 
{ 
//    NSLog(@"%d",boxInfoTextView.selectedRange.location);
//    NSInteger start = [self lineIndexFromSelectedCharRande:boxInfoTextView.selectedRange];
//    NSLog(@"%@",[lineBuffer objectAtIndex:start]);
//    NSInteger end = [self lineIndexFromSelectedCharRande:NSMakeRange(
//                                                                     nowSelectedRange.location+[[lineBuffer objectAtIndex:start] length]+1
//                                                                     , nowSelectedRange.length-[[lineBuffer objectAtIndex:start] length]+1)];
    //NSLog(@"%@",[lineBuffer objectAtIndex:end]);
    //NSInteger end = nowSelectedRange.location+nowSelectedRange.length;
    //NSInteger startLine = 
}

- (IBAction)splitBoxItem:(id)sender 
{
    if (oldSeletedLine == -1) {
        return;
    }
    NSInteger lastSelectedLine = oldSeletedLine;
    
    // 蒋 207 528 246 567 0
    NSString *splitLineBuffer = [NSString stringWithString:[lineBuffer objectAtIndex:oldSeletedLine]];
    NSArray *splitArray = [splitLineBuffer componentsSeparatedByString:@" "];
        
    NSInteger left = [[splitArray objectAtIndex:1] integerValue];
    NSInteger top = [[splitArray objectAtIndex:2] integerValue];
    NSInteger right = [[splitArray objectAtIndex:3] integerValue];
    NSInteger bottom = [[splitArray objectAtIndex:4] integerValue];
    
    NSRect rect1 = NSMakeRect(left, top, (right-left)/2, bottom-top);
    NSRect rect2 = NSMakeRect(left+(right-left)/2, top, (right-left)/2, bottom-top);
    
    NSString *rect1String = [NSString stringWithFormat:@"%@ %d %d %d %d %@",[splitArray objectAtIndex:0],(int)rect1.origin.x,(int)rect1.origin.y,(int)rect1.origin.x+(int)rect1.size.width,(int)rect1.origin.y+(int)rect1.size.height,[splitArray objectAtIndex:5]];
    
    NSString *rect2String = [NSString stringWithFormat:@"%@ %d %d %d %d %@",[splitArray objectAtIndex:0],(int)rect2.origin.x,(int)rect2.origin.y,(int)rect2.origin.x+(int)rect2.size.width,(int)rect2.origin.y+(int)rect2.size.height,[splitArray objectAtIndex:5]];
    
    [lineBuffer removeObjectAtIndex:oldSeletedLine];
    [lineBuffer insertObject:rect1String atIndex:oldSeletedLine];
    [lineBuffer insertObject:rect2String atIndex:oldSeletedLine+1];

    NSMutableString *boxBuffer = [NSMutableString string];
    for (NSString *obj in lineBuffer)
    {
        [boxBuffer appendFormat:@"%@\n",obj];
    }
    [boxInfoTextView setString:boxBuffer];
    
    [self drawSelectedChar:lastSelectedLine];
}

- (IBAction)deleteBoxItem:(id)sender 
{    
    if (oldSeletedLine == -1)
    {
        return;
    }
    [lineBuffer removeObjectAtIndex:oldSeletedLine];

    NSMutableString *boxBuffer = [NSMutableString string];
    for (NSString *obj in lineBuffer)
    {
        [boxBuffer appendFormat:@"%@\n",obj];
    }
    [boxInfoTextView setString:boxBuffer];
    
    [self drawSelectedChar:oldSeletedLine];
}

- (void)windowDidLoad
{
    [super windowDidLoad]; 
    
    oldSeletedLine = 0;
    
    nowSelectedRange = NSMakeRange(0, 9);
    
    self.window.delegate = self;
    
    imageRect = [NSImage imageNamed:@"rect.png"];
    
    // 导入识别图
    imageBox = [[NSImage alloc] initWithContentsOfFile:self.boxPath];
    NSImageView *iv = [[NSImageView alloc] init];
    [iv setFrame:NSMakeRect(0, 0, imageBox.size.width, imageBox.size.height)];
    [iv setImage:imageBox];
    [imageView setDocumentView:iv];
    [iv release];
    
    // 导入box文件信息
    NSArray *array = [self.boxPath componentsSeparatedByString:@"."];
    NSString *buffer = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@.%@.%@.box",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]] encoding:NSUTF8StringEncoding error:nil];
    [boxInfoTextView setString:buffer];
    boxInfoTextView.delegate = self;
    
    lineBuffer = [[NSMutableArray alloc] init];
    [lineBuffer addObjectsFromArray:[buffer componentsSeparatedByString:@"\n"]];
    
    [self drawSelectedChar:0];
    [boxInfoTextView setSelectedRange:NSMakeRange(0, 0)];
}

- (NSInteger)lineIndexFromSelectedCharRande:(NSRange)range
{
    NSInteger lineCount = 0;
    NSInteger pawugCount = 0;
    for (NSString *obj in lineBuffer)
    {
        pawugCount += [obj length];
        pawugCount++; // 空格也算了一个位置
        if (range.location <= pawugCount)
        {
            break;
        }
        lineCount++;
    }
    return lineCount;
}

- (void)drawSelectedChar:(NSInteger)line
{
    if (line >= [lineBuffer count]) 
    {
        return;
    }
    // 移除原有绘制
    for (NSView *view in [(NSView*)imageView.documentView subviews])
    {
        [view removeFromSuperview];
    }
    
    NSView *drawView = [[NSView alloc] init];
    
    // 计算绘制位置
    NSString *buffer = boxInfoTextView.string;
    [lineBuffer removeAllObjects];
    [lineBuffer addObjectsFromArray:[buffer componentsSeparatedByString:@"\n"]];
    NSString *singleLineBuffer = [lineBuffer objectAtIndex:line];
    NSArray *locationArray = [singleLineBuffer componentsSeparatedByString:@" "];
    NSRect rect = NSMakeRect([[locationArray objectAtIndex:1] floatValue], [[locationArray objectAtIndex:2] floatValue], [[locationArray objectAtIndex:3] floatValue]-[[locationArray objectAtIndex:1] floatValue], [[locationArray objectAtIndex:4] floatValue]-[[locationArray objectAtIndex:2] floatValue]);
    [drawView setFrame:NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width+100, rect.size.height+100)];
    
    [imageView scrollRectToVisible:drawView.frame];
    
    // 绘制矩形框框
    NSImageView *rectIV = [[NSImageView alloc] init];
    [rectIV setFrame:NSMakeRect(0, 0, rect.size.width, rect.size.height)];
    //[rectIV setImageAlignment:NSImageAlignBottomLeft];
    [rectIV setImageScaling:NSImageScaleAxesIndependently];
    [rectIV setImage:imageRect];
    [drawView addSubview:rectIV];
    [rectIV release];
    
    // 绘制当前识别文字
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, rect.size.height, 20, 20)];
    [label setDrawsBackground:NO];
    [label setBordered:NO];
    [label setFont:[NSFont boldSystemFontOfSize:18]];
    [label setAlignment:NSLeftTextAlignment];
    [label setStringValue:[locationArray objectAtIndex:0]];
    [label setEditable:NO];
    [label setTextColor:[NSColor greenColor]];
    [label setBackgroundColor:[NSColor clearColor]];
    [drawView addSubview:label];
    [label release];
    
    [imageView.documentView addSubview:drawView];
    [drawView release];
    
    oldSeletedLine = line;
}

- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange
{
    nowSelectedRange = NSMakeRange(newSelectedCharRange.location, newSelectedCharRange.length);
    [self drawSelectedChar:[self lineIndexFromSelectedCharRande:newSelectedCharRange]];
    return newSelectedCharRange;
}

- (NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex
{
    return nil;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    [self drawSelectedChar:oldSeletedLine];
    return YES;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray *)affectedRanges replacementStrings:(NSArray *)replacementStrings
{
    [self drawSelectedChar:oldSeletedLine];
    return YES;
}

- (BOOL)windowShouldClose:(id)sender
{
    [self close]; 
    return YES;
}

@end
