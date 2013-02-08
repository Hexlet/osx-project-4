//
//  Cell.h
//  iDNA3
//

#import <Foundation/Foundation.h>

@interface Cell : NSObject
{
    NSInteger previousLength;

}

@property NSMutableString *nucleo;
@property int humming;

- (Cell *)initWithDNALength:(NSInteger)length;
- (Cell *)initWithDNAString:(NSString *)string;
- (Cell *)initWithBaseCell:(Cell *)base andMutationPercents:(int)percents;
- (void)changeDNALength:(NSInteger)length;
- (void)changeDNAString:(NSString *)string;
- (NSString *)DNAString;
- (void)mutateWithBaseCell:(Cell *)base andMutationPercents:(int)percents;
- (void)mutateWithPercents:(int)percents;
- (void)matingWithParrentA:(Cell *)parentA andParrentB:(Cell *)parentB;
+ (NSMutableArray *)sort:(NSMutableArray *)array;
- (int)hummingDistance:(Cell *)base;

@end
