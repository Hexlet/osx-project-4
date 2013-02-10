//
//  AboutController.h
//  weeksOfLife
//
//  Created by Александр Борунов on 27.01.13.
//  Copyright (c) 2013 Александр Борунов. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface AboutController : NSWindowController {
    IBOutlet NSTextView* aboutMessage;
    IBOutlet NSPanel* panel;
}
-(NSPanel *)panel;

@end
