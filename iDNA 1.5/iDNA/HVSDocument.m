//
//  HVSDocument.m
//  iDNA
//
//  Created by VladIslav Khazov on 23.12.12.
//  Copyright (c) 2012 VladIslav Khazov. All rights reserved.
//

#import "HVSDocument.h"
#import "HVSCellDna.h"
#import "HVSPopulationOfDna.h"
#import "HVSGenerateWindowController.h"

@implementation HVSDocument

//Для получения сообщения из Центра уведомлений
NSString *const HVSMyRandomNumberNotification = @"HVSMyRandomNumberNotification";

- (id)init
{
    self = [super init];
    if (self) {
        //Создаем популяцию с начальными параметрами.
        myPopulation = [[HVSPopulationOfDna alloc]init];
        //Добавляем свойство lengthDNA в наблюдение нашему контроллеру.
        [myPopulation addObserver:self forKeyPath:@"populationLengthDna" options:NSKeyValueObservingOptionOld context:@"changePopulationLengthDNA"];
        [myPopulation addObserver:self forKeyPath:@"populationSize" options:NSKeyValueObservingOptionOld context:@"changePopulationSize"];
        [myPopulation addObserver:self forKeyPath:@"populationRate" options:NSKeyValueObservingOptionOld context:@"changePopulationRate"];
        //Добавим себя слушателем для Центра уведомлений. Будем ожидать когда закончится генерация случайного числа.
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(handleRandomNumber:) name:HVSMyRandomNumberNotification object:nil];
        flagPause=NO;
    }
    return self;
}

-(void)dealloc {
    //Убираем свойства из наблюдения.
    [myPopulation removeObserver:self forKeyPath:@"populationLengthDna"];
    [myPopulation removeObserver:self forKeyPath:@"populationSize"];
    [myPopulation removeObserver:self forKeyPath:@"populationRate"];
    //Уберем себя из наблюдателей
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}
//Доп метод
-(void) changeKeyPath:(NSString *) keyPath
             ofObject:(id) obj
              toValue:(id) value {
    [obj setValue:value forKeyPath:keyPath];
}
//Метод запускается когда изменяется переменная populationLengthDna объекта myPopulation, а также всех  остальных наблюдаемых объектов
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
        NSUndoManager *myManager = [self undoManager];
    //Проверка, какая переменная была изменена.
    if (context==@"changePopulationLengthDNA") {
        //UNDO
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        if (oldValue == [NSNull null]) {
            oldValue = nil;
        }
        [[myManager prepareWithInvocationTarget:self] changeKeyPath:@"populationLengthDna" ofObject:myPopulation toValue:oldValue];
        [myManager setActionName:@"Change Length DNA"];
        
        //Получаем текущие значение переменной
        int length = (int)[myPopulation populationLengthDna];
        //Генерим нового Альфа самца 
        [myPopulation setGoalDNA:[[HVSCellDna alloc]initWithLengthDna:length]];
        // Выводим Goal DNA нашей поппуляции в текстовом поле.
        //Берем GOAL DNA
        NSMutableArray *myArrayDNA = [[myPopulation goalDNA] DNA];
        NSMutableString *result = [[NSMutableString alloc]init];
        //Цикл перевода массива в строку.
        for (int i=0; i<=[myArrayDNA count]-1 ; i++) {
            [result appendString:[myArrayDNA objectAtIndex:i]];
        }
        [_popTextGoalDna setStringValue:result];
        //Сохраним пользовательскую настройку
        [HVSPopulationOfDna setPreferenceLengthDNA:[myPopulation populationLengthDna]];
    }
    if (context==@"changePopulationSize") {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        if (oldValue == [NSNull null]) {
            oldValue = nil;
        }
        [[myManager prepareWithInvocationTarget:self] changeKeyPath:@"populationSize" ofObject:myPopulation toValue:oldValue];
        [myManager setActionName:@"Change Size"];
        //Сохраним пользовательскую настройку
        [HVSPopulationOfDna setPreferenceSize:[myPopulation populationSize]];
  }
    if (context==@"changePopulationRate") {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        if (oldValue == [NSNull null]) {
            oldValue = nil;
        }
        [[myManager prepareWithInvocationTarget:self] changeKeyPath:@"populationRate" ofObject:myPopulation toValue:oldValue];
        [myManager setActionName:@"Change Rate"];
        //Сохраним пользовательскую настройку
        [HVSPopulationOfDna setPreferenceRate:[myPopulation populationRate]];
    }
}

