//
//  MiniNavView.m
//  MiniNav
//
//  Created by Tibimac on 01/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "MiniNavView.h"
#import "MiniNavViewController.h"

@implementation MiniNavView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        isiPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
        isiOS7 = ([[[UIDevice currentDevice] systemVersion] characterAtIndex:0] == '7');
        
        
        /* ************************************************** */
        /* -------------- Crétation des espaces ------------- */
        UIBarButtonItem *fixSpace20;
        fixSpace20 = [[UIBarButtonItem alloc]
                      initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil
                                           action:@selector(alloc)];
        [fixSpace20 setWidth:20];

        UIBarButtonItem *flexSpace;
        flexSpace = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                          target:nil
                                          action:@selector(alloc)];
        
        
        /* ************************************************** */
        /* ------------------- ToolBar Top ------------------ */
        toolBarTop = [[UIToolbar alloc] init];
        [toolBarTop setBarStyle:UIBarStyleDefault];
        [self addSubview:toolBarTop];
        [toolBarTop release];
        
        
        /* ************************************************** */
        /* ---------------- Spinner chargement -------------- */
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_spinner setHidesWhenStopped:YES];
        
        UIBarButtonItem *spin = [[UIBarButtonItem alloc] initWithCustomView:_spinner];
        [spin setWidth:20];
        [_spinner release];
        
        /* ************************************************** */
        /* -------- "Label" affichant l'URL actuelle -------- */
        _urlOfPage = [[UILabel alloc] init];
        [_urlOfPage setTextAlignment:NSTextAlignmentCenter];
        [_urlOfPage setBackgroundColor:[UIColor colorWithRed:0.88
                                                       green:0.88
                                                        blue:0.88
                                                       alpha:0.5]];
        if (!isiOS7)
        {
            if (isiPhone)
            {
                [_urlOfPage setTextColor:[UIColor whiteColor]];
                [_urlOfPage setShadowColor:[UIColor darkGrayColor]];
            }
            else
            {
                [_urlOfPage setTextColor:[UIColor blackColor]];
                [_urlOfPage setShadowColor:[UIColor grayColor]];
            }
            
            [_urlOfPage setBackgroundColor:[UIColor clearColor]];
        }
        
        [self addSubview:_urlOfPage];
        [_urlOfPage release];

        
        /* ************************************************** */
        /* ------------------ Bouton reload ----------------- */
        reloadPageButton = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                target:_controller
                                                action:@selector(reloadPage)];
        
        
        /* ************************************************** */
        /* --------------- Assemblage ToolBar --------------- */
        [toolBarTop setItems:[NSArray arrayWithObjects: spin, flexSpace, reloadPageButton, nil]];
        [spin release];
        [reloadPageButton release];
        
        
        /* ************************************************** */
        /* --------------------- WebView -------------------- */
        _miniNavWebView = [[UIWebView alloc] init];
        [_miniNavWebView setDelegate:_controller];
        [_miniNavWebView setScalesPageToFit:YES];
        
        
        [self addSubview:_miniNavWebView];
        [_miniNavWebView release];
        
        
        /* ************************************************** */
        /* ----------------- ToolBar Bottom ----------------- */
        toolBarBottom = [[UIToolbar alloc] init];
        [toolBarBottom setBarStyle:UIBarStyleDefault];
        [self addSubview:toolBarBottom];
        [toolBarBottom release];
        
        
        /* ************************************************** */
        /* ----------------- Bouton 'Home' ------------------ */
        _goToHomeButton = [[UIBarButtonItem alloc]
                          initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                               target:_controller
                                               action:@selector(goToHomePage)];
        
        
        /* ************************************************** */
        /* ------------ Bouton 'page précécente' ------------ */
        _goToPreviousButton = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                    target:_controller
                                                    action:@selector(goToPreviousPage)];
        [_goToPreviousButton setEnabled:NO];
        
        
        /* ************************************************** */
        /* ------------- Bouton 'page suivante' ------------- */
        _goToNextButton = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                target:_controller
                                                action:@selector(goToNextPage)];
         [_goToNextButton setEnabled:NO];
        
        
        /* ************************************************** */
        /* --------------- Bouton 'Saisir URL' -------------- */
        _goToCustomURLButton = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                    target:_controller
                                                    action:@selector(goToCustomURL)];
        
        
        /* ************************************************** */
        /* --------------- Assemblage ToolBar --------------- */
        [toolBarBottom setItems:[NSArray arrayWithObjects:
                                 _goToHomeButton, flexSpace,
                                 _goToPreviousButton, fixSpace20,
                                 _goToNextButton, flexSpace,
                                 _goToCustomURLButton, nil]];
        
        
        /* ************************************************** */
        /* ----------- Release des UIBarButtonItem ---------- */
        [_goToHomeButton release];
        [_goToPreviousButton release];
        [_goToNextButton release];
        [_goToCustomURLButton release];
        [flexSpace release];
        [fixSpace20 release];
        
        
        /* ************************************************** */
        /* ------------- AlertView 'Saisir URL' ------------- */
        _alertToSetCustomUrl = [[UIAlertView alloc] initWithTitle:@"URL"
                                                         message:@"Saisissez une URL :"
                                                        delegate:_controller
                                               cancelButtonTitle:@"Annuler"
                                               otherButtonTitles:@"Aller", nil];
        [_alertToSetCustomUrl setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[_alertToSetCustomUrl textFieldAtIndex:0] setText:@"http://"];
        
        
        /* ************************************************** */
        /* ------------ Positionnement des objets ----------- */
        [self setViewFromOrientation:[[UIApplication sharedApplication] statusBarOrientation]
                  withStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame]];
        
        return self;
    }
    else
    {
        return nil;
    }
}


