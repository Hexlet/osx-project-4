//
//  Cell.h
//  Project1_DNA
//
//  Created by Alexander on 06.11.12.
//  Copyright (c) 2012 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cell : NSObject{
    NSArray *variety;
}
@property NSMutableArray *DNA;
-(int)hammingDistance:(Cell*)cell;
-(id)initWithLength:(int)length;
@end

@interface Cell (mutator)
-(void)mutator:(int)percent;
@end