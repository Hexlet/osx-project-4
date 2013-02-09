//
//  IntegerValueFormatter.m
//  iDNA
//
//  Created by Alexander Shvets on 06.01.13.
//  Copyright (c) 2013 Alexander Shvets. All rights reserved.
//

#import "IntegerValueFormatter.h"

@implementation IntegerValueFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    
    if([partialString length] == 0) *newString = @"0";

    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end
