//
//  HVSCellDna.m
//  iDNA
//
//  Created by VladIslav Khazov on 23.12.12.
//  Copyright (c) 2012 VladIslav Khazov. All rights reserved.
//

#import "HVSCellDna.h"

@implementation HVSCellDna

//Изменяем стандартный метод init
- (id) init {
    if (sizeDNA<1) {
        NSAlert *myAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"WARNING_DNA","ДНК не может быть меньше 1") defaultButton:NSLocalizedString(@"EXIT", "") alternateButton:nil otherButton:nil informativeTextWithFormat:@" "];
        [myAlert runModal];
        exit(0);
    }
    //вызов родительского метода
    self = [super init];
    if (self) {
        //Создаем временный массив
        NSArray *arrayCode = [NSArray arrayWithObjects:@"A", @"T", @"G", @"C", nil];
        //Определяем размерность нашего массива
        _DNA = [[NSMutableArray alloc] initWithCapacity:sizeDNA];
        //Заполняем массив
        for (int i=0; i<=sizeDNA-1; i++) {
            //Добавляем объект в массив DNA, используя случайное число от 0 до 3, как индекс для массива arrayCode
            [_DNA addObject:[arrayCode objectAtIndex:arc4random_uniform(4)]];
        }
    }
    // Устанавливаем размерность данного ДНК.
    [self setLengthDna:(int)sizeDNA];
    return self;
}

-(id)initWithLengthDna:(int)length {
    if (length<1 || length>100) {
        NSAlert *myAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"WARNING_DNA","ДНК не может быть меньше 1 и больше 100.") defaultButton:NSLocalizedString(@"EXIT", "") alternateButton:nil otherButton:nil informativeTextWithFormat:@" "];
        [myAlert runModal];
        exit(0);
    }
    //вызов родительского метода
    self = [super init];
    if (self) {
        //Создаем временный массив
        NSArray *arrayCode = [NSArray arrayWithObjects:@"A", @"T", @"G", @"C", nil];
        //Определяем размерность нашего массива
        _DNA = [[NSMutableArray alloc] initWithCapacity:length];
        //Заполняем массив
        for (int i=0; i<=length-1; i++) {
            //Добавляем объект в массив DNA, используя случайное число от 0 до 3, как индекс для массива arrayCode
            [_DNA addObject:[arrayCode objectAtIndex:arc4random_uniform(4)]];
        }
    }
    // Устанавливаем размерность данного ДНК.
    [self setLengthDna:(int)length];
    return self;
}

-(int) hammingDistance: (HVSCellDna *) otherCell{
    //Счетчик совпадений
    int count = 0;
    //Проверка размерности
    if (_lengthDna != [otherCell lengthDna]) {
        NSAlert *myAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"WARNING_DNA_SIZE", "ДНК имеют разную размерность!") defaultButton:NSLocalizedString(@"OK", "") alternateButton:nil otherButton:nil informativeTextWithFormat:@" "];
        [myAlert runModal];
        return 0;
    }
    // [otherCell DNA] возвращает свойство второго HVSCellDna, Обращаемся к нему как к NSMutableArray
    for(int i=0;i<=_lengthDna-1;i++){
        //Проверяем на совпадение
        if ([[otherCell DNA] objectAtIndex:i]!=[_DNA objectAtIndex:i]) {
            count++;
        }
    }
    return count;
}

-(void) mutate:(int) i{
    if (i<1 || i>100) {
        NSAlert *myAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"WARNING_MUTATE","Указан не верный параметр 'Процента мутации'. Обе ДНК остались без изменений") defaultButton:NSLocalizedString(@"OK", "") alternateButton:nil otherButton:nil informativeTextWithFormat:@" "];
        [myAlert runModal];
        return;
    }
    // Количество элементов которые необходимо изменить в ДНК
    int countMutator = _lengthDna*i/100;
    //Создадим массив для хранения еще не мутировавших
    NSMutableArray *arrayCheck = [[NSMutableArray alloc] initWithCapacity:_lengthDna];
    for (int k=0; k<_lengthDna; k++) {
        [arrayCheck addObject:[NSNumber numberWithInt:k]];
    }
    //Создаем временный массив видов ДНК
    NSArray *arrayCode = [NSArray arrayWithObjects:@"A", @"T", @"G", @"C", nil];
    // Переменная для случайного номера ДНК
    int dnaIndex = 0;
    
    //Цикл по нужному количество изменяемых элементов
    for (int j=1; j<=countMutator; j++) {
        //Генерим случайное число от 0 до количества еще не мутировавших элементов
        dnaIndex = arc4random_uniform(_lengthDna-j+1);
        //Меняем
        [[self DNA] replaceObjectAtIndex:[[arrayCheck objectAtIndex:dnaIndex] intValue] withObject:[arrayCode objectAtIndex:arc4random_uniform(4)]];
        // Удаляем мутировавший элемент из архива
        [arrayCheck removeObjectAtIndex:dnaIndex];
    }
}

@end
