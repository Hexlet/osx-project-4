//
//  HVSCellDna.h
//  iDNA
//
//  Created by VladIslav Khazov on 23.12.12.
//  Copyright (c) 2012 VladIslav Khazov. All rights reserved.
//

#import <Foundation/Foundation.h>

//размерность ДНК (Значение по умолчанию)
#define sizeDNA 100 // НЕ задавать меньше 1 !

@interface HVSCellDna : NSObject

// Основной массив, создаем свойство с методами
@property NSMutableArray *DNA;
//Данное свойство будет хранить размер данной ДНК. (Можно было брать его из популяции, но мне кажется так будет доп. проверка передаваемых значений)
@property int lengthDna;

//Определяем функцию сравнения, входной параметр объект класса HVSСellDna
-(int) hammingDistance: (HVSCellDna *) otherCell;
//Мутация входящий параметр - %
-(void) mutate:(int) i;
//метод init
-(id)init;
//Свой метод init  с указанной размерностью ДНК.
-(id)initWithLengthDna:(int) length;
@end