#pragma mark -
#pragma mark Draw Methods

- (void)setViewFromOrientation:(UIInterfaceOrientation)orientation withStatusBarFrame:(CGRect)statusBarFrame
{
    #pragma mark Debug UI Position
    /* ======================= DEBUG ======================= */
//    [toolBarTop setBackgroundColor:[UIColor yellowColor]];
//    [miniNavWebView setBackgroundColor:[UIColor yellowColor]];
//    [toolBarBottom setBackgroundColor:[UIColor yellowColor]];
//    [self setBackgroundColor:[UIColor yellowColor]];
    /* ===================================================== */
    
    
    #pragma mark Positioning Objects
     /* ----------------- INFO ----------------- *\
     |  CGRectMake(pos.X, pos.Y, width, height);  |
     \* ---------------------------------------- */
    
    #define MARGE_X 10
    #define TOOLBAR_HEIGHT 45
    
    CGFloat MARGE_Y = 0.0;
    CGFloat MARGE_STATUSBAR = 0.0;
    
    if (isiOS7) { MARGE_Y = 20.0; }
    
    if (statusBarFrame.size.height > 20) { MARGE_STATUSBAR = statusBarFrame.size.height-20; }
    
    /* ========== Définition de la hauteur et largeur de la vue principale en fonction de l'orientation du iDevice ========== */
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        // On déduit la hauteur supplémentaire de la statusBar si elle fait plus que ses 20pts habituel
        if (isiOS7) {   [self setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-MARGE_STATUSBAR)]; }
        if (!isiOS7) {  [self setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-(20+MARGE_STATUSBAR))]; } // Sur iOS 6 on déduit les 20pt de décalage
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if (isiOS7) {   [self setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)]; }
        if (!isiOS7) {  [self setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width-20)]; }// Sur iOS 6 on déduit les 20pt de décalage
    }
    
    CGFloat viewWidth = [self bounds].size.width;
    
    [toolBarTop setFrame:CGRectMake(0, MARGE_Y, viewWidth, TOOLBAR_HEIGHT)];
    
    if (isiPhone){  [_urlOfPage setFrame:CGRectMake((viewWidth-(viewWidth-100))/2, MARGE_Y+10, viewWidth-100, 25)]; }
    if (!isiPhone){ [_urlOfPage setFrame:CGRectMake((viewWidth-(viewWidth-120))/2, MARGE_Y+10, viewWidth-120, 25)]; }
        
    [_miniNavWebView setFrame:CGRectMake(0, MARGE_Y+TOOLBAR_HEIGHT, [self bounds].size.width, [self bounds].size.height-((TOOLBAR_HEIGHT*2)+MARGE_Y))];
    [toolBarBottom setFrame:CGRectMake(0, [self bounds].size.height-TOOLBAR_HEIGHT, [self bounds].size.width, TOOLBAR_HEIGHT)];
}



- (void)dealloc
{
    /* ************************************************** */
    /* --------- Release des objets persistants --------- */
    [_alertToSetCustomUrl release];
    [super dealloc];
}

@end