//
//  HVSGenerateWindowController.m
//  iDNA
//
//  Created by VladIslav Khazov on 03.02.13.
//  Copyright (c) 2013 VladIslav Khazov. All rights reserved.
//

#import "HVSGenerateWindowController.h"
#import "HVSDocument.h"

@interface HVSGenerateWindowController ()

@end

@implementation HVSGenerateWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) init {
    self =[super initWithWindowNibName:@"HVSGenerateWindowController"];
    if (self) {
        //Опа, оказывается надо вызвать метод у окна, чтоб он вызвывал метод mouseMoved - значение по умолчанию - НЕТ.
        [[self window] setAcceptsMouseMovedEvents:YES];
        [self setCountMoveMouse:0];
        [[self progress] stopAnimation:self];
    }
    return self;
}

//Если не двигаем мышь, останавливаем прогресс бар
-(void)stopBackgroundUpdate {
    sleep(1);
    [_progress stopAnimation:self];
}

//Так как мы унаследованы от NSResponer, перепишем его метод.
-(void)mouseMoved:(NSEvent *)theEvent {
    //запускаем движение бара
    [_progress startAnimation:self];
    [self setCountMoveMouse:_countMoveMouse+1];
    //Как только 100 раз двигали мышь, заканчиваем
    if (_countMoveMouse <=100) {
        NSPoint p = [theEvent locationInWindow];
        myRandomNumber = myRandomNumber + p.x+p.y;
        //NSLog(@"currentNumber:%d",myRandomNumber);
        if (_countMoveMouse==100) {
            //Пошлем сообщение в центр Сообщений для обработки
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            //Данный ключь потом можно использовать при обращении к объекту Notification свойства userInfo как к словарю.
            //Передадим наше случайно число.
            NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:myRandomNumber] forKey:@"myRandomNumber"];
            //Пошлем сообщение с вложенной информацией о нашем случайном числе. dictInfo всегда Dictionary
            [nc postNotificationName:HVSMyRandomNumberNotification object:nil userInfo:dictInfo];
        }
    } else {
        [[self window] close];
    }
//    currentPoint = [selfconvertPoint:p fromView:nil];
    //запускаем остановку 
    [self performSelectorInBackground:@selector(stopBackgroundUpdate) withObject:nil];
    
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
