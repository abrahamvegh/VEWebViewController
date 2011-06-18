//
//  AVWVC_TesterAppDelegate.m
//  AVWVC Tester
//
//  Created by Abraham Vegh on 6/13/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import "AVWVC_TesterAppDelegate.h"
#import "AVWebViewController.h"

@implementation AVWVC_TesterAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{

	NSMutableArray *pushedViewControllers = [NSMutableArray array];
	
	#if 0 // Testing bottom bar handling
	
		UIViewController *testViewController = [[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		testViewController.title = @"Testie";	
		testViewController.hidesBottomBarWhenPushed = YES;
		[pushedViewControllers addObject:testViewController];
	
	#endif

	AVWebViewController *webViewController = [[AVWebViewController alloc] initWithURLString: @"www.apple.com"];
	[pushedViewControllers addObject:webViewController];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[pushedViewControllers objectAtIndex:0]];
	
	for (UIViewController *aVC in pushedViewControllers)
	if (![navigationController.viewControllers containsObject:aVC])
	[navigationController pushViewController:aVC animated:NO];
	
	self.window.rootViewController = navigationController;
	[self.window makeKeyAndVisible];

	return YES;
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
