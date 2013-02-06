//
//  RandomWindowController.h
//  iDNA
//
//  Created by alex on 05/02/2013.
//  Copyright (c) 2013 alex. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RandomWindowController : NSWindowController

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSView *view;
@property NSNumber *random;

- (IBAction)onExit:(id)sender;

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
