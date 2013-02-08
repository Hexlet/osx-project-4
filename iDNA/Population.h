//
//  Population.h
//  iDNA
//
//  Created by Роман Евсеев on 06.01.13.
//  Copyright (c) 2013 Роман Евсеев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"

@interface Population : NSObject

@property NSMutableArray * cells;
@property Cell * goalDNA;
@property (readonly) NSUInteger step;
@property (readonly) NSUInteger count;
@property NSUInteger mutationRate;
@property (readonly) NSUInteger bestMatch;
- (id) initWithCapacity: (NSUInteger) capacity DNALength: (NSUInteger) len;
- (BOOL) evolution;
@end
