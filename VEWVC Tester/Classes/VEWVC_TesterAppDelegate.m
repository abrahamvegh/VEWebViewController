//
//  VEWVC_TesterAppDelegate.m
//  VEWVC Tester
//
//  Created by Abraham Vegh on 6/13/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import "VEWVC_TesterAppDelegate.h"
#import "VEWebViewController.h"

@implementation VEWVC_TesterAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
	VEWebViewController *v = [[VEWebViewController alloc] initWithURLString: @"http://www.apple.com/"];
	UINavigationController *n = [[UINavigationController alloc] initWithRootViewController: v];

	self.window.rootViewController = n;

	[self.window makeKeyAndVisible];

	return YES;
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
