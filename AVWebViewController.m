//
//  AVWebViewController.m
//
//  Created by Abraham Vegh on 6/12/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import "AVWebViewController.h"

@interface AVWebViewController ()

- (void) updateUI;
- (void) updateToolbar;
- (void) showActionSheet;

@end

@implementation AVWebViewController

@synthesize URLString = _URLString;
@synthesize webView = _webView;

#pragma mark -
#pragma mark Initialization

- (id) initWithURLString: (NSString *) URLString
{
	self = [super initWithNibName: @"AVWebViewController" bundle: nil];
	_URLString = [URLString copy];

	return self;
}

- (void) setURLString: (NSString *) URLString
{
	[_URLString release];

	_URLString = [URLString copy];

	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.URLString]]];
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
// TODO: Do something intelligent when the network isn’t reachable
	self.navigationController.toolbarHidden = NO;
	self.webView.delegate = self;

	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.URLString]]];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
	[self updateUI];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark -
#pragma mark Control UI

- (void) updateUI
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: self.webView.isLoading];
	[self updateToolbar];

	self.title = [self.webView stringByEvaluatingJavaScriptFromString: @"document.title"];
}

- (void) updateToolbar
{
// TODO: Make this way more reuse-efficient than it is right now, because it totally blows right now
	[_backButton release];
	[_forwardButton release];
	[_loadButton release];
	[_actionButton release];

	// Back button
	_backButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"back"] 
												   style: UIBarButtonItemStylePlain 
												  target: self.webView 
												  action: @selector(goBack)];
	_backButton.enabled = self.webView.canGoBack;
	
	// Forward button
	_forwardButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"forward"] 
													  style: UIBarButtonItemStylePlain 
													 target: self.webView 
													 action: @selector(goForward)];
	_forwardButton.enabled = self.webView.canGoForward;
	
	// Activity indicator
	_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];

	self.webView.isLoading ? [_indicatorView startAnimating] : [_indicatorView stopAnimating] ;

	// Stop/reload button
	_loadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: self.webView.isLoading ? UIBarButtonSystemItemStop : UIBarButtonSystemItemRefresh 
																target: self.webView 
																action: self.webView.isLoading ? @selector(stopLoading) : @selector(reload)];

	// Action button
	_actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction 
																  target: self 
																  action: @selector(showActionSheet)];

	// I had no idea you could reuse these, and maybe you can’t, but it seems like you can, so what the hell
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target: nil action: nil];
	
	fixedSpace.width = 12.0;
	self.toolbarItems = [NSArray arrayWithObjects: 
						 fixedSpace, 
						 _backButton, 
						 flexibleSpace, 
						 _forwardButton, 
						 flexibleSpace, 
						 [[[UIBarButtonItem alloc] initWithCustomView: _indicatorView] autorelease], 
						 flexibleSpace, 
						 _loadButton, 
						 flexibleSpace, 
						 _actionButton, 
						 fixedSpace, 
						 nil];

	[flexibleSpace release];
	[fixedSpace release];
}

- (void) showActionSheet
{
// TODO: I would there to be some sort of delegate protocol for sending links to Instapaper
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: self.webView.request.mainDocumentURL.absoluteString
															 delegate: self 
													cancelButtonTitle: nil 
											   destructiveButtonTitle: nil 
													otherButtonTitles: @"Open in Safari", nil];

	if ([MFMailComposeViewController canSendMail])
		[actionSheet addButtonWithTitle: @"Mail Link"];

	[actionSheet addButtonWithTitle: @"Cancel"];
	[actionSheet setCancelButtonIndex: actionSheet.numberOfButtons - 1];
	[actionSheet showFromToolbar: self.navigationController.toolbar];
	[actionSheet release];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void) webViewDidStartLoad: (UIWebView *) webView
{
	[self updateUI];
}

- (void) webViewDidFinishLoad: (UIWebView *) webView
{
	[self updateUI];
}

- (void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error
{
	[self updateUI];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void) actionSheet: (UIActionSheet *) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
// FIXME: Fetching the URL from the webview request is non-reliable, and often gives back nothing
	if (buttonIndex == 0)
	{
		[[UIApplication sharedApplication] openURL: self.webView.request.mainDocumentURL];
	}
	else if (buttonIndex == 1)
	{
		MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init]; 

		[composer setMailComposeDelegate: self]; 
		[composer setMessageBody: self.webView.request.mainDocumentURL.absoluteString isHTML: NO];
		[self presentModalViewController: composer animated: YES];
		[composer release];
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void) mailComposeController: (MFMailComposeViewController *) controller 
		   didFinishWithResult: (MFMailComposeResult) result 
						 error: (NSError *) error
{
	[controller dismissModalViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark Memory management

- (void) viewDidUnload
{
	self.webView = nil;
}

- (void) dealloc
{
	[_webView release];
	[_backButton release];
	[_forwardButton release];
	[_indicatorView release];
	[_loadButton release];
	[_actionButton release];
	[super dealloc];
}

@end
