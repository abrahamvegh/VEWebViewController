//
//  AVWebViewController.h
//
//  Created by Abraham Vegh on 6/12/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AVWebViewController : UIViewController
{
	NSString *_URLString;
@private
	UIWebView *_webView;
	UIBarButtonItem *_backItem;
	UIBarButtonItem *_forwardItem;
	UIActivityIndicatorView *_indicatorView;
	UIBarButtonItem *_indicatorItem;
	UIBarButtonItem *_loadItem;
	UIBarButtonItem *_actionItem;
	UIBarButtonItem *_fixedSpaceItem;
	UIBarButtonItem *_flexibleSpaceItem;
}

@property (nonatomic, copy) NSString *URLString; // Set this to navigate the web view to a new URL

- (id) initWithURLString: (NSString *) URLString;
- (void) reload;

@end
