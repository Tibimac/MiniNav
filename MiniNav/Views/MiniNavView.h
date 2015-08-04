//
//  MiniNavView.h
//  MiniNav
//
//  Created by Tibimac on 01/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MiniNavViewController;

@interface MiniNavView : UIView
{
    UIToolbar *toolBarTop;
        UIBarButtonItem *reloadPageButton;
//        UITextField *champURL; V2 - Saisie d'une nouvelle URL dans une barre d'adresse à la place d'une UIAlertView
    
    UIToolbar *toolBarBottom;
    
    BOOL isiPhone;
    BOOL isiOS7;
}

// Controleur de la vue.
// Les évènements sur la vue seront reçus par le controleur.
@property (readwrite, retain) UIViewController <UIWebViewDelegate, UIAlertViewDelegate, UITextFieldDelegate> *controller;

// Boutons de la toolbar du haut
@property (readonly, copy) UIActivityIndicatorView *spinner;
@property (readwrite, retain) UILabel *urlOfPage;

// WebView
@property (readonly, copy) UIWebView *miniNavWebView;

// Boutons de la toolbar du bas
@property (readonly, copy) UIBarButtonItem *goToHomeButton;
@property (readonly, copy) UIBarButtonItem *goToPreviousButton;
@property (readonly, copy) UIBarButtonItem *goToNextButton;
@property (readonly, copy) UIBarButtonItem *goToCustomURLButton;
@property (readonly, copy) UIAlertView *alertToSetCustomUrl;

- (void)setViewFromOrientation:(UIInterfaceOrientation)orientation
            withStatusBarFrame:(CGRect)statusBarFrame;

@end