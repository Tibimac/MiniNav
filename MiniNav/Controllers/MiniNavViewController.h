//
//  MiniNavViewController.h
//  MiniNav
//
//  Created by Tibimac on 01/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MiniNavView;

@interface MiniNavViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
    MiniNavView *mainMiniNavView; // Vue principale gérée par le controlleur
    NSURL *homeURL;
}

- (void)goToPreviousPage;
- (void)goToNextPage;
- (void)reloadPage;
- (void)goToHomePage;
- (void)goToCustomURL;

@end