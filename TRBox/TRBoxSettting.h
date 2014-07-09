//
//  TRBoxSettting.h
//  TRBox
//
//  Created by hxp on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    OCR_ENG = 0, // 英文
    OCR_SIM = 1, // 简体
    OCR_TRA = 2, // 繁体 
    OCR_CUSTOM = 3,
    OCR_ERROR,   // 无效 
}OCR_TYPE;

@interface TRBoxSettting : NSObject{}
@property(nonatomic,retain)NSString *lang;
@property(nonatomic,retain)NSString *font;
@property(nonatomic,assign)OCR_TYPE ocr;
@property(nonatomic,assign)BOOL isDigits;
@property(nonatomic,assign)BOOL isConvertGray;

+ (TRBoxSettting*)sharedTRBoxSetting;
@end
