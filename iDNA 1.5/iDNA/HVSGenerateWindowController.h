//
//  HVSGenerateWindowController.h
//  iDNA
//
//  Created by VladIslav Khazov on 03.02.13.
//  Copyright (c) 2013 VladIslav Khazov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HVSGenerateWindowController : NSWindowController {
    //Число для random
    unsigned int myRandomNumber;
}

@property  double countMoveMouse;
@property (weak) IBOutlet NSProgressIndicator *progress;

@end
