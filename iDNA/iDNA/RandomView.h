//
//  RandomView.h
//  iDNA
//
//  Created by Admin on 07.02.13.
//  Copyright (c) 2013 Kabest. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RandomView : NSView {
    unsigned rnd;
    NSPoint lastPoint;
    NSMutableDictionary *attr;
    NSString *string;
}

-(void)drawText;

@end
