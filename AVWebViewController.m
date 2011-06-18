//
//  AVWebViewController.m
//
//  Created by Abraham Vegh on 6/12/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import "AVWebViewController.h"

#pragma mark Class continuation

@interface AVWebViewController ()

- (void) updateUI;
- (void) updateToolbar;
- (void) showActionSheet;
- (void) stopLoading;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *backItem;
@property (nonatomic, retain) UIBarButtonItem *forwardItem;
@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;
@property (nonatomic, retain) UIBarButtonItem *indicatorItem;
@property (nonatomic, retain) UIBarButtonItem *loadItem;
@property (nonatomic, retain) UIBarButtonItem *actionItem;
@property (nonatomic, retain) UIBarButtonItem *fixedSpaceItem;
@property (nonatomic, retain) UIBarButtonItem *flexibleSpaceItem;

@end

@implementation AVWebViewController

@synthesize URLString = _URLString;
@synthesize webView = _webView;
@synthesize backItem = _backItem;
@synthesize forwardItem = _forwardItem;
@synthesize indicatorView = _indicatorView;
@synthesize indicatorItem = _indicatorItem;
@synthesize loadItem = _loadItem;
@synthesize actionItem = _actionItem;
@synthesize fixedSpaceItem = _fixedSpaceItem;
@synthesize flexibleSpaceItem = _flexibleSpaceItem;


#pragma mark -
#pragma mark Initialization

- (id) initWithURLString: (NSString *) URLString
{
	self = [super initWithNibName: nil bundle: nil];
	self.URLString = URLString;

	return self;
}

#pragma mark -
#pragma mark Setter overrides

- (void) setURLString: (NSString *) URLString
{
	if (_URLString == URLString)
		return;
		
	[self willChangeValueForKey:@"URLString"];
	[_URLString release];
	_URLString = [URLString copy];
	[self didChangeValueForKey:@"URLString"];

	if (![self isViewLoaded])
		return;
		
	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.URLString]]];
}

#pragma mark -
#pragma mark Getter overrides

- (UIBarButtonItem *) backItem
{
	if (_backItem == nil)
		_backItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"AVWebViewController.bundle/back"] 
													 style: UIBarButtonItemStylePlain 
													target: self.webView 
													action: @selector(goBack)];

	_backItem.enabled = self.webView.canGoBack;

	return _backItem;
}

- (UIBarButtonItem *) forwardItem
{
	if (_forwardItem == nil)
		_forwardItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"AVWebViewController.bundle/forward"] 
														style: UIBarButtonItemStylePlain 
													   target: self.webView 
													   action: @selector(goForward)];

	_forwardItem.enabled = self.webView.canGoForward;

	return _forwardItem;
}

- (UIActivityIndicatorView *) indicatorView
{
	if (_indicatorView == nil)
		_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];

	_indicatorView.hidesWhenStopped = YES;

	return _indicatorView;
}

- (UIBarButtonItem *) indicatorItem
{
	if (_indicatorItem == nil)
		_indicatorItem = [[UIBarButtonItem alloc] initWithCustomView: self.indicatorView];

	return _indicatorItem;
}

- (UIBarButtonItem *) actionItem
{
	if (_actionItem == nil)
		_actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction 
																	target: self 
																	action: @selector(showActionSheet)];

	return _actionItem;
}

- (UIBarButtonItem *) fixedSpaceItem
{
	if (_fixedSpaceItem == nil)
	{
		_fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target: nil action: nil];
		_fixedSpaceItem.width = 12.0;
	}

	return _fixedSpaceItem;
}

- (UIBarButtonItem *) flexibleSpaceItem
{
	if (_flexibleSpaceItem == nil)
		_flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];

	return _flexibleSpaceItem;
}

#pragma mark -
#pragma mark View lifecycle

- (void) loadView
{
	[super loadView]; // technically illegal, may cause infinite recursion below if Apple changes how things work in the back

	self.webView = [[[UIWebView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
	self.webView.delegate = self;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.scalesPageToFit = YES;
	self.view = self.webView;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.URLString]]];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

	self.navigationController.toolbarHidden = NO;

	[self updateUI];
}

- (void) viewWillDisappear: (BOOL) animated
{
	[self.webView stopLoading];

	self.navigationController.toolbarHidden = YES;

	[super viewWillDisappear: animated];
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
	self.loadItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: self.webView.isLoading ? UIBarButtonSystemItemStop : UIBarButtonSystemItemRefresh 
																  target: self 
																  action: self.webView.isLoading ? @selector(stopLoading) : @selector(reload)];
	self.toolbarItems = [NSArray arrayWithObjects: 
						 self.fixedSpaceItem, 
						 self.backItem, 
						 self.flexibleSpaceItem, 
						 self.forwardItem, 
						 self.flexibleSpaceItem, 
						 self.indicatorItem, 
						 self.flexibleSpaceItem, 
						 self.loadItem, 
						 self.flexibleSpaceItem, 
						 self.actionItem, 
						 self.fixedSpaceItem, 
						 nil];

	self.webView.isLoading ? [self.indicatorView startAnimating] : [self.indicatorView stopAnimating] ;
}

- (void) showActionSheet
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: self.URLString 
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

- (void) stopLoading
{
	[self.webView stopLoading];
}

- (void) reload
{
	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.URLString]]];
}

- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
  navigationType: (UIWebViewNavigationType) navigationType
{
	[_URLString release];

	_URLString = [request.URL.absoluteString copy];
	
	return YES;
}

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
	if (buttonIndex == 0)
	{
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: self.URLString]];
	}
	else if (buttonIndex == 1)
	{
		MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init]; 

		[composer setMailComposeDelegate: self]; 
		[composer setMessageBody: self.URLString isHTML: NO];
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
	self.backItem = nil;
	self.forwardItem = nil;
	self.indicatorView = nil;
	self.indicatorItem = nil;
	self.loadItem = nil;
	self.actionItem = nil;
	self.fixedSpaceItem = nil;
	self.flexibleSpaceItem = nil;

	[super viewDidUnload];
}

- (void) dealloc
{
	[_URLString release];
	[_webView release];
	[_backItem release];
	[_forwardItem release];
	[_indicatorView release];
	[_indicatorItem release];
	[_loadItem release];
	[_actionItem release];
	[_fixedSpaceItem release];
	[_flexibleSpaceItem release];
	[super dealloc];
}

@end
