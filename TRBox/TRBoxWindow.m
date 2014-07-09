//
//  TRBoxWindow.m
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TRBoxWindow.h"
#import "Controller.h"
#import "TRBoxSettting.h"
#import "TRBoxEditController.h"

CGImageRef CGImageRefCopyFromNSImage(NSImage* image)
{
    NSData * imageData = [image TIFFRepresentation];	
    CGImageRef imageRef = nil;	
    if(imageData)		
    {		
        CGImageSourceRef imageSource = 	CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);	 //need release	
        imageRef = CGImageSourceCreateImageAtIndex( imageSource, 0, NULL);   //need release by caller
		
		CFRelease(imageSource);
    }
	
    return imageRef;
}

NSImage* nsImageFromCGImageRef(CGImageRef image)
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    // Create a new image to receive the Quartz image data.
	if(imageRect.size.height ==0 ||imageRect.size.width ==0)
	{
		NSLog(@"nsImageFromCGImageRef should not be here!!!,CGImageRef is %@",image);
	}
    newImage = [[[NSImage alloc] initWithSize:imageRect.size] autorelease];
    [newImage lockFocus];
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext]
								  graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
    return newImage;
}

NSImage* GrayImageFromNSImage(NSImage*image)
{
    if(nil == image)
        return nil;
    BOOL enableAlaph = YES;
    
    CGColorSpaceRef colorspace = NULL;
    CGContextRef context = NULL;
    
    colorspace = CGColorSpaceCreateWithName(enableAlaph?kCGColorSpaceGenericRGB : kCGColorSpaceGenericGray);  //need release
    //colorspace = CGColorSpaceCreateDeviceGray();
    
    unsigned char *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    CGImageRef inImage = CGImageRefCopyFromNSImage(image);  //need release
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = pixelsWide * (enableAlaph ? 4 : 1);
    bitmapByteCount = bitmapBytesPerRow * pixelsHigh;
    //LOGDEBUG("bitmapdata is %d", bitmapByteCount);
    bitmapData = (unsigned char *)malloc(bitmapByteCount);  //need free
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,
                                    bitmapBytesPerRow,
                                    colorspace,
                                    (enableAlaph ?
                                     kCGImageAlphaPremultipliedLast : kCGImageAlphaNone));  //need release
    
    
    CGRect rect = {{0, 0}, {pixelsWide, pixelsHigh}};
    CGContextDrawImage(context, rect, inImage);
    CGImageRelease(inImage);
    if(enableAlaph)
    {
        int i,j;
        for(i = 0; i < bitmapBytesPerRow; i += 4)
            for(j = 0; j < pixelsHigh; j++)
            {
                int grey = (int)(bitmapData[j * bitmapBytesPerRow + i]*0.299
                                 + bitmapData[j * bitmapBytesPerRow + i+1]*0.587 + bitmapData[j *
                                                                                              bitmapBytesPerRow + i+2]*0.114);
                bitmapData[j * bitmapBytesPerRow + i] = bitmapData[j *
                                                                   bitmapBytesPerRow + i + 1] = bitmapData[j * bitmapBytesPerRow + i + 2] =
                grey;
            }
    }
    CGImageRef test = CGBitmapContextCreateImage(context) ;  //need release
    free(bitmapData);
    //LOGDEBUG("test is %s", test == nil ? "nil" : "full");
    
    NSImage * img = nsImageFromCGImageRef(test);
    
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
    CGImageRelease(test);
    return img;
}

@implementation TRBoxWindow
@synthesize filesTableView;
@synthesize activity;
@synthesize grayConvertButton;
@synthesize boxConvertButton;
@synthesize combineConvertButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    finderFiles = [NSMutableArray new];
    windowsArray = [NSMutableArray new];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(changedDrag:) name:CHANGEDA_NOTIFICATION_DRAG_NAME object:nil];
}

- (void)dealloc
{
    [finderFiles release];
    for (id obj in windowsArray)
    {
        [obj release];
    }
    [windowsArray release];
    [super dealloc];
}

- (void)changedDrag:(NSNotification*)notification
{
    filesTableView.menuDataSource = self;
    
    // add file's absolution path.
    [finderFiles addObject:notification.object];

    [grayConvertButton setEnabled:YES];
}

