//
//  RandomGenWindowController.h
//  iDNA
//
//  Created by Admin on 06.02.13.
//  Copyright (c) 2013 Kabest. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const IDNARandomNumberChanged;
extern NSString *const IDNARandomNumberReady;
extern NSString *const IDNARandomNumber;

@interface RandomGenWindowController : NSWindowController {
    int progress;
    BOOL ready;
}

@property (weak) IBOutlet NSProgressIndicator *progressBar;

-(IBAction)exitButtonClicked:(id)sender;

@end
