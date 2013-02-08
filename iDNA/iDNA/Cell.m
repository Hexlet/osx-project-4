#import "Cell.h"
#import "NucleobaseType.h"

@implementation Cell

-(id) initWithDNA:(NSMutableArray *)dna {
    self = [super init];
    if (self) {
        _dna = dna;
    }
    return self;
}

-(id) initWithRandomDNAOfLength:(NSInteger)length {
    self = [super init];
    if (self) {
        _dna = [NSMutableArray arrayWithCapacity:length];
        for (int i = 0; i < length; i++) {
            [_dna addObject: [NucleobaseType random]];
        }
    }
    return self;
}

-(NSString*) description {
    return [_dna componentsJoinedByString:@""];
}

-(int) hammingDistance:(Cell *)otherCell {
    int distance = 0;
    NSString* myNucleobaceType;
    NSString* otherCellsNucleobaseType;
    
    for (int i = 0; i < _dna.count; i++) {
        myNucleobaceType = [_dna objectAtIndex:i];
        otherCellsNucleobaseType = [otherCell.dna objectAtIndex:i];
        if ([myNucleobaceType isEqualToString:otherCellsNucleobaseType] == NO) {
            distance++;
        }
    }
    
    return distance;
}

-(NSString *)nucleobaseAtIndex:(NSInteger)index {
    return [_dna objectAtIndex:index];
}

-(void)mutate:(NSInteger)percent {
    NSMutableArray* mutationPositionsMask = [self createMutationPositionsMask: percent];
    for (int i = 0; i < [mutationPositionsMask count]; i++) {
        if ([[mutationPositionsMask objectAtIndex:i] boolValue]) {
            NSString* replacement = [NucleobaseType randomExcluding:[self.dna objectAtIndex:i]];
            [self.dna replaceObjectAtIndex:i withObject: replacement];
        }
    }
}

-(NSMutableArray*)createMutationPositionsMask:(NSInteger)percent {
    
    int totalPositionsCount = (int)[self.dna count];
    int mutationPositionsCount = (int)(totalPositionsCount * percent / 100);
    
    NSMutableArray* positions = [[NSMutableArray alloc] initWithCapacity:totalPositionsCount];
    
    for (int i = 0; i < totalPositionsCount; i++) {
        [positions addObject: [NSNumber numberWithBool:NO]];
    }
    for (int i = 0; i < mutationPositionsCount; i++) {
        [positions replaceObjectAtIndex:i withObject: [NSNumber numberWithBool:YES]];
    }
    [[self class] shuffle:positions];
    
    return positions;
}

+(void)shuffle:(NSMutableArray*)array {
    for (int i = 0; i < [array count]; i++) {
        int targetPosition = arc4random_uniform((int)[array count]);
        [array exchangeObjectAtIndex:i withObjectAtIndex:targetPosition];
    }
}

@end
