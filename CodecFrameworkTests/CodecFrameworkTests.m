//
//  CodecFrameworkTests.m
//  CodecFrameworkTests
//
//  Created by hitoshi ohtubo on 11/08/07.
//  Copyright 2011 hitoshi ohtubo. All rights reserved.
//

#import "CodecFrameworkTests.h"
#import "Codec.h"
#import "NSStringHashExtension.h"

@implementation CodecFrameworkTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEncodeBase64NoChunkedNoURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *resultstr = @"YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjAxMjM0NTY3ODk=";
    NSData *testdata = [testdatastr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *resultdata = [resultstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encdata = [testdata encodeBase64:NO urlSafe:NO];
    
    STAssertTrue([resultdata isEqualToData:encdata], @"encode error");
}

- (void)testEncodeBase64ChunkedNoURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *resultstr = [NSString stringWithFormat:@"%@\r\n%@\r\n",@"YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjAxMjM0",@"NTY3ODk="];
    NSData *testdata = [testdatastr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *resultdata = [resultstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encdata = [testdata encodeBase64:YES urlSafe:NO];
    
    STAssertTrue([resultdata isEqualToData:encdata], @"encode error");
}

- (void)testEncodeBase64SHANoChunkedNoURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *resultstr = @"4mt9rvQ2YSj8euP7dfMXia4DZIxhuRGSrGz/tJJKHOU8B2j+IdqrY19a66p/0RKzJf1qMnFZJsPXPRrDHmQxpQ==";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *resultdata = [resultstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encdata = [testdata encodeBase64:NO urlSafe:NO];
    
    STAssertTrue([resultdata isEqualToData:encdata], @"encode error");
}

- (void)testEncodeBase64SHANoChunkedURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *resultstr = @"4mt9rvQ2YSj8euP7dfMXia4DZIxhuRGSrGz_tJJKHOU8B2j-IdqrY19a66p_0RKzJf1qMnFZJsPXPRrDHmQxpQ";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *resultdata = [resultstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encdata = [testdata encodeBase64:NO urlSafe:YES];
    
    STAssertTrue([resultdata isEqualToData:encdata], @"encode error");
}

- (void)testEncodeBase64SHAChunkedURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *resultstr = [NSString stringWithFormat:@"%@\r\n%@\r\n", @"4mt9rvQ2YSj8euP7dfMXia4DZIxhuRGSrGz_tJJKHOU8B2j-IdqrY19a66p_0RKzJf1qMnFZJsPX",@"PRrDHmQxpQ"];
    NSData *testdata = [testdatastr hashSHA512];
    NSData *resultdata = [resultstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encdata = [testdata encodeBase64:YES urlSafe:YES];
    
    STAssertTrue([resultdata isEqualToData:encdata], @"encode error");
}

- (void)testEncodeBase64NoData
{
    NSData *emptydata = [NSData data];
    NSData *encdata = [emptydata encodeBase64:NO urlSafe:NO];
    
    STAssertTrue([encdata length] == 0, @"encode error");
}

- (void)testDecodeBase64SHANoChunkedNoURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *encdata = [testdata encodeBase64:NO urlSafe:NO];
    NSData *decdata = [encdata decodeBase64];
    
    STAssertTrue([testdata isEqualToData:decdata], @"decode error");
}

- (void)testDecodeBase64SHAChunkedNoURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *encdata = [testdata encodeBase64:YES urlSafe:NO];
    NSData *decdata = [encdata decodeBase64];
    
    STAssertTrue([testdata isEqualToData:decdata], @"decode error");
}

- (void)testDecodeBase64SHANoChunkedURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *encdata = [testdata encodeBase64:NO urlSafe:YES];
    NSData *decdata = [encdata decodeBase64];
    
    STAssertTrue([testdata isEqualToData:decdata], @"decode error");
}

- (void)testDecodeBase64SHAChunkedURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *encdata = [testdata encodeBase64:YES urlSafe:YES];
    NSData *decdata = [encdata decodeBase64];
    
    STAssertTrue([testdata isEqualToData:decdata], @"decode error");
}

- (void)testDecodeBase64NoData
{
    NSData *emptydata = [NSData data];
    NSData *decdata = [emptydata decodeBase64];
    
    STAssertTrue([decdata length] == 0, @"decode error");
}

- (void)testIsBase64Success
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *encdata = [testdata encodeBase64:YES urlSafe:NO];
    
    STAssertTrue([encdata isBase64], @"isBase64 error");
}

- (void)testIsBase64SuccessURLSafe
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSData *testdata = [testdatastr hashSHA512];
    NSData *encdata = [testdata encodeBase64:NO urlSafe:YES];
    
    STAssertTrue([encdata isBase64], @"isBase64 error");
}

