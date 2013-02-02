//
//  HVSPopulationOfDna.m
//  iDNA
//
//  Created by VladIslav Khazov on 23.12.12.
//  Copyright (c) 2012 VladIslav Khazov. All rights reserved.
//

#import "HVSPopulationOfDna.h"

@implementation HVSPopulationOfDna

//Зададим значения для пользовательских настроек
NSString *const HVSPopulationSizeKey = @"HVSPopulationSizeKey";
NSString *const HVSPopulationLengthDNAKey = @"HVSPopulationLengthDNAKey";
NSString *const HVSPopulationRateKey = @"HVSPopulationRateKey";

//Воспользуемся методом initialized для записи заводских настроек
+(void)initialize {
    NSMutableDictionary *factoryValues = [NSMutableDictionary dictionary];
    [factoryValues setObject:[NSNumber numberWithInteger:1000] forKey:HVSPopulationSizeKey];
    [factoryValues setObject:[NSNumber numberWithInteger:30] forKey:HVSPopulationLengthDNAKey];
    [factoryValues setObject:[NSNumber numberWithInteger:5] forKey:HVSPopulationRateKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:factoryValues];
}

//методы загрузки/сохранения пользовательских настроек
+(void)setPreferenceSize:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:HVSPopulationSizeKey];
}
+(NSInteger)preferenceSize {
    return [[NSUserDefaults standardUserDefaults] integerForKey:HVSPopulationSizeKey];
}
+(void)setPreferenceLengthDNA:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:HVSPopulationLengthDNAKey];
}

+(NSInteger)preferenceLengthDNA {
    return [[NSUserDefaults standardUserDefaults] integerForKey:HVSPopulationLengthDNAKey];
}
+(void)setPreferenceRate:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:HVSPopulationRateKey];
}

+(NSInteger)preferenceRate {
    return [[NSUserDefaults standardUserDefaults] integerForKey:HVSPopulationRateKey];
}

//сохранение пользовательских настроек
-(IBAction)setSavePreference:(id)sender {
    [HVSPopulationOfDna setPreferenceSize:[self populationSize]];
    [HVSPopulationOfDna setPreferenceRate:[self populationRate]];
    [HVSPopulationOfDna setPreferenceLengthDNA:[self populationLengthDna]];
    NSLog(@"Size:%ld",[self populationSize]);
    NSLog(@"Rate:%ld",[self populationRate]);
    NSLog(@"Length:%ld",[self populationLengthDna]);
}

//Восстановление заводских настроек
-(IBAction)restoreFactoryPreference:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HVSPopulationSizeKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HVSPopulationLengthDNAKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HVSPopulationRateKey];
}

-(id)init {
    self = [super init];
    if (self) {
        [self setPopulationLengthDna:[HVSPopulationOfDna preferenceLengthDNA]];
        [self setPopulationRate:[HVSPopulationOfDna preferenceRate]];
        [self setPopulationSize:[HVSPopulationOfDna preferenceSize]];
        [self setGoalDNA:[[HVSCellDna alloc]initWithLengthDna:30]];
        [self setFlag:NO];
        [self setMaxHamming:0];
        [self setCountEvolution:0];
    }
    return self;
}

//метод заполнения популяции c заданными параметрами
-(void)setPopulation {
//    [self setPopulationDNA:[[NSMutableArray alloc]initWithCapacity:[self populationSize]]];
    _populationDNA = [[NSMutableArray alloc] initWithCapacity:_populationSize];
    //Заполняем популяцию
    for (int i=0; i<=_populationSize-1; i++) {
        //Длина каждой днк
        int length = (int)_populationLengthDna;
        //Добавляем объект в массив.
//        [[self populationDNA] addObject:[[HVSCellDna alloc]initWithLengthDna:length]];
        [_populationDNA addObject:[[HVSCellDna alloc] initWithLengthDna:length]];
    }
}


