//
//  NSString+Addition.h
//  Hiyiqi
//
//  Created by Noah on 6/30/14.
//  Copyright (c) 2014 Noah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Addition)
- (instancetype)urlencode;
- (instancetype)removeLineBreakAndSpace;
//- (NSString *)md5Encrypt;
- (instancetype)getMd5_32Bit_String;
- (instancetype)replacingNewLine;
- (NSURL *)toURL;
+ (NSString *)getOffRubbishWithString:(NSString *)str;
@end
