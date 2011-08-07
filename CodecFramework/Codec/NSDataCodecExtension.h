//
//  NSDataCodecExtension.h
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

#import <Foundation/Foundation.h>


@interface NSData (NSDataCodecExtension)
- (BOOL)isBase64;

- (NSData *)encodeBase64:(BOOL)isChunked urlSafe:(BOOL)urlSafe;
- (NSString *)encodeBase64URLSafeString;
- (NSData *)decodeBase64;

- (NSData *)encodeHex:(BOOL)toLowerCase;
- (NSData *)decodeHex;
@end