- (void)testIsBase64Fail
{
    char chardata[16] = {0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf};
    NSData *testdata = [NSData dataWithBytes:chardata length:16];
    
    STAssertFalse([testdata isBase64], @"isBase64 error");
}

- (void)testEncodeHex
{
    char chardata[16] = {0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf};
    char charresultdata[32] = {'0','0','0','1','0','2','0','3','0','4','0','5','0','6','0','7','0','8','0','9','0','A','0','B','0','C','0','D','0','E','0','F'};
    NSData *testdata = [NSData dataWithBytes:chardata length:16];
    NSData *resultdata = [NSData dataWithBytes:charresultdata length:32];
    NSData *encdata = [testdata encodeHex:NO];
    
    STAssertTrue([resultdata isEqualToData:encdata], @"encode error");
}

- (void)testEncodeHexLowCase
{
    char chardata[16] = {0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf};
    char charresultdata[32] = {'0','0','0','1','0','2','0','3','0','4','0','5','0','6','0','7','0','8','0','9','0','a','0','b','0','c','0','d','0','e','0','f'};
    NSData *testdata = [NSData dataWithBytes:chardata length:16];
    NSData *resultdata = [NSData dataWithBytes:charresultdata length:32];
    NSData *encdata = [testdata encodeHex:YES];
    
    STAssertTrue([resultdata isEqualToData:encdata], @"encode error");
}

- (void)testEncodeHexNoData
{
    NSData *emptydata = [NSData data];
    NSData *encdata = [emptydata encodeHex:NO];
    
    STAssertTrue([encdata length] == 0, @"encode error");
}

- (void)testDecodeHex
{
    char chardata[16] = {0x0,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff};
    NSData *testdata = [NSData dataWithBytes:chardata length:16];
    NSData *encdata = [testdata encodeHex:NO];
    NSData *decdata = [encdata decodeHex];
    
    STAssertTrue([testdata isEqualToData:decdata], @"decode error");
}

- (void)testDecodeHexNoData
{
    NSData *emptydata = [NSData data];
    NSData *decdata = [emptydata decodeHex];
    
    STAssertTrue([decdata length] == 0, @"decode error");
}

- (void)testDecodeHexFailLengthOdd
{
    char charresultdata[31] = {'0','0','0','1','0','2','0','3','0','4','0','5','0','6','0','7','0','8','0','9','0','a','0','b','0','c','0','d','0','e','0'};
    NSData *encdata = [NSData dataWithBytes:charresultdata length:31];
    
    STAssertThrows([encdata decodeHex], @"decode error");
}

- (void)testDecodeHexFailIllegalChar
{
    char charresultdata[32] = {'0','0','0','1','0','2','0','3','0','4','0','5','0','6','0','7','0','8','0','9','0','a','0','b','0','c','0','d','0','e','0',0xff};
    NSData *encdata = [NSData dataWithBytes:charresultdata length:32];
    
    STAssertThrows([encdata decodeHex], @"decode error");
}

- (void)testEncodeBase64URLSafeSubstringWithLength
{
    NSString *testdatastr = @"0123456789";
    NSInteger length = 5;
    NSRange rng = NSMakeRange(0, MIN([testdatastr length], length));
    rng = [testdatastr rangeOfComposedCharacterSequencesForRange:rng];
    NSString *testdatasubstr = [testdatastr substringWithRange:rng];
    
    NSString *encdata = [testdatastr encodeBase64URLSafeSubstringWithLength:5];
    NSData *decdata = [encdata decodeBase64];
    
    NSString *decdatastr = [[[NSString alloc] initWithData:decdata encoding:NSUTF8StringEncoding] autorelease];
    
    STAssertTrue([testdatasubstr isEqualToString:decdatastr],@"encodebase64urlsafesubstring error");
}

- (void)testEncodeBase64URLSafeSubstringWithLengthZen
{
    NSString *testdatastr = @"０１２３４５６７８９";
    NSInteger length = 5;
    NSRange rng = NSMakeRange(0, MIN([testdatastr length], length));
    rng = [testdatastr rangeOfComposedCharacterSequencesForRange:rng];
    NSString *testdatasubstr = [testdatastr substringWithRange:rng];
    
    NSString *encdata = [testdatastr encodeBase64URLSafeSubstringWithLength:5];
    NSData *decdata = [encdata decodeBase64];
    
    NSString *decdatastr = [[[NSString alloc] initWithData:decdata encoding:NSUTF8StringEncoding] autorelease];
    
    STAssertTrue([testdatasubstr isEqualToString:decdatastr],@"encodebase64urlsafesubstring error");
}

