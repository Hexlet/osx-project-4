//
//  IDNCell.h
//  IDNA
//
//  Created by Dmitriy Zhukov on 07.01.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDNCell : NSObject

@property NSMutableArray *DNA;
@property NSString *rangeOfDNACellValues;
@property NSInteger arrayCapacity;
@property NSInteger unitDistanceToTargetDNA;

- (id)initWithRandom:(unsigned int)r;
- (void) fillDNAArrayWithCapacity: (NSInteger)fCapacity;
- (NSInteger) hammingDistance: (IDNCell*) anotherDNA;
- (void) mutate: (NSInteger) procentageOfMutations;

@end
