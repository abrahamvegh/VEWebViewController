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
}

- (id) initWithURLString: (NSString *) URLString;
- (id) initWithRequest: (NSURLRequest *)request;

@end
