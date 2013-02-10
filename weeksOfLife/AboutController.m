//
//  AboutController.m
//  weeksOfLife
//
//  Created by Александр Борунов on 27.01.13.
//  Copyright (c) 2013 Александр Борунов. All rights reserved.
//

#import "AboutController.h"

@interface AboutController ()

@end

@implementation AboutController


-(id) init{
    if (self = [super initWithWindowNibName:@"AboutController"]){
        
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // создадим текст сообщения О программе
    NSString *s = [NSString stringWithFormat:@"%@%@%@%@",
                   NSLocalizedString(@"ABOUT1", @"about1"),
                   NSLocalizedString(@"ABOUT2", @"video"),
                   NSLocalizedString(@"ABOUT3", @"about3"),
                   NSLocalizedString(@"ABOUT4", @"about4")];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]initWithString:s];

    // добавим атрибуты для всего текста
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setParagraphSpacing:5.0];
    [paragraphStyle setAlignment:NSJustifiedTextAlignment];
    [paragraphStyle setDefaultTabInterval:10.0];
    
    [paragraphStyle setFirstLineHeadIndent:10.0];
    [paragraphStyle setTailIndent:10.0];
    
    [aboutMessage setDefaultParagraphStyle:paragraphStyle];
    
    NSMutableDictionary *atrs = [NSMutableDictionary dictionary];
    [atrs setObject:[NSFont systemFontOfSize:12.0] forKey:NSFontAttributeName];
    
    NSRange vse; vse.location = 0; vse.length = [s length];
    [as addAttributes:atrs range:vse];

    // теперь добавим http-линк на видео (ABOUT2)
    atrs = [NSMutableDictionary dictionary];
    [atrs setObject:[NSURL URLWithString: NSLocalizedString(@"LINK_VIDEO", @"video http link")] forKey:NSLinkAttributeName];
    NSRange videoLinkRange;
    videoLinkRange.location = [NSLocalizedString(@"ABOUT1", @"about1") length];
    videoLinkRange.length = [NSLocalizedString(@"ABOUT2", @"video") length];
    [as addAttributes:atrs range:videoLinkRange];
    
    // а теперь mailto-линк на фамилию (ABOUT4)
    atrs = [NSMutableDictionary dictionary];
    [atrs setObject:[NSURL URLWithString: NSLocalizedString(@"LINK_MAIL", @"mailto: link")] forKey:NSLinkAttributeName];
    NSRange mailLinkRange;
    mailLinkRange.location = [NSLocalizedString(@"ABOUT1", @"about1") length] +
                                [NSLocalizedString(@"ABOUT2", @"about1") length] +
                                [NSLocalizedString(@"ABOUT3", @"about1") length];
    mailLinkRange.length = [NSLocalizedString(@"ABOUT4", @"name") length];
    [as addAttributes:atrs range:mailLinkRange];
    
    [[aboutMessage textStorage] setAttributedString: as];
    [panel makeKeyAndOrderFront:self];
    
/*
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Message text"];
    [alert setInformativeText:@"Informative text"];
//    [alert setAccessoryView:accessory];
//    [alert runModal];
*/    
//    [panel displayIfNeeded];


//    [aboutMessage setToolTip:@"about tip"];
//    [panel setTitle:@"Oo"];

}


-(NSPanel *)panel {
    return panel;
}

@end