- (void)convertGray:(id)sender
{
    NSMutableArray *convertarray = [NSMutableArray array];
    while (true)
    {
        for (NSInteger i = 0; i < [finderFiles count]; i++)
        {
            // 获取所需信息
            NSString *path = [finderFiles objectAtIndex:i];
            NSArray *array = [path componentsSeparatedByString:@"."];
            NSString *suffix = [array lastObject];
            NSString *lang = [TRBoxSettting sharedTRBoxSetting].lang;
            NSString *font = [TRBoxSettting sharedTRBoxSetting].font;
            NSString *newPath = [NSString stringWithFormat:@"%@/%@.%@%d.exp%d.%@",[array objectAtIndex:0],lang,font,i,i,suffix];
            NSArray *result = [newPath componentsSeparatedByString:@"/"];
            NSMutableString *resultPath = [NSMutableString string];
            for (NSInteger i = 0; i < [result count]; i++)
            {
                if (i == [result count]-2)
                {
                    continue;
                }
                NSString *obj = [result objectAtIndex:i];
                [resultPath appendString:obj];
                if (i == [result count]-1)
                {
                    continue;
                }
                [resultPath appendString:@"/"];
            }
            
            // 转换到灰度并依据语言和字体名称更替文件名
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
            if (![TRBoxSettting sharedTRBoxSetting].isConvertGray)
            {
                // 不转换灰度图
                [image.TIFFRepresentation writeToFile:resultPath atomically:YES];
                [image release];
            }
            else
            {
                // 转换成灰度图
                NSImage *grayImage = GrayImageFromNSImage(image);
                [image release];
                NSData *data = grayImage.TIFFRepresentation;
                [data writeToFile:resultPath atomically:YES];
            } 
            [convertarray addObject:resultPath];
            if ([resultPath isEqualToString:path])
            {
                
            }
            else 
            {
                // 删除原有文件
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
        break;
    }
    [activity stopAnimation:nil];
    
    // 重新设置TableView的内容
    Controller *controller = (Controller*)filesTableView.delegate;
    [controller clear];
    [finderFiles removeAllObjects];
    [finderFiles addObjectsFromArray:convertarray];
    [controller resetFromArray:finderFiles];
    
    [grayConvertButton setEnabled:NO];
    [boxConvertButton setEnabled:YES];
    
    [NSThread exit];
}

- (IBAction)grayConvert:(id)sender 
{    
    [activity startAnimation:nil];
    [NSThread detachNewThreadSelector:@selector(convertGray:) toTarget:self withObject:nil];
}

#define TESSERACT_DATA @"/usr/local/Cellar/tesseract/3.01/share/tessdata"
#define TESSERACT_DATA_ENG @"eng.traineddata"
#define TESSERACT_DATA_SIM @"chi_sim.traineddata"
#define TESSERACT_DATA_TRA @"chi_tra.traineddata"

#define TESSERACT_BIN @"/usr/local/Cellar/tesseract/3.01/bin"
#define TESSERACT_BIN_TESSERACT @"tesseract"
#define TESSERACT_BIN_CNTRAINING @"cntraining"
#define TESSERACT_BIN_MFTRAINING @"mftraining"
#define TESSERACT_BIN_UNICHARSET @"unicharset_extractor"
#define TESSERACT_BIN_COMBINE @"combine_tessdata"
#define TESSERACT_BIN_WORDLIST @"wordlist2dawg"

#define TESSERACT_CONFIGS @"/usr/local/Cellar/tesseract/3.01/share/tessdata/configs"
#define TESSERACT_CONFIGS_MAKEBOX @"makebox"
#define TESSERACT_CONFIGS_BOXTRAIN @"box.train"

- (void)convertCombine:(id)sender
{
    while (true)
    {
        // tesseract share.arial.exp0.tiff share.arial.exp0 -l eng nobatch box.train.stderr 
        NSString *tesseractPath = [NSString stringWithFormat:@"%@/%@",TESSERACT_BIN,TESSERACT_BIN_TESSERACT];
        // 获得训练数据
        for (NSString *obj in finderFiles)
        {
            // 准备参数
            NSArray *array = [obj componentsSeparatedByString:@"."];
            NSMutableArray *args = [NSMutableArray array];
            [args addObject:obj];
            [args addObject:[NSString stringWithFormat:@"%@.%@.%@",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]]];
            [args addObject:@"-l"];
            switch ([TRBoxSettting sharedTRBoxSetting].ocr) 
            {
                case OCR_ENG: 
                    [args addObject:@"eng"];
                    break;
                case OCR_SIM:
                    [args addObject:@"chi_sim"];
                    break;
                case OCR_TRA:
                    [args addObject:@"chi_tra"];
                    break;
                case OCR_CUSTOM:
                    [args addObject:@"share"];
                    break;
                default:
                    break;
            }
            if ([TRBoxSettting sharedTRBoxSetting].isDigits) 
            {
                [args addObject:@"digits"];
            }
            [args addObject:@"nobatch"];
            [args addObject:@"box.train.stderr"];
            
            // 测试识别
            NSTask *task = [NSTask launchedTaskWithLaunchPath:tesseractPath arguments:args];
            [task waitUntilExit];
        }
        
        // (unicharset_extractor share.airal.exp0.box share.arial.exp1.box ...)
        // 字符集导出
        NSString *unicharsetPath = [NSString stringWithFormat:@"%@/%@",TESSERACT_BIN,TESSERACT_BIN_UNICHARSET];
        NSMutableArray *boxArray = [NSMutableArray array];
        for (NSString *obj in finderFiles)
        {
            NSArray *array = [obj componentsSeparatedByString:@"."];
            [boxArray addObject:[NSString stringWithFormat:@"%@.%@.%@.box",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]]];
        }
        NSTask *task = [[NSTask alloc] init];
        NSMutableArray *arrayPath = [NSMutableArray arrayWithArray:[[finderFiles objectAtIndex:0] componentsSeparatedByString:@"/"]];
        [arrayPath removeLastObject];
        NSMutableString *dirPath = [NSMutableString stringWithString:@"/"];
        for (NSString *obj in arrayPath)
        {
            [dirPath appendString:obj];
            [dirPath appendString:@"/"];
        }
        [task setCurrentDirectoryPath:dirPath];        
        [task setLaunchPath:unicharsetPath];
        [task setArguments:boxArray];
        [task launch];
        [task waitUntilExit];
        [task release];
        
        // 创建font_properties
        NSMutableString *fontProperties = [NSMutableString string];
        for (NSInteger i = 0; i < [finderFiles count]; i++)
        {
            [fontProperties appendFormat:@"%@%d 0 0 0 0 0\n",[TRBoxSettting sharedTRBoxSetting].font,i];
        }
        [fontProperties writeToFile:[dirPath stringByAppendingString:@"font_properties"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        // (mftraining -F font_properties -U unicharset -O lang.unicharset lang.fontname.exp0.tr lang.fontname.exp1.tr...)
        // 训练1
        NSString *mftrainingPath = [NSString stringWithFormat:@"%@/%@",TESSERACT_BIN,TESSERACT_BIN_MFTRAINING];
        NSMutableArray *mfArgs = [NSMutableArray array];
        [mfArgs addObject:@"-F"];
        [mfArgs addObject:@"font_properties"];
        [mfArgs addObject:@"-U"];
        [mfArgs addObject:@"unicharset"];
        [mfArgs addObject:@"-O"];
        [mfArgs addObject:[NSString stringWithFormat:@"%@.unicharset",[TRBoxSettting sharedTRBoxSetting].lang]];
        for (NSString *obj in finderFiles)
        {
            NSArray *array = [obj componentsSeparatedByString:@"."];
            [mfArgs addObject:[NSString stringWithFormat:@"%@.%@.%@.tr",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]]];
        }
        NSTask *mfTask = [[NSTask alloc] init];
        [mfTask setCurrentDirectoryPath:dirPath];
        [mfTask setLaunchPath:mftrainingPath];
        [mfTask setArguments:mfArgs];
        [mfTask launch];
        [mfTask waitUntilExit];
        [mfTask release];
        
        // cntraining share.arial.exp0.tr share.arial.exp1.tr ...
        // 训练2
        NSString *cntrainingPath = [NSString stringWithFormat:@"%@/%@",TESSERACT_BIN,TESSERACT_BIN_CNTRAINING];
        NSMutableArray *cnArgs = [NSMutableArray array];
        for (NSString *obj in finderFiles)
        {
            NSArray *array = [obj componentsSeparatedByString:@"."];
            [cnArgs addObject:[NSString stringWithFormat:@"%@.%@.%@.tr",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]]];
        }
        NSTask *cnTask = [[NSTask alloc] init];
        [cnTask setCurrentDirectoryPath:dirPath];
        [cnTask setLaunchPath:cntrainingPath];
        [cnTask setArguments:cnArgs];
        [cnTask launch];
        [cnTask waitUntilExit];
        [cnTask release];
        
        // 重命名文件inttemp为share.inttemp，Microfeat为share.Microfeat，pffmtable为share.pffmtable，normproto为share.normproto
        NSData *inttemp = [NSData dataWithContentsOfFile:[dirPath stringByAppendingString:@"/inttemp"]];
        [inttemp writeToFile:[dirPath stringByAppendingFormat:@"/%@.inttemp",[TRBoxSettting sharedTRBoxSetting].lang] atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:[dirPath stringByAppendingString:@"/inttemp"] error:nil];
        
        NSData *Microfeat = [NSData dataWithContentsOfFile:[dirPath stringByAppendingString:@"/Microfeat"]];
        [Microfeat writeToFile:[dirPath stringByAppendingFormat:@"/%@.Microfeat",[TRBoxSettting sharedTRBoxSetting].lang] atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:[dirPath stringByAppendingString:@"/Microfeat"] error:nil];
        
        NSData *pffmtable = [NSData dataWithContentsOfFile:[dirPath stringByAppendingString:@"/pffmtable"]];
        [pffmtable writeToFile:[dirPath stringByAppendingFormat:@"/%@.pffmtable",[TRBoxSettting sharedTRBoxSetting].lang] atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:[dirPath stringByAppendingString:@"/pffmtable"] error:nil];
        
        NSData *normproto = [NSData dataWithContentsOfFile:[dirPath stringByAppendingString:@"/normproto"]];
        [normproto writeToFile:[dirPath stringByAppendingFormat:@"/%@.normproto",[TRBoxSettting sharedTRBoxSetting].lang] atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:[dirPath stringByAppendingString:@"/normproto"] error:nil];
        
        // 合并训练库
        NSString *combinePath = [NSString stringWithFormat:@"%@/%@",TESSERACT_BIN,TESSERACT_BIN_COMBINE];
        NSTask *combineTask = [[NSTask alloc] init];
        [combineTask setCurrentDirectoryPath:dirPath];
        [combineTask setLaunchPath:combinePath];
        [combineTask setArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@.",[TRBoxSettting sharedTRBoxSetting].lang], nil]];
        [combineTask launch];
        [combineTask waitUntilExit];
        [combineTask release];
        break;
    }
    [activity stopAnimation:nil];
    [NSThread exit];
}

- (IBAction)combineConvert:(id)sender 
{
    [activity startAnimation:nil];
    [NSThread detachNewThreadSelector:@selector(convertCombine:) toTarget:self withObject:nil];
}

- (void)convertBox:(id)sender
{
    while (true)
    {
        // 命令行路径
        //tesseract 1.jpg 1 -l chi_sim batch.nochop makebox
        NSString *tesseractPath = [NSString stringWithFormat:@"%@/%@",TESSERACT_BIN,TESSERACT_BIN_TESSERACT];
        for (NSString *obj in finderFiles)
        {
            // 准备参数
            NSArray *array = [obj componentsSeparatedByString:@"."];
            NSMutableArray *args = [NSMutableArray array];
            [args addObject:obj];
            [args addObject:[NSString stringWithFormat:@"%@.%@.%@",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]]];
            [args addObject:@"-l"];
            switch ([TRBoxSettting sharedTRBoxSetting].ocr) 
            {
                case OCR_ENG: 
                    [args addObject:@"eng"];
                    break;
                case OCR_SIM:
                    [args addObject:@"chi_sim"];
                    break;
                case OCR_TRA:
                    [args addObject:@"chi_tra"];
                    break;
                case OCR_CUSTOM:
                    [args addObject:@"share"];
                    break;
                default:
                    break;
            }
            if ([TRBoxSettting sharedTRBoxSetting].isDigits) 
            {
                [args addObject:@"digits"];
            }
            [args addObject:@"batch.nochop"];
            [args addObject:@"makebox"];
            
            // 测试识别
            [NSTask launchedTaskWithLaunchPath:tesseractPath arguments:args];
        }
        break;
    }
    [activity stopAnimation:nil];
    [boxConvertButton setEnabled:NO];
    [combineConvertButton setEnabled:YES];
    [NSThread exit];
}

