//
//  Cell.h
//  iDNA
//
//  Created by Роман Евсеев on 06.01.13.
//  Copyright (c) 2013 Роман Евсеев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cell : NSObject {
    NSMutableArray * DNA;
}

@property (nonatomic, readonly) NSMutableArray * DNA;
@property (readonly) NSUInteger lastDistance;

- (id) initWithCapacity: (NSUInteger) capacity;
- (id) initWithString: (NSString *) string;
+ (Cell *) cellWithString: (NSString *) string;

- (NSUInteger) hammingDistance: (Cell *) cell;
- (void) mutate: (NSUInteger) percent;

+(NSString *) mixMethod1: (NSString *) stringOne withString: (NSString *) stringTwo;
+(NSString *) mixMethod2: (NSString *) stringOne withString: (NSString *) stringTwo;
+(NSString *) mixMethod3: (NSString *) stringOne withString: (NSString *) stringTwo;

+ (NSArray *) getElements;
+ (NSString *) randomElementWithout: (NSString *) element;

+ (NSString *) mixString: (NSString *) stringOne withString: (NSString *) stringTwo;

@end
