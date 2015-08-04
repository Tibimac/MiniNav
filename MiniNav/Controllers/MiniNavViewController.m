//
//  MiniNavViewController.m
//  MiniNav
//
//  Created by Tibimac on 01/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "MiniNavViewController.h"
#import "MiniNavView.h"

@implementation MiniNavViewController
#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Création de la vue gérée par ce controleur
    mainMiniNavView = [[MiniNavView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [mainMiniNavView setController:self];                                           // On indique à la vue qu'on va la controler. (La vue connait ainsi son controleur)
    [[mainMiniNavView miniNavWebView] setDelegate:self];                            // On indique à la UIWebView que nous gérons son protocol de délégation
    [[mainMiniNavView alertToSetCustomUrl] setDelegate:self];                       // On indique a la UIAlertView que nous gérons son protocol de délégation
    [[[mainMiniNavView alertToSetCustomUrl] textFieldAtIndex:0] setDelegate:self];  // On indique au UITextField de la UIAlertView que nous gérons son protocol de délégation
    
    // Le bouton de retour vers la page d'accueil est désactivé lorsqu'on est sur le page d'accueil
    // Ce qui est le cas au lancement de l'app puisqu'on lance directement la page d'accueil
    [[mainMiniNavView goToHomeButton] setEnabled:NO];
    
    // On désactive le bouton pendant le chargement d'une requête et on l'initiliase ainsi puisqu'on charge une page d'accueil dés le lancement
    // Cela permet une bonne gestion du vidage ou non du champ de la UIAlertView (voir méthode - (void)webViewDidFinishLoad:(UIWebView *)webView)
    [[mainMiniNavView goToCustomURLButton] setEnabled:NO];
    
    
    // On relie la vue créé a la vue dirigée par ce controlleur. (Le controleur connait ainsi la vue qu'il gère)
    [[self view] addSubview:mainMiniNavView];
    
    
    // Ajout d'un observateur pour être averti lorsque la statusBar change de taille
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(statusBarDidChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    
    homeURL = [[NSURL alloc] initWithString:@"http://www.google.fr"];
    
    [self goToHomePage];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [homeURL release];
}


/* ************************************************** */
/* ----------- Rotation et Modif StatusBar ---------- */
#pragma mark -
#pragma mark Draw View Methods
- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [mainMiniNavView setViewFromOrientation:toInterfaceOrientation
                         withStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame]];
}


-(void)statusBarDidChange
{
    [mainMiniNavView setViewFromOrientation:[[UIApplication sharedApplication] statusBarOrientation]
                         withStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame]];
}



/* ************************************************** */
/* ------------- Bouton Page Précédente ------------- */
#pragma mark -
#pragma mark Action Methods
- (void)goToPreviousPage
{
    [[mainMiniNavView miniNavWebView] goBack];
    [[mainMiniNavView miniNavWebView] setNeedsDisplay];
}



/* ************************************************** */
/* -------------- Bouton Page Suivante -------------- */
- (void)goToNextPage
{
    [[mainMiniNavView miniNavWebView] goForward];
    [[mainMiniNavView miniNavWebView] setNeedsDisplay];
}



/* ************************************************** */
/* ---------------- Bouton Recharger ---------------- */
- (void)reloadPage
{
    [[mainMiniNavView miniNavWebView] reload];
}



/* ************************************************** */
/* -------------- Bouton Page d'Accueil ------------- */
- (void)goToHomePage
{
    NSURLRequest *home = [NSURLRequest requestWithURL:homeURL];
    [[mainMiniNavView miniNavWebView] loadRequest:home];
}



/* ************************************************** */
/* ------------- AlertView 'Saisir URL' ------------- */
- (void)goToCustomURL
{
    [[mainMiniNavView alertToSetCustomUrl] show];
}



/* ************************************************** */
/* ------------ UIWebViewDelegate Methods ----------- */
#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[mainMiniNavView spinner] startAnimating];
    [[mainMiniNavView goToCustomURLButton] setEnabled:NO];
//    NSLog(@"Reload - Url : %@", [[[[mainMiniNavView miniNavWebView] request] URL] absoluteString]);
}



- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[mainMiniNavView spinner] stopAnimating];
    [[mainMiniNavView goToCustomURLButton] setEnabled:YES];
    
    UIAlertView *alertViewError = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                             message:[NSString stringWithFormat:@"%@", [error localizedDescription]]
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil];
    [alertViewError setAlertViewStyle:UIAlertViewStyleDefault];
    
    [alertViewError show];
    [alertViewError release];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[mainMiniNavView spinner] stopAnimating];
    [[mainMiniNavView goToCustomURLButton] setEnabled:YES];
    
    // Mise à jour de la couleur des bouton avant/arriere
    if ([[mainMiniNavView miniNavWebView] canGoBack])
    {
        [[mainMiniNavView goToPreviousButton] setEnabled:YES];
    }
    else
    {
        [[mainMiniNavView goToPreviousButton] setEnabled:NO];
    }
    
    if ([[mainMiniNavView miniNavWebView] canGoForward])
    {
        [[mainMiniNavView goToNextButton] setEnabled:YES];
    }
    else
    {
        [[mainMiniNavView goToNextButton] setEnabled:NO];
    }
    
    if ([@"https://www.google.fr/?gws_rd=ssl" isEqual:[[[[mainMiniNavView miniNavWebView] request] URL] absoluteString]])
    {
        [[mainMiniNavView goToHomeButton] setEnabled:NO];
    }
    else
    {
        [[mainMiniNavView goToHomeButton] setEnabled:YES];
    }
    
    // Affecte l'URL courante au label
    [[mainMiniNavView urlOfPage] setText:[NSString stringWithFormat:@"%@",[[[[mainMiniNavView miniNavWebView] request] URL] absoluteString]]];
    
    
