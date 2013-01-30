//
//  VEWebViewController.m
//
//  Created by Abraham Vegh on 6/12/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import "VEWebViewController.h"
#import <MessageUI/MessageUI.h>

@interface VEWebViewController () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property BOOL toolbarWasHidden;
@property (retain) UIWebView *webView;
@property (copy) NSString *URLString;
@property NSInteger activityCount;

- (void) UI;
- (void) captureURLString: (NSString *) URLString;
- (void) showActionSheet;

@end

@implementation VEWebViewController

@synthesize toolbarWasHidden = _toolbarWasHidden;
@synthesize webView = _webView;
@synthesize URLString = _URLString;
@synthesize activityCount = _activityCount;

- (NSInteger) activityCount
{
	return _activityCount;
}

- (void) setActivityCount: (NSInteger) count
{
	_activityCount = MAX(count, 0);
}

- (void) viewDidUnload
{
	self.webView.delegate = nil;
	self.webView = nil;
	self.URLString = nil;

	[super viewDidUnload];
}

- (void) dealloc
{
	[_webView release];
	[_URLString release];
	[super dealloc];
}

- (id) initWithURLString: (NSString *) URLString
{
	self = [super initWithNibName: nil bundle: nil];

	if (self)
	{
		self.URLString = URLString;
	}
	
	return self;
}

- (void) loadView
{
	self.webView = [[[UIWebView alloc] initWithFrame: CGRectZero] autorelease];
	self.webView.delegate = self;
	self.webView.scalesPageToFit = YES;
	self.view = self.webView;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation duration: (NSTimeInterval) duration
{
	[self.webView setNeedsLayout];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.URLString]]];
}

- (void) viewWillAppear: (BOOL) animated
{
	[super viewWillAppear: animated];

	self.toolbarWasHidden = self.navigationController.isToolbarHidden;

	if (self.toolbarWasHidden)
		[self.navigationController setToolbarHidden: NO animated: animated];
}

- (void) viewDidAppear: (BOOL) animated
{
	if (self.navigationController.isToolbarHidden)
		[self.navigationController setToolbarHidden: NO animated: animated];
}

- (void) viewWillDisappear: (BOOL) animated
{
	[super viewWillDisappear: animated];

	if (self.toolbarWasHidden)
		[self.navigationController setToolbarHidden: YES animated: animated];
}

- (void) UI
{
	self.title = [self.webView stringByEvaluatingJavaScriptFromString: @"document.title"];

	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target: nil action: nil];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"VEWebViewController.bundle/back"] style: UIBarButtonItemStylePlain target: self.webView action: @selector(goBack)];
	UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
	UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"VEWebViewController.bundle/forward"] style: UIBarButtonItemStylePlain target: self.webView action: @selector(goForward)];
	UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
	UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem *indicatorItem = [[UIBarButtonItem alloc] initWithCustomView: indicatorView];
	UIBarButtonItem *flexibleSpace4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
	UIBarButtonItem *controlButton = nil;
	
	if (self.activityCount > 0)
		controlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop target: self.webView action: @selector(stopLoading)];
	else
		controlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self.webView action: @selector(reload)];
	
	UIBarButtonItem *flexibleSpace6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: self action: @selector(showActionSheet)];
	
	fixedSpace.width = 12.0;
	backButton.enabled = self.webView.canGoBack;
	forwardButton.enabled = self.webView.canGoForward;

	if (self.activityCount > 0) [indicatorView startAnimating];

	self.toolbarItems = [NSArray arrayWithObjects: fixedSpace, backButton, flexibleSpace1, forwardButton, flexibleSpace2, 
						 indicatorItem, flexibleSpace4, controlButton, flexibleSpace6, actionButton, fixedSpace, nil];
	
	[fixedSpace release];
	[backButton release];
	[flexibleSpace1 release];
	[forwardButton release];
	[flexibleSpace2 release];
	[indicatorView release];
	[indicatorItem release];
	[flexibleSpace4 release];
	[controlButton release];
	[flexibleSpace6 release];
	[actionButton release];
}

- (void) showActionSheet
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: self.URLString 
															 delegate: self 
													cancelButtonTitle: nil 
											   destructiveButtonTitle: nil 
													otherButtonTitles: nil];

	[actionSheet addButtonWithTitle: NSLocalizedString(@"Open in Safari", @"Open in Safari")];

	if ([MFMailComposeViewController canSendMail])
		[actionSheet addButtonWithTitle: NSLocalizedString(@"Mail Link", @"Mail Link")];

	[actionSheet addButtonWithTitle: NSLocalizedString(@"Cancel", @"Cancel")];
	[actionSheet setCancelButtonIndex: actionSheet.numberOfButtons - 1];
	[actionSheet showFromToolbar: self.navigationController.toolbar];
	[actionSheet release];
}

#pragma mark UIActionSheetDelegate

- (void) actionSheet: (UIActionSheet *) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
	if (buttonIndex == 0)
	{
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: self.URLString]];
	}
	else if (buttonIndex == 1)
	{
		MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init]; 
		
		[composer setMailComposeDelegate: self];
		[composer setSubject: [self.webView stringByEvaluatingJavaScriptFromString: @"document.title"]];
		[composer setMessageBody: self.URLString isHTML: NO];
		[self presentViewController: composer animated: YES completion: NULL];
		[composer release];
	}
}

#pragma mark MFMailComposeViewControllerDelegate

- (void) mailComposeController: (MFMailComposeViewController *) controller 
		   didFinishWithResult: (MFMailComposeResult) result 
						 error: (NSError *) error
{
	[controller dismissViewControllerAnimated: YES completion: NULL];
}

#pragma mark UIWebViewDelegate

- (void) captureURLString: (NSString *) URLString
{
	if (self.activityCount == 0) self.URLString = URLString;
}

- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
  navigationType: (UIWebViewNavigationType) navigationType
{
	[self captureURLString: request.URL.absoluteString];
	[self UI];

	return YES;
}

- (void) webViewDidStartLoad: (UIWebView *) webView
{
	self.activityCount += 1;

	[self UI];
}

- (void) webViewDidFinishLoad: (UIWebView *) webView
{
	self.activityCount -= 1;

	[self captureURLString: webView.request.URL.absoluteString];
	[self UI];
}

- (void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error
{
	self.activityCount -= 1;

	[self UI];
}

@end
