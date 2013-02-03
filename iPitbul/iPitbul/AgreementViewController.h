//
//  LegalAndPrivacyViewController.h
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 25.12.12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgreementViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)done:(id)sender;

@end
