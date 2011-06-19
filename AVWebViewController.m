//
//  AVWebViewController.m
//
//  Created by Abraham Vegh on 6/12/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import "AVWebViewController.h"

#pragma mark Class continuation

@interface AVWebViewController () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

- (void) updateUI;
- (void) updateToolbar;
- (void) showActionSheet;
- (void) stopLoading;

- (void) setRepresentedURL:(NSURL *)newURL triggeringRequestLoad:(BOOL)shouldLoadRequestIfAppropriate;

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

@synthesize representedURL = _representedURL;
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

- (id) initWithURL: (NSURL *) anURL
{
	self = [super initWithNibName: nil bundle: nil];
	if (!self)
		return nil;
		
	self.representedURL = anURL;
	self.hidesBottomBarWhenPushed = NO;
		
	return self;
}

- (id) initWithURLString: (NSString *) URLString
{
	self = [self initWithURL:[NSURL URLWithString:URLString]];
	
	if (!self.representedURL.scheme)
		self.representedURL = [NSURL URLWithString:[@"http://" stringByAppendingString:URLString]];

	return self;
}

#pragma mark -
#pragma mark Setter overrides

- (void) setRepresentedURL:(NSURL *)newURL
{
	[self setRepresentedURL:newURL triggeringRequestLoad:YES];
}

- (void) setRepresentedURL:(NSURL *)newURL triggeringRequestLoad:(BOOL)shouldLoadRequestIfAppropriate 
{
	if (_representedURL == newURL || [_representedURL isEqual:newURL])
		return;
		
	[self willChangeValueForKey:@"representedURL"];
	[_representedURL release];
	_representedURL = [newURL copy];
	[self didChangeValueForKey:@"representedURL"];

	if (![self isViewLoaded])
		return;
		
	if (shouldLoadRequestIfAppropriate)
		[self.webView loadRequest: [NSURLRequest requestWithURL: _representedURL]];
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
	self.webView = [[[UIWebView alloc] initWithFrame: CGRectZero] autorelease];
	self.webView.delegate = self;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.scalesPageToFit = YES;
	self.view = self.webView;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.webView loadRequest: [NSURLRequest requestWithURL: _representedURL]];
}

static NSString * const kAVWebViewControllerNavigationControllerToolbarWasHidden = @"kAVWebViewControllerNavigationControllerToolbarWasHidden";

- (void) viewWillAppear: (BOOL) animated
{
	[super viewWillAppear: animated];

	id boundValue = self.navigationController.toolbarHidden ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
	objc_setAssociatedObject(self, kAVWebViewControllerNavigationControllerToolbarWasHidden, boundValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	self.navigationController.toolbarHidden = NO;

	[self updateUI];
}

- (void) viewWillDisappear: (BOOL) animated
{
	[self.webView stopLoading];
	
	//	Em, the animation does not look very right for me
	
	[self.navigationController setToolbarHidden:[objc_getAssociatedObject(self, kAVWebViewControllerNavigationControllerToolbarWasHidden) boolValue] animated:animated];
	objc_setAssociatedObject(self, kAVWebViewControllerNavigationControllerToolbarWasHidden, nil, OBJC_ASSOCIATION_ASSIGN);

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
	NSString *actionSheetTitle = [self.representedURL absoluteString];
	
	actionSheetTitle = [actionSheetTitle stringByReplacingOccurrencesOfString:@"(^http://)|(/$)" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [actionSheetTitle length])];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: actionSheetTitle
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

#pragma mark -
#pragma mark UIWebViewDelegate

- (void) stopLoading
{
	[self.webView stopLoading];
}

- (void) reload
{
	[self.webView loadRequest: [NSURLRequest requestWithURL: self.representedURL]];
}

- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
  navigationType: (UIWebViewNavigationType) navigationType
{
	[self setRepresentedURL:request.URL triggeringRequestLoad:NO];
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
		[[UIApplication sharedApplication] openURL:self.representedURL];
	}
	else if (buttonIndex == 1)
	{
		MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init]; 

		[composer setMailComposeDelegate: self]; 
		[composer setMessageBody: [self.representedURL absoluteString] isHTML: NO];
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
	[_representedURL release];
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