- (IBAction)boxConvert:(id)sender 
{
    [activity startAnimation:nil];
    [NSThread detachNewThreadSelector:@selector(convertBox:) toTarget:self withObject:nil];
}

- (void)editAction:(id)sender
{
    NSMenuItem *mi = (NSMenuItem*)sender; 
    TRBoxEditController *editWindowController = [[TRBoxEditController alloc] initWithBoxPath:[finderFiles objectAtIndex:mi.tag]];
    [editWindowController setShouldCascadeWindows:YES];
    [[editWindowController window] center];
    [[editWindowController window] makeKeyAndOrderFront:self];
    [windowsArray addObject:editWindowController];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (NSMenu*)tableView:(NSTableView*)tableView menuForEvent:(NSEvent*)event
{
    if (!combineConvertButton.isEnabled)
    {
        return nil;
    }
    NSInteger selectedRow = [tableView rowAtPoint:[tableView convertPoint:[event locationInWindow] fromView:nil]];
    NSMenuItem *sub0 = [[[NSMenuItem alloc] initWithTitle:@"编辑BOX文件" action:@selector(editAction:) keyEquivalent:@"e"] autorelease]; 
    sub0.tag = selectedRow;
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    [menu insertItem:sub0 atIndex:0]; 
    return menu;
}
@end
