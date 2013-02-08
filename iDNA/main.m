//
//  main.m
//  iDNA
//
//  Created by Igor Pavlov on 25.12.12.
//  Copyright (c) 2012 Igor Pavlov. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject<NSApplicationDelegate>

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;

@end


@implementation AppController

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSAlert *a = [NSAlert alertWithMessageText:nil
                                 defaultButton:nil
                               alternateButton:NSLocalizedString(@"CANCEL", @"Cancel")
                                   otherButton:nil
                     informativeTextWithFormat:NSLocalizedString(@"QUIT_QUESTION", @"Quit question")];
    NSInteger result = [a runModal];
    if (NSAlertDefaultReturn != result)
        return NSTerminateCancel;
    return NSTerminateNow;
}

@end


int main(int argc, char *argv[])
{
    [NSApplication sharedApplication];

    AppController *delegate = [[AppController alloc] init];
    [NSApp setDelegate: delegate];

    return NSApplicationMain(argc, (const char **)argv);
}