//Действия
-(void)startBackgroundEvolution {
    //Эволюция
    //Выполняем пока не получим 100: совпадений или пока не нажмут на кнопку Пауза
    while ([myPopulation flag]==NO && flagPause==NO) {
        [myPopulation evolution];
        [_popLevelMatch setIntegerValue:myPopulation.maxHamming];
        [_popLabelMatch setIntegerValue:myPopulation.maxHamming];
        [_popLabelGeneration setIntegerValue:myPopulation.countEvolution];
    }
    
    //Меняем интерфейс если не Пауза
    if (flagPause==NO) {
      [_popTextSize setEnabled:YES];
      [_popTextLength setEnabled:YES];
    
      [_popSliderSize setEnabled:YES];
      [_popSliderLength setEnabled:YES];
    
      [_popButtonLoad setEnabled:YES];
    }
    
    //Разрешаем менять % мутации, даже на паузе.
    [_popSliderRate setEnabled:YES];
    [_popTextRate setEnabled:YES];
    [_popButtonStart setEnabled:YES];
    [_popButtonPause setEnabled:NO];
}

//Метод запускается когда приходит сообщение о окончании процесса генерации случайного числа
-(void)handleRandomNumber:(NSNotification *) notif {
    
    //в UserInfo объекта NSNotification данне о нашем случайном числе
    unsigned int temp = [[notif userInfo] objectForKey:@"myRandomNumber"];
    //устанавливаем
    [myPopulation setIntGenerate:temp];
    //теперь все готово и можно снова запускать эволюцию
    [self buttonStart:self];
}


//Метд который обрабатывает нажатие на кнопку старт. Если случ.число еще не сгенерилось, то запускаем окно генерации.
-(IBAction)buttonStartNew:(id)sender {
    
    if (![myPopulation intGenerate]) {
           if (!generate) {
                generate = [[HVSGenerateWindowController alloc] init];
            }
            [generate showWindow:self];
            //как только будет сгенерировано случаное число, метод buttonStart запуститься автоматически из метода handleRandomNumber Центра сообщений
    }
    else { //запускаем основной процесс эволюции если случ. число уже готово. и/или нажимаем кнопку после Паузы
        [self buttonStart:self];
    }

    
}