//  Si l'utilisateur a déjà utilisé la UIAlertView et a saisi du texte alors
//  ce texte est toujours contenu dans le champ de saisi.
//  Il peut être intéressant d'afficher de nouveau le contenu du champ si l'utilisateur s'est trompé dans l'URL
//  pour qu'il puisse corriger.
//  S'il a bien saisi l'URL alors on videra le champ.
//  Il est fort probable que l'utilisateur n'ai pas mis de / à la fin de l'URL qu'il a saisi or souvent un / est rajouté à la fin d'une URL;
//      On construit donc une URL avec la saisi de l'utilisateur + un / à la fin
//      On compare ensuite les 2 chaines à l'URL courante et si l'URL saisi par l'utilisateur est bonne alors :
//          L'URL actuelle correspondra soit :
//              - à la saisi de l'utilisateur sans le /
//              - à la chaine construite avec l'URL saisi + le /
//      On peut donc vider le champ avant affichage.
    
    // Reecupération du contenu du champ
    NSString *inputTextFromUser = [[[mainMiniNavView alertToSetCustomUrl] textFieldAtIndex:0] text];
    
    // Si le contenu n'est pas vide, l'utilisateur a donc déjà écris au préalable
    if (![inputTextFromUser isEqual:@""])
    {
        // Construction d'une chaine temporaire contenant l'URL saisi par l'utilisateur à laquelle on ajoute un /
        NSString *inputTextFromUserWithSlash = [[NSString alloc] initWithFormat:@"%@/", inputTextFromUser];
        // On récupère l'URL courante
         NSString *currentURL = [[[[mainMiniNavView miniNavWebView] request] URL] absoluteString];
        
        // Si l'URL actuelle correspondant à l'une des deux chaines, l'utilisateur a donc saisi correctement l'URL
        if (([currentURL isEqual:inputTextFromUser]) || ([currentURL isEqual:inputTextFromUserWithSlash]))
        {
            // On vide le champ avant affichage de la UIAlertView
            [[[mainMiniNavView alertToSetCustomUrl] textFieldAtIndex:0] setText:@"http://"];
        }
        
        [inputTextFromUserWithSlash release];
    }
}



/* ************************************************** */
/* ----------- UIAlertViewDelegate Methods ---------- */
#pragma mark -
#pragma mark UIAlertViewDelegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *inputTextFromUser = [[[mainMiniNavView alertToSetCustomUrl] textFieldAtIndex:0] text];
        
//      Teste si l'utilisateur a saisi le http:// au début de l'url.
//      Si oui on charge l'url telle qu'elle, sinon on fait un recherche Google sur le terme saisi
        NSURL *url;
        NSURLRequest *customURLRequest;

        if ([inputTextFromUser rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location == NSNotFound) // Non sensible à la casse (http et HTTP sont égaux)
        {
            // Si l'URL n'est pas bonn, plutôt que d'afficher une erreur à l'utilisateur, j'utilise sa saisie pour faire une recherche Google, c'est plus "user-friendly" ^^
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.fr/search?q=%@", inputTextFromUser]];
            customURLRequest = [NSURLRequest requestWithURL:url];
        }
        else
        {
            url = [NSURL URLWithString:inputTextFromUser];
            customURLRequest = [NSURLRequest requestWithURL:url];
        }
        
        [[mainMiniNavView miniNavWebView] loadRequest:customURLRequest]; // Chargement de la requête créée
    }
}



/* ************************************************** */
/* ----------- UITextFieldDelegate Methods ---------- */
#pragma mark -
#pragma mark UITextFiedDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
/* === Les 2 méthodes suivantes sont nécessaire. Pour que le fonctionnement soit complet les deux doivent être là === */
//  Permet de faire disparaitre la UIAlertView lorsqu'on appui sur "retour" du clavier.
//  Peu importe le numéro passé en paramètre.
    [[mainMiniNavView alertToSetCustomUrl] dismissWithClickedButtonIndex:1 animated:YES];
    
//  Permet d'appeler la méthode qui récupère le contenu du champ passé en paramètre et lancer la requête
    [self alertView: [mainMiniNavView alertToSetCustomUrl] clickedButtonAtIndex:1];
    
    
    return YES;
}



#pragma mark -
- (void)dealloc
{
    [homeURL release];
    [mainMiniNavView release];
    [super dealloc];
}
@end
