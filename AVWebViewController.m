//
//  AVWebViewController.m
//
//  Created by Abraham Vegh on 6/12/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import "AVWebViewController.h"

@interface AVWebViewController () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property BOOL toolbarWasHidden;
@property (retain) UIWebView *webView;
@property (retain, nonatomic) NSURLRequest *currentRequest;
@property (nonatomic, readonly) NSString *URLString;
@property (nonatomic) NSInteger activityCount;

- (void) UI;
- (void) showActionSheet:(id)sender;

@end

@implementation AVWebViewController

@synthesize toolbarWasHidden = _toolbarWasHidden;
@synthesize webView = _webView;
@synthesize currentRequest = _currentRequest;
@synthesize activityCount = _activityCount;

- (NSString *) URLString
{
    if (_currentRequest) {
        return self.currentRequest.URL.absoluteString;
    }
    return nil;
}

- (void) setActivityCount: (NSInteger) count
{
	_activityCount = MAX(count, 0);
}

- (void) viewDidUnload
{
	self.webView.delegate = nil;
	self.webView = nil;
	self.currentRequest = nil;

	[super viewDidUnload];
}

- (void) dealloc
{
	[_webView release];
	[_currentRequest release];
	[super dealloc];
}

-(id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        _activityCount = 0;
        self.currentRequest = request;
    }
    return self;
}

- (id) initWithURLString: (NSString *) URLString
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	return [self initWithRequest:request];
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
    if (self.presentingViewController) {
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:self
                                                                           action:@selector(closeButtonTapped:)];
        
        self.navigationItem.rightBarButtonItem = closeButtonItem;
    }
	[self.webView loadRequest:self.currentRequest];
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
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"AVWebViewController.bundle/back"] style: UIBarButtonItemStylePlain target: self.webView action: @selector(goBack)];
	UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
	UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"AVWebViewController.bundle/forward"] style: UIBarButtonItemStylePlain target: self.webView action: @selector(goForward)];
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
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: self action: @selector(showActionSheet:)];
	
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

- (void)closeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) showActionSheet:(id)sender
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
	[actionSheet showFromBarButtonItem:sender animated:YES];
	[actionSheet release];
}

#pragma mark UIActionSheetDelegate

- (void) actionSheet: (UIActionSheet *) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
	if (buttonIndex == 0)
	{
		[[UIApplication sharedApplication] openURL:self.currentRequest.URL];
	}
	else if (buttonIndex == 1)
	{
		MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init]; 
		
		[composer setMailComposeDelegate: self];
		[composer setSubject: [self.webView stringByEvaluatingJavaScriptFromString: @"document.title"]];
		[composer setMessageBody: self.URLString isHTML: NO];
		[self presentModalViewController: composer animated: YES];
		[composer release];
	}
}

#pragma mark MFMailComposeViewControllerDelegate

- (void) mailComposeController: (MFMailComposeViewController *) controller 
		   didFinishWithResult: (MFMailComposeResult) result 
						 error: (NSError *) error
{
	[controller dismissModalViewControllerAnimated: YES];
}

#pragma mark UIWebViewDelegate

- (void) setCurrentRequest:(NSURLRequest *)currentRequest;
{
	if (self.activityCount == 0) _currentRequest = [currentRequest copy];
}

- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
  navigationType: (UIWebViewNavigationType) navigationType
{
	self.currentRequest = request;
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

	self.currentRequest = webView.request;
	[self UI];
}

- (void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error
{
	self.activityCount -= 1;

	[self UI];
}

@end
