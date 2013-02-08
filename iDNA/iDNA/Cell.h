#import <Foundation/Foundation.h>

@interface Cell : NSObject

@property NSMutableArray* dna;

-(id) initWithRandomDNAOfLength:(NSInteger)length;
-(id) initWithDNA:(NSMutableArray *)dna;
-(int) hammingDistance:(Cell*)otherCell;
-(void) mutate:(NSInteger)percent;
-(NSString *) nucleobaseAtIndex:(NSInteger)index;

@end