//Нажата кнопка Старт - теперь этот метод не обрабатывает нажатие, сначала запускается buttonStartNew
- (IBAction)buttonStart:(id)sender {
    
    //Доп. проверка
    //Проверяем, если еще не генерировано число, то выходим
    if (![myPopulation intGenerate]) {
        return;
    }
    
    //Меняем интерфейс
    
    [_popTextSize setEnabled:NO];
    [_popTextLength setEnabled:NO];
    [_popTextRate setEnabled:NO];
    
    [_popSliderSize setEnabled:NO];
    [_popSliderLength setEnabled:NO];
    [_popSliderRate setEnabled:NO];
    
    [_popButtonStart setEnabled:NO];
    [_popButtonLoad setEnabled:NO];
    [_popButtonPause setEnabled:YES];

    //Если это не после паузы
    if (flagPause==NO) {
      //Создаем случайную популяцию ДНК с заданными параметрами.
      [myPopulation setPopulation];
      // Устанавливаем флаг совпадений в NO
      [myPopulation setFlag:NO];
      //Совпадение с Альфа
      [myPopulation setMaxHamming:0];
      //Количество эволюций
      [myPopulation setCountEvolution:0];
    }
    //Эволюция - запускаем фоном
    flagPause=NO;
    [self performSelectorInBackground:@selector(startBackgroundEvolution) withObject:nil];
}
- (IBAction)buttonPause:(id)sender {
    flagPause=YES;
    
}
- (IBAction)buttonLoad:(id)sender {
    //Загрузка файла текстового поля

    //Создаем File Open Dialog class
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    //Включаем выбор файлов
    [openDlg setCanChooseFiles:YES];
    //отключаем выбор папок
    [openDlg setCanChooseDirectories:NO];
//    [openDlg setRequireFileType:@"txt"];
    //разрешаем только расширение txt
    [openDlg setAllowedFileTypes:[[NSArray alloc]initWithObjects:@"txt", nil]];
    //Остальные разрешенеия запрещаем выбирать
    [openDlg setAllowsOtherFileTypes:NO];
    
    // Запускаем и ждем  Окей
    if ( [openDlg runModal] == NSOKButton )
    {
        // Получаем список выбранных файлов
        NSArray* files = [openDlg URLs] ;
        
        BOOL symbol=NO;
        // Проходим по ним
        for( int i = 0; i < [files count]; i++ )
        {
            //Получаем Path первого выбранного
            NSString* fileName = [[files objectAtIndex:i] path];
            //Считываем все подряд
            NSString * fileContents = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
            // Записываем его есои он устраивает нашим параметрам
            if ([fileContents length]==[myPopulation populationLengthDna] && [fileContents length]<=100) {
                //Проверка символов в файле
                for (int t=0; t<=[fileContents length]-1; t++) {
                    switch ([fileContents characterAtIndex:t]) {
                        case (unichar)'A':
                            break;
                        case (unichar)'T':
                            break;
                        case (unichar)'G':
                            break;
                        case (unichar)'C':
                            break;
                        default:
                            symbol=YES;
                            break;
                    }
                }
                
                if (symbol==NO) {
                    //Устанавливаем текстовое поле
                    [_popTextGoalDna setStringValue:fileContents];
                    //создаем нового альфа самца размерностью файла
                    [[myPopulation goalDNA] setDNA:[[NSMutableArray alloc]initWithContentsOfFile:fileContents]];
                } else {
                    NSAlert *myAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"WARNING_FILE_SYM","Похоже файл содержит символ не относящийся к ДНК или в нем есть управляющие символы (Пр. перевод каретки)")
                                                       defaultButton:NSLocalizedString(@"OK", "") alternateButton:nil otherButton:nil informativeTextWithFormat:@" "];
                     [myAlert runModal];
                }
                
            } else {
                NSString *str=[[NSMutableString alloc]initWithFormat:NSLocalizedString(@"FILE_LENGTH","Данный файл имеет длину %ld"),[fileContents length]];
                NSAlert *myAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"WARNING_FILE_LENGTH","Файл содержит ДНК другой размерностью или его размер больше 100 единиц!!! ")
                                                   defaultButton:NSLocalizedString(@"OK", "") alternateButton:nil otherButton:nil informativeTextWithFormat:str];
                [myAlert runModal];
            }
        
        }
    }
    
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"HVSDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    // Выводим Goal DNA нашей поппуляции.
    //Берем GOAL DNA
    NSMutableArray *myArrayDNA = [[myPopulation goalDNA] DNA];
    NSMutableString *result = [[NSMutableString alloc]init];
    //Цикл перевода массива в строку.
    for (int i=0; i<=[myArrayDNA count]-1 ; i++) {
        [result appendString:[myArrayDNA objectAtIndex:i]];
    }
    [_popTextGoalDna setStringValue:result];
}

+ (BOOL)autosavesInPlace
{
    //Парит - жутко. Отключил.
    return NO;
}

//Сохранение документа
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    //Проверим, действительно ли пользователь хочет сохранить файл.
    NSInteger choice = NSRunAlertPanel(NSLocalizedString(@"FILE_SAVE_NAME",@"Сохранение данных в файл")
                                       ,NSLocalizedString(@"FILE_SAVE_MSG",@"Вы действительно хотите сохранить документ?")
                                       ,NSLocalizedString(@"YES","")
                                       ,NSLocalizedString(@"NO",""), nil);
    if (choice != 1) {
        return nil;
    }
    
    NSMutableData *saveData = [[NSMutableData alloc]init];
    NSKeyedArchiver *myKeyArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:saveData];
    [myKeyArchiver encodeInteger:[myPopulation populationSize] forKey:@"populationSize"];
    [myKeyArchiver encodeInteger:[myPopulation populationLengthDna] forKey:@"populationLengthDna"];
    [myKeyArchiver encodeInteger:[myPopulation populationRate] forKey:@"populationRate"];
    [myKeyArchiver encodeObject:[myPopulation populationDNA] forKey:@"populationDNA"];
    [myKeyArchiver encodeInt:[[myPopulation goalDNA] lengthDna] forKey:@"lengthDna"];
    [myKeyArchiver encodeObject:[[myPopulation goalDNA] DNA] forKey:@"DNA"];
    [myKeyArchiver encodeBool:[myPopulation flag] forKey:@"flag"];
    [myKeyArchiver encodeInteger:[myPopulation maxHamming] forKey:@"maxHamming"];
    [myKeyArchiver encodeInteger:[myPopulation countEvolution] forKey:@"countEvolution"];

    [myKeyArchiver finishEncoding];
    
    
