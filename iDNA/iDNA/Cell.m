//
//  Cell.m
//  DNAProject
//
//  Created by alex on 31/10/2012.
//  Copyright (c) 2012 alex. All rights reserved.
//

#import "Cell.h"

NSString *const DNAChangeNotification = @"DNAChangeNotification";

@implementation Cell (mutator)

-(void) mutate: (NSInteger)X
{
    // количество ячеек, которые нужно заменить
    int n = (int)floor([[self DNA] count]*X/100);
    NSMutableArray *exists = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < n; i++) {
        // следим, чтобы не воткнуть новый элемент в уже измененную ячейку
        int k = arc4random()%[[self DNA] count];
        while ([exists containsObject:[NSNumber numberWithInteger:k]]) {
            k = arc4random()%[[self DNA] count];
        }
        // добавляем номер ячейки в список измененных
        [exists addObject:[NSNumber numberWithInteger:k]];
        
        // запоминаем, что у нас на этом месте стояло
        NSString *prev = [[self DNA] objectAtIndex:k];
        // и заменяем на другой(!) элемент
        while ([prev isEqualToString:[[self DNA] objectAtIndex:k]]) {
            [[self DNA] replaceObjectAtIndex:k withObject:[DNAElements objectAtIndex:arc4random()%4]];
        }
    }
    
    // сбрасываем закэшированное значение расстояния до goalDNA
    self.hammingDistanceToRootCell = -1;
}

@end


@implementation Cell

-(id) init
{
    if (self = [super init]) {
        DNAElements = [[NSArray alloc] initWithObjects:@"A", @"T", @"G", @"C", nil];
        _DNA = [[NSMutableArray alloc] init];
        _hammingDistanceToRootCell = -1;
    }
    return self;
}

-(id)initWithSize:(NSInteger)size
{
    if (self = [self init]) {
        [self populateForSize:size];
    }
    return self;
}

-(id)initWithSize:(NSInteger)size andRootCell:(Cell *)cell
{
    if (self = [self initWithSize:size]) {
        _rootCell = cell;
    }
    return self;
}

-(id)initWithString:(NSString *)string
{
    if (self = [self init]) {
        [self populateWithString:string];
    }
    return self;
}

-(void)populateForSize:(NSInteger)size
{
    [_DNA removeAllObjects];

    // заполняем массив DNA случайными элементами
    for (int i = 0; i < size; i++) {
        [_DNA addObject:[DNAElements objectAtIndex:arc4random()%4]];
    }
    //NSLog(@"%@", _DNA);
    
    // говорим всем, что значение поменялось
    [[NSNotificationCenter defaultCenter] postNotificationName:DNAChangeNotification object:self];
}

-(void)populateWithString:(NSString*)string
{
    [_DNA removeAllObjects];
    
    for (int i = 0; i < string.length; i++) {
        [_DNA addObject:[string substringWithRange:NSMakeRange(i, 1)]];
    }
    
    // говорим всем, что значение поменялось
    [[NSNotificationCenter defaultCenter] postNotificationName:DNAChangeNotification object:self];
}


-(int) hammingDistance:(Cell *)cell
{
    int result = 0;
    
    // проверяем, а не с goalDNA мы сравниваем, если да, то пытаемся возвратить закэшированное значение
    if (self == _rootCell || cell == _rootCell) {
        if (_hammingDistanceToRootCell > -1) {
            //NSLog(@"return cached value (%d)", _hammingDistanceToRootCell);
            return _hammingDistanceToRootCell;
        }
    }
    
    for (int i = 0; i < _DNA.count; i++) {
        if (![[_DNA objectAtIndex:i] isEqualToString: [[cell DNA] objectAtIndex:i]]) {
            result++;
        }
    }
    
    // если сравниваем с goalDNA, то кэшируем полученное значение
    if (self == _rootCell || cell == _rootCell) {
        //NSLog(@"store value (%d) in cache", result);
        _hammingDistanceToRootCell = result;
    }
    
    return result;
}


-(NSString*) asString
{
    return [[_DNA valueForKey:@"description"] componentsJoinedByString:@""];
}

-(NSComparisonResult)compareWithCell:(Cell*) cell
{
    int distance1 = [_rootCell hammingDistance:self];
    int distance2 = [_rootCell hammingDistance:cell];
    
    if (distance1 < distance2) {
        return NSOrderedAscending;
    } else
    if (distance1 > distance2) {
        return NSOrderedDescending;
    } else
    return NSOrderedSame;
    
    // сравнение имеет смысл только с goalDNA
    //return [[[NSNumber alloc] initWithInt:[_rootCell hammingDistance:self]] compare:[[NSNumber alloc] initWithInt:[_rootCell hammingDistance:cell]]];
}

-(id)combineWith:(Cell *)cell withWay:(int)n
{
    Cell *newCell = [Cell copyCell:self];
    
    if (n == 1) { // 50% первого ДНК + 50% второго ДНК
        
        int size1 = (int)_DNA.count/2; // середина нашего массива
        int size2 = (int)cell.DNA.count/2; // середина другого массива
        // если число элементов нечетное, то чуточку подправляем...
        if (size2 < _DNA.count-size1) {
            size2 = (int)_DNA.count-size1;
        }
        
        [newCell.DNA replaceObjectsInRange:NSMakeRange(size1, _DNA.count-size1) withObjectsFromArray:cell.DNA range:NSMakeRange(0, size2)];
        
    } else if (n == 2) { // 1% первого ДНК + 1% второго ДНК + 1% первого ДНК + ... и т.д. (в лекции было сказано, что можно просто по одной штучке менять)
        
        int i = 1;
        while (i < newCell.DNA.count) {
            if (i >= cell.DNA.count) break;
            [newCell.DNA replaceObjectAtIndex:i withObject:[cell.DNA objectAtIndex:i]];
            i += 2;
        }
        
    } else if (n == 3) { // 20% первого ДНК + 60% второго ДНК + 20% первого ДНК
        int size20 = (int)_DNA.count/5; // 20% нашего массива
        int size60 = (int)cell.DNA.count*0.6f; // 60% чужого массива
        
        [newCell.DNA replaceObjectsInRange:NSMakeRange(size20, size60) withObjectsFromArray:cell.DNA range:NSMakeRange(0, size60)]; // - тут автоматически должно остаться 20% исходного массива в конце
    }
    
    return newCell;
}

+(id) copyCell:(Cell *) cell
{
    Cell *result = [[Cell alloc] initWithSize:[[cell DNA] count]];
    NSMutableArray *dest = [result DNA];
    NSMutableArray *source = [cell DNA];
    for (int i = 0; i < source.count; i++) {
        [dest replaceObjectAtIndex:i withObject: [source objectAtIndex:i]];
    }
    return result;
}

@end
