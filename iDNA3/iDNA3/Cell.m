//
//  Cell.m
//  iDNA3
//

#import "Cell.h"

@implementation Cell

@synthesize nucleo;
@synthesize humming;

char nucleoBase[] = {'A', 'C', 'G', 'T'};

- (Cell *)initWithDNALength:(NSInteger)length
{
    if (self = [super init])
    {
        previousLength = 0;
        
        [self changeDNALength:length];
    }
    
    return self;
}

- (Cell *)initWithBaseCell:(Cell *)base andMutationPercents:(int)percents
{
    if (self = [super init])
    {
        const char *DNAArray = [[base DNAString] UTF8String];
        int DNALength = (int)[[base DNAString] length];
        char temp[DNALength];
        BOOL mut[DNALength];
        BOOL fill;
        int i, j;
        char n;
        
        if (percents <= 0) return [NSMutableString stringWithUTF8String:DNAArray];
        
        percents = percents > 100 ? 100 : percents;
        
        if (percents > 50)
        {
            fill = TRUE;
            percents = 100 - percents;
        }
        else fill = FALSE;
        
        for (i = 0; i < DNALength; i++) mut[i] = fill;
        
        i = 0;
        
        while (i < (int)round(DNALength * percents /100.0))
        {
            j = arc4random() % DNALength;
            
            if (mut[j] == fill)
            {
                mut[j] = !fill;
                i++;
            }
        }
        
        for (i = 0; i < DNALength; i++)
        {
            n = DNAArray[i];
            
            if (mut[i])
            {
                do
                    n = nucleoBase[arc4random() % 4];
                while (n == DNAArray[i]);
            }
            
            temp[i] = n;
        }
        
        temp[DNALength] = '\0';
        
        nucleo = [NSMutableString stringWithUTF8String:temp];
        humming = [self hummingDistance:base];
        
    }
    
    return self;
}

- (Cell *)initWithDNAString:(NSString *)string
{
    if (self = [super init]) nucleo = [NSMutableString stringWithString:string];
    
    return self;
}

- (void)changeDNALength:(NSInteger)length
{
    if (previousLength != length)
    {
        if (previousLength < length)
        {
            char temp[(unsigned)(length - previousLength)];
            
            for (unsigned i = 0; i < length - previousLength; temp[i++] = nucleoBase[arc4random() % 4])
                
                temp[(unsigned)(length - previousLength)]='\0';
            
            if (previousLength == 0) nucleo = [NSMutableString stringWithUTF8String:temp];
            else [nucleo appendString:[NSMutableString stringWithUTF8String:temp]];
        }
        else
        {
            [nucleo setString:[nucleo substringToIndex:length]];
        }
        
        previousLength = length;

    }
}

- (void)changeDNAString:(NSString *)string
{
    [nucleo setString:string];
    
}

- (NSString *) DNAString
{
    return [self nucleo];
}

- (void)mutateWithBaseCell:(Cell *)base andMutationPercents:(int)percents
{
    
}

- (void)mutateWithPercents:(int)percents
{
    
}

- (void)matingWithParrentA:(Cell *)parentA andParrentB:(Cell *)parentB
{
    const char *arrayA = [[parentA DNAString] UTF8String];
    const char *arrayB = [[parentB DNAString] UTF8String];
    
    int DNALength = (int)[[parentA DNAString] length];
    
    char child[DNALength];

    int matingCase = arc4random() % 5;
    
    switch (matingCase)
    {
        case 0: for(int i = 0; i < DNALength; i++) child[i] = i < DNALength / 2 ? arrayA[i] : arrayB[i];
                break;
            
        case 1: for(int i = 0; i < DNALength; i++) child[i] = i % 2 ? arrayA[i] : arrayB[i];
                break;
            
        case 2: for(int i = 0; i < DNALength; i++) child[i] = (i > 0.2 * DNALength && i < 0.8 * DNALength)  ? arrayB[i] : arrayA[i];
                break;
            
        case 3: for(int i = 0; i < DNALength; i++) child[i] = (BOOL)(arc4random() % 2) ? arrayA[i] : arrayB[i];
                break;
            
        case 4: for(int i = 0; i < DNALength; i++) child[i] = (BOOL)!(arc4random() % 3) ? nucleoBase[arc4random() % 4] : ((BOOL)(arc4random() % 2) ? arrayA[i] : arrayB[i]);
                break;
    }
    
    child[DNALength] = '\0';
    
    nucleo = [NSMutableString stringWithUTF8String:child];
}

+ (NSMutableArray *)sort:(NSMutableArray *)array
{
    
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                                                     {
                                                         int first = [(Cell *)a humming];
                                                         int second = [(Cell *)b humming];
                                                         return first > second;
                                                     }];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

-(int)hummingDistance:(Cell *)base
{
    humming = 0;
    NSString *DNA = [base DNAString];

    for (int i = 0; i < ([nucleo length] <= [DNA length] ? [nucleo length] : [DNA length]); i++) if ([nucleo characterAtIndex:i] != [DNA characterAtIndex:i]) humming++;
    
    return humming;
}

@end
