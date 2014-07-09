//
//  TRBoxSettting.m
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TRBoxSettting.h"

static TRBoxSettting *instance = nil;
@implementation TRBoxSettting
@synthesize font,lang,ocr,isDigits,isConvertGray;

+ (TRBoxSettting*)sharedTRBoxSetting
{
    if (instance == nil)
    {
        instance = [TRBoxSettting new];
    }
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.ocr = OCR_ERROR;
        self.font = nil;
        self.lang = nil;
        self.isDigits = NO;
        self.isConvertGray = NO;
    }
    return self;
}

- (void)dealloc
{
    self.font = nil;
    self.lang = nil;
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"lang:%@ font:%@ ocr:%d digits:%d gray:%d",self.lang,self.font,self.ocr,self,isDigits,self.isConvertGray];
}

@end
