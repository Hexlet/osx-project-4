//
//  LCDBoxView.m
//  iDNA
//
//  Created by Alexander Shvets on 24.12.12.
//  Copyright (c) 2012 Alexander Shvets. All rights reserved.
//

#import "LCDBoxView.h"

@implementation LCDBoxView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    static NSShadow *kDropShadow = nil;
    static NSShadow *kInnerShadow = nil;
    static NSGradient *kBackgroundGradient = nil;
    static NSColor *kBorderColor = nil;
    
    if (kDropShadow == nil) {
        kDropShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:.863 alpha:.75] offset:NSMakeSize(0, -1.0) blurRadius:1.0];
        kInnerShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0.0 alpha:.52] offset:NSMakeSize(0.0, -1.0) blurRadius:4.0];
        kBorderColor = [NSColor colorWithCalibratedWhite:0.569 alpha:1.0];
        // Xcode style
        kBackgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.957 green:0.976 blue:1.0 alpha:1.0],0.0,[NSColor colorWithCalibratedRed:0.871 green:0.894 blue:0.918 alpha:1.0],0.5,[NSColor colorWithCalibratedRed:0.831 green:0.851 blue:0.867 alpha:1.0],0.5,[NSColor colorWithCalibratedRed:0.82 green:0.847 blue:0.89 alpha:1.0],1.0, nil];
    }
    
    NSRect bounds = [self bounds];
    bounds.size.height -= 1.0;
    bounds.origin.y += 1.0;
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:3.5 yRadius:3.5];
    
    [NSGraphicsContext saveGraphicsState];
    [kDropShadow set];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
    
    [kBackgroundGradient drawInBezierPath:path angle:-90.0];
    
    [kBorderColor setStroke];
    [path strokeInside];
    
    [path fillWithInnerShadow:kInnerShadow];
}


@end
