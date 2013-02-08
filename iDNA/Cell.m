//
//  Cell.m
//  iDNA
//
//  Created by Роман Евсеев on 06.01.13.
//  Copyright (c) 2013 Роман Евсеев. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (id) initWithCapacity:(NSUInteger)capacity {
    if (self = [super init]) {
        DNA = [[NSMutableArray alloc] initWithCapacity:capacity];
        for (int i=0; i<capacity; i++) {
            [DNA addObject:[Cell randomElementWithout:@""]];
        }
    }
    return self;
}

- (id) initWithString:(NSString *)string {
    if (self = [super init]) {
        DNA = [[NSMutableArray alloc] initWithCapacity:[string length]];
        for (int i=0; i<[string length]; i++) {
            [DNA addObject:[string substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return self;
}

+ (Cell *) cellWithString:(NSString *)string {
    return [[Cell alloc] initWithString:string];
}

- (NSString *)description {
    return [DNA componentsJoinedByString:@""];
}

- (NSUInteger) hammingDistance:(Cell *)cell {
    int diffCount = 0;
    
    for (int i=0; i<[DNA count]; i++) {
        if ([DNA objectAtIndex:i] != [cell.DNA objectAtIndex:i]) {
            diffCount++;
        }
    }
    _lastDistance = diffCount;
    return diffCount;
}

- (void)mutate:(NSUInteger)percent {
    if (percent>100) {
        [NSException raise:@"Invalid value" format:@"Value must be in range [0..100]"];
    }
    NSMutableSet * positions = [[NSMutableSet alloc] init];
    int X = [DNA count]*percent/100;
    
    while ([positions count]<X) {
        [positions addObject:[NSNumber numberWithInt:arc4random() % [DNA count]]];
    }
    
    for(NSNumber * pos in positions) {
        [DNA replaceObjectAtIndex:[pos integerValue] withObject:[Cell randomElementWithout:[DNA objectAtIndex:[pos integerValue]]]];
    }
}

-(NSMutableArray *)DNA {
    return [NSArray arrayWithArray:DNA];
}

+ (NSArray *)getElements {
    return [NSArray arrayWithObjects:@"A", @"T", @"G", @"C", nil];
}

+ (NSString *)randomElementWithout:(NSString *)element {
    NSMutableArray * elements = [NSMutableArray arrayWithArray:[Cell getElements]];
    if ([elements containsObject:element]) {
        [elements removeObject:element];
    }
    return [elements objectAtIndex: arc4random() % [elements count]];
}

+(NSString *)mixMethod1:(NSString *)stringOne withString:(NSString *)stringTwo {
    NSUInteger delim = [stringOne length] / 2;
    return [NSString stringWithFormat:@"%@%@",
            [stringOne substringToIndex:delim],
            [stringTwo substringFromIndex:delim]];
}

+(NSString *)mixMethod2:(NSString *)stringOne withString:(NSString *)stringTwo {
    NSString * s = @"";
    for (int i=0; i<[stringOne length]; i++) {
        s = [s stringByAppendingFormat:@"%c", [i%2==0?stringTwo:stringOne characterAtIndex:i]];
    }
    return s;
}

+(NSString *)mixMethod3:(NSString *)stringOne withString:(NSString *)stringTwo {
    NSUInteger delim1 = [stringOne length] * 20 / 100;
    NSUInteger delim2 = [stringOne length] * 80 / 100;
    return [NSString stringWithFormat:@"%@%@%@",
            [stringOne substringToIndex:delim1],
            [stringTwo substringWithRange:NSMakeRange(delim1, delim2 - delim1)],
            [stringOne substringFromIndex:delim2]];
}

+ (NSString *) mixString:(NSString *)stringOne withString:(NSString *)stringTwo {
    int mixMethod = arc4random() % 3;
    NSString * s;
    NSUInteger len = [stringOne length];
    
    if (len == [stringTwo length]) {
        switch (mixMethod) {
            case 0:
                s = [Cell mixMethod1:stringOne withString:stringTwo];
                break;
            case 1:
                s = [Cell mixMethod2:stringOne withString:stringTwo];
                break;
            default:
                s = [Cell mixMethod3:stringOne withString:stringTwo];
                break;
        }
        if ([s length]!= len)
            NSLog(@"Error!!! method %i", mixMethod);
        return s;
    } else return stringOne;
}

@end