//    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:[self popButtonLoad]];
    return saveData;
}

//Загрузка файла
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    //Проверим, действительно ли пользователь хочет загрузить файл.
    NSInteger choice = NSRunAlertPanel(NSLocalizedString(@"FILE_LOAD_NAME",@"Загрузка данных из файла"),
                                       NSLocalizedString(@"FILE_LOAD_MSG",@"Вы действительно хотите открыть новый документ?"),
                                       NSLocalizedString(@"YES",""),
                                       NSLocalizedString(@"NO",""), nil);
    if (choice != 1) {
        return NO;
    }
    
    NSKeyedUnarchiver *myKeyArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    HVSPopulationOfDna *newMyPopulation = nil;
    @try {
        newMyPopulation = [[HVSPopulationOfDna alloc] init];
        [newMyPopulation setPopulationSize:[myKeyArchiver decodeIntegerForKey:@"populationSize"]];
        [newMyPopulation setPopulationLengthDna:[myKeyArchiver decodeIntegerForKey:@"populationLengthDna"]];
        [newMyPopulation setPopulationRate:[myKeyArchiver decodeIntegerForKey:@"populationRate"]];
        [newMyPopulation setPopulationDNA:[myKeyArchiver decodeObjectForKey:@"populationDNA"]];
        //Подготовка
        [newMyPopulation setGoalDNA:[[HVSCellDna alloc] initWithLengthDna:(int)[myKeyArchiver decodeIntegerForKey:@"lengthDna"]]];
//        [myKeyArchiver decodeIntForKey:@"lengthDna"];
//        [myKeyArchiver decodeObjectForKey:@"DNA"];
        [[newMyPopulation goalDNA] setDNA:[myKeyArchiver decodeObjectForKey:@"DNA"]];
                                     
        [newMyPopulation setFlag:[myKeyArchiver decodeBoolForKey:@"flag"]];
        [newMyPopulation setMaxHamming:[myKeyArchiver decodeIntegerForKey:@"maxHamming"]];
        [newMyPopulation setCountEvolution:[myKeyArchiver decodeIntegerForKey:@"countEvolution"]];
    }
    @catch (NSException *exception) {
        if (outError) {
            NSDictionary *d = [NSDictionary dictionaryWithObject:@"The file is invalid!" forKey:NSLocalizedFailureReasonErrorKey];
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:d];
            return NO;
        }
    }
    myPopulation = newMyPopulation;
    //Не понятно, потому что в инит стоит addObsrving, но он при почему то не работает при вызове...
    [myPopulation addObserver:self forKeyPath:@"populationLengthDna" options:NSKeyValueObservingOptionOld context:@"changePopulationLengthDNA"];
    [myPopulation addObserver:self forKeyPath:@"populationSize" options:NSKeyValueObservingOptionOld context:@"changePopulationSize"];
    [myPopulation addObserver:self forKeyPath:@"populationRate" options:NSKeyValueObservingOptionOld context:@"changePopulationRate"];
    return YES;
}

//Закрытие документа
- (BOOL)windowShouldClose:(id)sender
{
    //NSLog(@"CLoooose");
    NSInteger choice = NSRunAlertPanel(NSLocalizedString(@"DOC_CLOSE_NAME",@"Закрытие документа"),
                                       NSLocalizedString(@"DOC_CLOSE_MSG",@"Вы действительно хотите закрыть документ?"),
                                       NSLocalizedString(@"YES",""),
                                       NSLocalizedString(@"NO",""), nil);
    if (choice == 1) {
        return YES;
        
    }
    return NO;
}

@end
