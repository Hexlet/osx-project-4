//
//  Cell.h
//  dna
//
//  Created by Igor Pavlov on 02.11.12.
//  Copyright (c) 2012 Igor Pavlov. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Cell : NSObject <NSCopying, NSCoding>
{
    NSString  *dna;
}

+ (NSString*) getNucleotides;

- (id)          init __attribute__((unavailable("init not available")));
- (id)          initWithSize:(NSUInteger)size;
- (id)          initWithDnaString:(NSString*)dnaStr;
- (NSUInteger)  hammingDistance:(Cell*)otherCell;

@end
