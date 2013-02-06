//
//  Cell.h
//  DNAProject
//
//  Created by alex on 31/10/2012.
//  Copyright (c) 2012 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DNAChangeNotification;

@interface Cell : NSObject {
    NSArray *DNAElements; // A, T, G и C
}

@property NSMutableArray *DNA;
@property Cell *rootCell;
@property int hammingDistanceToRootCell;


-(id) init;
-(id) initWithSize: (NSInteger) size;
-(id) initWithSize: (NSInteger) size andRootCell:(Cell*)cell;
-(id) initWithString: (NSString*) string;
-(void) populateForSize: (NSInteger) size;
-(void) populateWithString: (NSString*) string;
-(int) hammingDistance: (Cell*) cell;
-(NSString*) asString;
-(NSComparisonResult)compareWithCell:(Cell*) cell;
-(id)combineWith:(Cell*) cell withWay:(int)n;

+(id) copyCell: (Cell*) cell;

@end

@interface Cell (mutator)

-(void) mutate: (NSInteger)X;

@end
