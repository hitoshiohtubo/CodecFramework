//
//  NSStringCodecExtension.m
//
//  Created by hitoshi ohtubo on 11/07/28.
//  Copyright 2011 hitoshi ohtubo. All rights reserved.
//

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NSStringCodecExtension.h"

#import "NSDataCodecExtension.h"

@implementation NSString (NSStringCodecExtension)

- (NSString *)encodeBase64URLSafeString
{
    if ([self length] == 0) {
        return [NSString string];
    }
    return [[self dataUsingEncoding:NSUTF8StringEncoding] encodeBase64URLSafeString];
}

- (NSString *)encodeBase64URLSafeSubstringWithLength:(NSUInteger)length
{
    if (length == 0) {
        return [NSString string];
    }
    NSRange rng = NSMakeRange(0, MIN([self length], length));
    rng = [self rangeOfComposedCharacterSequencesForRange:rng];
    return [[self substringWithRange:rng] encodeBase64URLSafeString];
}

- (NSData *)decodeBase64
{
    if ([self length] == 0) {
        return [NSData data];
    }
    return [[self dataUsingEncoding:NSUTF8StringEncoding] decodeBase64];
}

@end
