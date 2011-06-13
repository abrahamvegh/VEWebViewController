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
	AVWebViewController *v = [[AVWebViewController alloc] initWithURLString: @"http://www.apple.com/"];
	UINavigationController *n = [[UINavigationController alloc] initWithRootViewController: v];

	[self.window addSubview: n.view];
	[self.window makeKeyAndVisible];

	return YES;
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
