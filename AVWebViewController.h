//
//  AVWebViewController.h
//
//  Created by Abraham Vegh on 6/12/11.
//  Copyright 2011 Abraham Vegh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AVWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
	NSString *_URLString;
@private
	NSString                *_currentURLString;
	UIWebView               *_webView;
	UIBarButtonItem         *_backButton;
	UIBarButtonItem         *_forwardButton;
	UIActivityIndicatorView *_indicatorView;
	UIBarButtonItem         *_loadButton;
	UIBarButtonItem         *_actionButton;
}

@property (nonatomic, copy) NSString *URLString;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id) initWithURLString: (NSString *) URLString;

@end
