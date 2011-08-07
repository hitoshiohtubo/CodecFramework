//
//  NSDataCodecExtension.m
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

#import "NSDataCodecExtension.h"

// original apache commons codec 1.5
// transrate objective-c by hitosh ohtubo

/**
 * BASE64 characters are 6 bits in length. 
 * They are formed by taking a block of 3 octets to form a 24-bit string, 
 * which is converted into 4 BASE64 characters.
 */
static int BITS_PER_UNENCODED_BYTE = 8;
static int BITS_PER_ENCODED_BYTE = 6;
static int BYTES_PER_UNENCODED_BLOCK = 3;
static int BYTES_PER_ENCODED_BLOCK = 4;

/**
 * Chunk separator per RFC 2045 section 2.1.
 *
 * <p>
 * N.B. The next major release may break compatibility and make this field private.
 * </p>
 * 
 * @see <a href="http://www.ietf.org/rfc/rfc2045.txt">RFC 2045 section 2.1</a>
 */
static char CHUNK_SEPARATOR[] = {'\r', '\n'};

/**
 * This array is a lookup table that translates 6-bit positive integer index values into their "Base64 Alphabet"
 * equivalents as specified in Table 1 of RFC 2045.
 * 
 * Thanks to "commons" project in ws.apache.org for this code.
 * http://svn.apache.org/repos/asf/webservices/commons/trunk/modules/util/
 */
static char STANDARD_ENCODE_TABLE[] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

/**
 * This is a copy of the STANDARD_ENCODE_TABLE above, but with + and /
 * changed to - and _ to make the encoded Base64 results more URL-SAFE.
 * This table is only used when the Base64's mode is set to URL-SAFE.
 */    
static char URL_SAFE_ENCODE_TABLE[] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '_'
};

/**
 * This array is a lookup table that translates Unicode characters drawn from the "Base64 Alphabet" (as specified in
 * Table 1 of RFC 2045) into their 6-bit positive integer equivalents. Characters that are not in the Base64
 * alphabet but fall within the bounds of the array are translated to -1.
 * 
 * Note: '+' and '-' both decode to 62. '/' and '_' both decode to 63. This means decoder seamlessly handles both
 * URL_SAFE and STANDARD base64. (The encoder, on the other hand, needs to know ahead of time what to emit).
 * 
 * Thanks to "commons" project in ws.apache.org for this code.
 * http://svn.apache.org/repos/asf/webservices/commons/trunk/modules/util/
 */
static char DECODE_TABLE[] = {
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, 62, -1, 63, 52, 53, 54,
    55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4,
    5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
    24, 25, -1, -1, -1, -1, 63, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34,
    35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51
};

/** Mask used to extract 8 bits, used in decoding bytes */
static int MASK_8BITS = 0xff;

/**
 * Base64 uses 6-bit fields. 
 */
/** Mask used to extract 6 bits, used when encoding */
static int MASK_6BITS = 0x3f;

/**
 *  MIME chunk size per RFC 2045 section 6.8.
 *
 * <p>
 * The {@value} character limit does not count the trailing CRLF, but counts all other characters, including any
 * equal signs.
 * </p>
 *
 * @see <a href="http://www.ietf.org/rfc/rfc2045.txt">RFC 2045 section 6.8</a>
 */
static int MIME_CHUNK_SIZE = 76;

/**
 * Byte used to pad output.
 */
static char PAD = '='; // Allow static access to default

/**
 * Used to build output as Hex
 */