- (void)testEncodeBase64URLSafeSubstringWithLengthMix
{
    NSString *testdatastr = @"０1２３４５６７８９";
    NSInteger length = 5;
    NSRange rng = NSMakeRange(0, MIN([testdatastr length], length));
    rng = [testdatastr rangeOfComposedCharacterSequencesForRange:rng];
    NSString *testdatasubstr = [testdatastr substringWithRange:rng];
    
    NSString *encdata = [testdatastr encodeBase64URLSafeSubstringWithLength:5];
    NSData *decdata = [encdata decodeBase64];
    
    NSString *decdatastr = [[[NSString alloc] initWithData:decdata encoding:NSUTF8StringEncoding] autorelease];
    
    STAssertTrue([testdatasubstr isEqualToString:decdatastr],@"encodebase64urlsafesubstring error");
}

- (void)testEncodeBase64URLSafeSubstringWithLengthZenShort
{
    NSString *testdatastr = @"２３４5";
    NSInteger length = 5;
    NSRange rng = NSMakeRange(0, MIN([testdatastr length], length));
    rng = [testdatastr rangeOfComposedCharacterSequencesForRange:rng];
    NSString *testdatasubstr = [testdatastr substringWithRange:rng];
    
    NSString *encdata = [testdatastr encodeBase64URLSafeSubstringWithLength:5];
    NSData *decdata = [encdata decodeBase64];
    
    NSString *decdatastr = [[[NSString alloc] initWithData:decdata encoding:NSUTF8StringEncoding] autorelease];
    
    STAssertTrue([testdatasubstr isEqualToString:decdatastr],@"encodebase64urlsafesubstring error");
}

- (void)testEncodeBase64URLSafeSubstringWithLengthZenShort2
{
    NSString *testdatastr = @"1";
    NSInteger length = 18;
    NSRange rng = NSMakeRange(0, MIN([testdatastr length], length));
    rng = [testdatastr rangeOfComposedCharacterSequencesForRange:rng];
    NSString *testdatasubstr = [testdatastr substringWithRange:rng];
    
    NSString *encdata = [testdatastr encodeBase64URLSafeSubstringWithLength:18];
    NSData *decdata = [encdata decodeBase64];
    
    NSString *decdatastr = [[[NSString alloc] initWithData:decdata encoding:NSUTF8StringEncoding] autorelease];
    
    STAssertTrue([testdatasubstr isEqualToString:decdatastr],@"encodebase64urlsafesubstring error");
}

- (void)testEncodeBase64URLSafeSubstringWithLengthZenShort3
{
    NSString *testdatastr = @"１";
    NSInteger length = 18;
    NSRange rng = NSMakeRange(0, MIN([testdatastr length], length));
    rng = [testdatastr rangeOfComposedCharacterSequencesForRange:rng];
    NSString *testdatasubstr = [testdatastr substringWithRange:rng];
    
    NSString *encdata = [testdatastr encodeBase64URLSafeSubstringWithLength:18];
    NSData *decdata = [encdata decodeBase64];
    
    NSString *decdatastr = [[[NSString alloc] initWithData:decdata encoding:NSUTF8StringEncoding] autorelease];
    
    STAssertTrue([testdatasubstr isEqualToString:decdatastr],@"encodebase64urlsafesubstring error");
}

- (void)testHashSHA512EncodeBase64
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyz";
    NSString *resultstr = @"Tb/4bMLKG64eFkaKBcuYgcl/F1O842GQNImPqhqr5CmVWhv47Eg9dCH+PBZGYTpZ7VRB+w8yE4n3f0ioecex8Q==";
    NSString *encdata = [testdatastr hashSHA512EncodeBase64];
    
    STAssertTrue([resultstr isEqualToString:encdata],@"hashshaencode64 error");
}

- (void)testHashMD5EncodeBase64
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyz";
    NSString *resultstr = @"w/zT12GS5AB9+0lsymfhOw==";
    NSString *encdata = [testdatastr hashMD5EncodeBase64];
    
    STAssertTrue([resultstr isEqualToString:encdata],@"hashshaencode64 error");
}

- (void)testHashSHA1EncodeBase64
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyz";
    NSString *resultstr = @"MtEMe4z5ZXDKBM438qGdhCQNOok=";
    NSString *encdata = [testdatastr hashSHA1EncodeBase64];
    
    STAssertTrue([resultstr isEqualToString:encdata],@"hashshaencode64 error");
}

- (void)testHashSHA256EncodeBase64
{
    NSString *testdatastr = @"abcdefghijklmnopqrstuvwxyz";
    NSString *resultstr = @"ccSA35PWri8e+tFEfGbJUl4xYhjPUfyNntgy8trxi3M=";
    NSString *encdata = [testdatastr hashSHA256EncodeBase64];
    
    STAssertTrue([resultstr isEqualToString:encdata],@"hashshaencode64 error");
}

@end
