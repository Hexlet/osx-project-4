//
//  Cell.h
//  macosx-hw1
//
//  Created by Admin on 17.11.12.
//  Copyright (c) 2012 Kabest. All rights reserved.
//

@interface Cell : NSObject {
    int capacity;
}
+(NSArray*)dhaChars;
@property NSMutableArray* dna;
-(id)initWithCapacity:(NSInteger)val;
-(NSInteger)capacity;
-(NSString*)stringValue;
-(void)setStringValue:(NSString*)val;
-(int)hammingDistance:(Cell*) cell;
-(void)mutateDNA:(NSUInteger)percentage;
-(Cell*)crossBreedingWith:(Cell*)cell;
@end