//Эволюция 1 проход
-(void)evolution {
    //Сортировка
    //Создаем временный массив.
    NSMutableArray *sortPopulationDNA = [[NSMutableArray alloc] initWithCapacity:_populationSize];
    //Смысл сортировки: Ищем и добавляем в массив сначала все элементы которые совпадают полностью, затем на 1 меньше и так далее. Пока не добавим все элементы в сортированный массив.
    for (int lenDNA=(int)_populationLengthDna; lenDNA>=1; lenDNA--) {
        for (int i=0; i<=_populationSize-1 ; i++) {
            int tempHamming =[[_populationDNA objectAtIndex:i] hammingDistance:_goalDNA];
            if (tempHamming==lenDNA) {
                [sortPopulationDNA addObject:[_populationDNA objectAtIndex:i]];
                //Проверка на полное совпадение
                if (tempHamming==(int)_populationLengthDna) {
                    _flag=YES;
                }
                //Максимальное совпадение
                if (tempHamming*100/_populationLengthDna>_maxHamming) {
                   _maxHamming = tempHamming*100/_populationLengthDna;
                }
            }
        }
    }
    //Присваиваем отсортированный массив нашему.
    _populationDNA=sortPopulationDNA;
    //Временная ДНК для скрещивания.
    NSMutableArray *tempDNA = [[NSMutableArray alloc] initWithCapacity:_populationLengthDna];
    // временные индексы топ ДНК
    int tempDNA1,tempDNA2;
    //Если нет совпадений делаем эволюцию
    if (_flag==NO) {
        //Увеличиваем счетчик
        _countEvolution++;
        //Цикл по второй половине популяция, для их замены.
        for (int i=(int)_populationSize/2; i<=_populationSize-1; i++) {
            //Случайный выбор метода.
            int random = arc4random_uniform(3);
            switch (random) {
                case 0:
                    tempDNA1 = arc4random_uniform((int)_populationSize/2);
                    tempDNA2 = arc4random_uniform((int)_populationSize/2);
                    //создаем новый ДНК 50/50
                    for (int j=0; j<=(int)_populationLengthDna-1; j++) {
                        if (j<=(int)_populationLengthDna/2) {
                            //Добавляем значение случайной ДНК 1, по индексу j.
                            [tempDNA addObject:[[[_populationDNA objectAtIndex:tempDNA1] DNA] objectAtIndex:j]];
                        } else {
                            //Добавляем значение случайной ДНК 2, по индексу j.
                            [tempDNA addObject:[[[_populationDNA objectAtIndex:tempDNA2] DNA] objectAtIndex:j]];
                        }
                    }
                    //Записываем результат
                    [[_populationDNA objectAtIndex:i] setDNA:tempDNA];
                    break;
                case 1:
                    tempDNA1 = arc4random_uniform((int)_populationSize/2);
                    tempDNA2 = arc4random_uniform((int)_populationSize/2);
                    //создаем новый ДНК через 1 1/1/1/1/1
                    for (int j=0; j<=(int)_populationLengthDna-1; j++) {
                        if (j%2==0) {
                            //Добавляем значение случайной ДНК 1, по индексу j.
                            [tempDNA addObject:[[[_populationDNA objectAtIndex:tempDNA1] DNA] objectAtIndex:j]];
                        } else {
                            //Добавляем значение случайной ДНК 2, по индексу j.
                            [tempDNA addObject:[[[_populationDNA objectAtIndex:tempDNA2] DNA] objectAtIndex:j]];
                        }
                    }
                    //Записываем результат
                    [[_populationDNA objectAtIndex:i] setDNA:tempDNA];
                    break;
                case 2:
                    tempDNA1 = arc4random_uniform((int)_populationSize/2);
                    tempDNA2 = arc4random_uniform((int)_populationSize/2);
                    //создаем новый ДНК 20/60/20
                    for (int j=0; j<=(int)_populationLengthDna-1; j++) {
                        if (j*100/((int)_populationLengthDna-1)<=20 || j*100/((int)_populationLengthDna-1)>60) {
                            //Добавляем значение случайной ДНК 1, по индексу j.
                            [tempDNA addObject:[[[_populationDNA objectAtIndex:tempDNA1] DNA] objectAtIndex:j]];
                        } else {
                            //Добавляем значение случайной ДНК 2, по индексу j.
                            [tempDNA addObject:[[[_populationDNA objectAtIndex:tempDNA2] DNA] objectAtIndex:j]];
                        }
                    }
                    //Записываем результат
                    [[_populationDNA objectAtIndex:i] setDNA:tempDNA];
                    break;
                default:
                    break;
            }
            
        }
        //Мутация популяции
        for (HVSCellDna *dna in _populationDNA) {
            [dna mutate:(int)_populationRate];
        }
    }
}

@end