static char DIGITS_LOWER[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

/**
 * Used to build output as Hex
 */
static char DIGITS_UPPER[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

@implementation NSData (NSDataCodecExtension)

- (BOOL)isBase64
{
    if ([self length] == 0) {
        return YES;
    }
    
    BOOL (^isbase64)(char) = ^(char byteToCheck) {
        int length = sizeof(DECODE_TABLE) / sizeof(char);
        BOOL ret = NO;
        if (byteToCheck == PAD || (byteToCheck >= 0 && byteToCheck < length && DECODE_TABLE[byteToCheck] != -1)) {
            ret = YES;
        }
        return ret;
    };
    
    BOOL (^iswhitespace)(char) = ^(char byteToCheck) {
        BOOL ret = NO;
        if (isspace(byteToCheck) && !(byteToCheck == '\v' || byteToCheck == '\f')) {
            ret = YES;
        }
        return ret;
    };
    
    char *inBuffer = (char *)[self bytes];
    NSUInteger length = [self length];
    for (NSUInteger i = 0; i < length; i++) {
        char c = inBuffer[i];
        if (!isbase64(c) && !iswhitespace(c)) {
            return NO;
        }
    }
    return YES;
}

- (NSData *)encodeBase64:(BOOL)isChunked urlSafe:(BOOL)urlSafe
{
    if ([self length] == 0) {
        return [NSData data];
    }
    
    int unencodedBlockSize;
    int encodedBlockSize;
    int lineLength;
    NSData *lineSeparator = nil;
    
    unencodedBlockSize = BYTES_PER_UNENCODED_BLOCK;
    encodedBlockSize = BYTES_PER_ENCODED_BLOCK;
    lineSeparator = [[NSData alloc] initWithBytes:CHUNK_SEPARATOR length:sizeof(CHUNK_SEPARATOR) / sizeof(char)];
    
    if (isChunked) {
        lineLength = (MIME_CHUNK_SIZE / encodedBlockSize ) * encodedBlockSize; 
    }
    else {
        lineLength = 0;
    }
    
    char *encodeTable = urlSafe ? URL_SAFE_ENCODE_TABLE : STANDARD_ENCODE_TABLE;
    
    NSMutableData *encodeBuffer = [NSMutableData data];
    
    int currentLinePos = 0;
    unsigned int bitWorkArea = 0;
    
    char *inBuffer = (char *)[self bytes];
    NSUInteger bufflen = [self length];;
    NSInteger i;
    int b;
    char buffer[encodedBlockSize];
    int modulus = 0;
    
    unsigned int (^encodeTableIndex)(unsigned int,int,int) = ^(unsigned int bits,int total,int idx) {
        int shift = total - (idx + 1) * BITS_PER_ENCODED_BYTE;
        unsigned int ret;
        if (shift > 0) {
            ret = ((bits >> shift) & MASK_6BITS);
        }
        else if (shift == 0) {
            ret = bits & MASK_6BITS;
        }
        else {
            ret = ((bits << (-shift)) & MASK_6BITS);
        }
        return ret;
    };
    
    for (i = 0; i < bufflen; i++) {
        modulus = (modulus + 1) % unencodedBlockSize;
        b = (unsigned char) inBuffer[i];
        bitWorkArea = (bitWorkArea << 8) + b; //  BITS_PER_BYTE
        if (modulus == 0) { // 3 bytes = 24 bits = 4 * 6 bits to extract
            for (int j = 0; j < encodedBlockSize; j++) {
                buffer[j] = encodeTable[encodeTableIndex(bitWorkArea,24,j)];
            }
            [encodeBuffer appendBytes:buffer length:encodedBlockSize];
            currentLinePos += encodedBlockSize;
            if (isChunked && lineLength <= currentLinePos) {
                [encodeBuffer appendData:lineSeparator];
                currentLinePos = 0;
            }
        }
    }
    
    if (modulus > 0) {
        int total = 0;
        int proccnt = 0;
        int totalproccnt = 0;
        switch (modulus) { // 0-2
            case 1 : // 8 bits = 6 + 2
                total = 8;
                break;
                
            case 2 : // 16 bits = 6 + 6 + 4
                total = 16;
                break;
        }
        proccnt = (total / 6) + 1;
        totalproccnt = proccnt;
        // URL-SAFE skips the padding to further reduce size.
        if (!urlSafe) {
            totalproccnt = encodedBlockSize;
        }
        int j;
        for (j = 0; j < proccnt; j++) {
            buffer[j] = encodeTable[encodeTableIndex(bitWorkArea,total,j)];
        }
        // URL-SAFE skips the padding to further reduce size.
        for (; j < totalproccnt; j++) {
            buffer[j] = PAD;
        }
        [encodeBuffer appendBytes:buffer length:totalproccnt];
        currentLinePos += totalproccnt;
    }
    if (isChunked && currentLinePos > 0) {
        [encodeBuffer appendData:lineSeparator];
        currentLinePos = 0;
    }
    [lineSeparator release];
    
    return [NSData dataWithData:encodeBuffer];
}

- (NSString *)encodeBase64URLSafeString
{
    return [[[NSString alloc] initWithData:[self encodeBase64:NO urlSafe:YES] encoding:NSUTF8StringEncoding] autorelease];
}

- (NSData *)decodeBase64
{
    if ([self length] == 0) {
        return [NSData data];
    }
    
    int unencodedBlockSize;
    int encodedBlockSize;
    
    unencodedBlockSize = BYTES_PER_UNENCODED_BLOCK;
    encodedBlockSize = BYTES_PER_ENCODED_BLOCK;
    
    NSMutableData *decodeBuffer = [NSMutableData data];
    int modulus = 0;
    unsigned int bitWorkArea = 0;
    char *inBuffer = (char *)[self bytes];
    NSUInteger bufflen = [self length];
    NSInteger i;
    char b;
    char buffer[unencodedBlockSize];
    int decodeTableLength = sizeof(DECODE_TABLE) / sizeof(char);
    
    char (^decodeValue)(unsigned int,int,int) = ^(unsigned int bits,int total,int idx) {
        int shift = total - idx * BITS_PER_UNENCODED_BYTE;
        char ret;
        if (shift > 0) {
            ret = (char)((bits >> shift) & MASK_8BITS); 
        }
        else {
            ret = (char)(bits & MASK_8BITS); 
        }
        return ret;
    };
    
    for (i = 0; i < bufflen; i++) {
        b = inBuffer[i];
        if (b == PAD) {
            break;
        } else {
            if (b >= 0 && b < decodeTableLength) {
                int result = DECODE_TABLE[b];
                if (result >= 0) {
                    modulus = (modulus+1) % encodedBlockSize;
                    bitWorkArea = (bitWorkArea << BITS_PER_ENCODED_BYTE) + result;
                    if (modulus == 0) {
                        for (int j = 0; j < unencodedBlockSize; j++) {
                            buffer[j] = decodeValue(bitWorkArea,16,j);
                        }
                        [decodeBuffer appendBytes:buffer length:unencodedBlockSize];
                    }
                }
            }
        }
    }
    
    if (modulus != 0) {
        int total = 0;
        int proccnt = 0;
        int j;
        switch (modulus) {
                //   case 1: // 6 bits - ignore entirely
                //       break;
            case 2 : // 12 bits = 8 + 4
                bitWorkArea = bitWorkArea >> 4; // dump the extra 4 bits
                total = 0;
                proccnt = 1;
                break;
            case 3 : // 18 bits = 8 + 8 + 2
                bitWorkArea = bitWorkArea >> 2; // dump 2 bits
                total = 8;
                proccnt = 2;
                break;
        }
        for (j = 0; j < proccnt; j++) {
            buffer[j] = decodeValue(bitWorkArea,total,j);
        }
        if (proccnt > 0) {
            [decodeBuffer appendBytes:buffer length:proccnt];
        }
    }
    return [NSData dataWithData:decodeBuffer];
}

- (NSData *)encodeHex:(BOOL)toLowerCase
{
    if ([self length] == 0) {
        return [NSData data];
    }
    
    char *toDigits = toLowerCase ? DIGITS_LOWER : DIGITS_UPPER;
    NSUInteger length = [self length];
    NSMutableData *encodeBuffer = [NSMutableData data];
    int encodeTmpBuffSize = 2;
    char buffer[encodeTmpBuffSize];
    char *data = (char *)[self bytes];
    
    char (^encodeValue)(unsigned int,int,int) = ^(unsigned int bits,int total,int idx) {
        int shift = total - idx * 4;
        int cidx;
        if (shift > 0) {
            cidx = (bits >> shift) & 0x0F;
        }
        else {
            cidx = bits & 0x0F;
        }
        return toDigits[cidx];
    };
    
    for (NSUInteger i = 0; i < length; i++) {
        unsigned char v = (unsigned char)data[i];
        for (int j = 0; j < encodeTmpBuffSize; j++) {
            buffer[j] = encodeValue(v,4,j);
        }
        [encodeBuffer appendBytes:buffer length:encodeTmpBuffSize];
    }
    return [NSData dataWithData:encodeBuffer];
}

- (NSData *)decodeHex
{
    if ([self length] == 0) {
        return [NSData data];
    }
    
    NSUInteger length = [self length];
    NSAssert((length % 2) == 0, @"Odd number of characters");
    
    NSUInteger i;
    char *data = (char *)[self bytes];
    BOOL chkdg = YES;
    for (i = 0; i < length; i++) {
        int c = data[i];
        if (isxdigit(c) == 0) {
            chkdg = NO;
            break;
        }
    }
    NSAssert(chkdg, @"illegal hexadecimal characters");
    
    NSMutableData *decodeBuffer = [NSMutableData data];
    char cbuf[3] = {0x0,0x0,0x0};
    char cc[1];
    for (i = 0; i < length;) {
        cbuf[0] = data[i++];
        cbuf[1] = data[i++];
        long v = strtol(cbuf, NULL, 16);
        cc[0] = (char)(v & 0xFF);
        [decodeBuffer appendBytes:cc length:1];
    }
    return [NSData dataWithData:decodeBuffer];
}

@end
