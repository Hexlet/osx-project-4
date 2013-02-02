//
//  HVSDocument.h
//  iDNA
//
//  Created by VladIslav Khazov on 23.12.12.
//  Copyright (c) 2012 VladIslav Khazov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HVSPopulationOfDna.h"

@interface HVSDocument : NSDocument {
    //Определяем нашу популяцию
    HVSPopulationOfDna *myPopulation;
    //Флаг Паузы
    BOOL flagPause;
}
//Свойста для работы с объектами на форме
//Текстовые поля
@property (weak) IBOutlet NSTextField *popTextSize;
@property (weak) IBOutlet NSTextField *popTextLength;
@property (weak) IBOutlet NSTextField *popTextRate;
@property (weak) IBOutlet NSTextField *popTextGoalDna;
//Слайдеры
@property (weak) IBOutlet NSSlider *popSliderSize;
@property (weak) IBOutlet NSSlider *popSliderLength;
@property (weak) IBOutlet NSSlider *popSliderRate;
//Лэйблы
@property (weak) IBOutlet NSTextField *popLabelGeneration;
@property (weak) IBOutlet NSTextField *popLabelMatch;
//Индикатор
@property (weak) IBOutlet NSLevelIndicator *popLevelMatch;
//Кнопки
@property (weak) IBOutlet NSButton *popButtonStart;
@property (weak) IBOutlet NSButton *popButtonPause;
@property (weak) IBOutlet NSButton *popButtonLoad;


//Действия
- (IBAction)buttonStart:(id)sender;
- (IBAction)buttonPause:(id)sender;
- (IBAction)buttonLoad:(id)sender;
//Фоновый поток
-(void)startBackgroundEvolution;
@end
