# What is this?

`AVWebViewController` is a `UIViewController` subclass, for the iPhone, intended to be used inside a `UINavigationController`.

It provides a `UIWebView` and controls for navigating the web view. It also provides a (buggy) action menu that allows you to open the current URL in Mobile Safari, or email the currently visible URL.

`AV` stands for [Abraham Vegh](http://abrahamvegh.com/), the name of the guy who wrote this cheesy readme.

`AVWebViewController` is largely inspired by and intended to mimic the look and feel of the in-app web browser in the official Twitter iPhone app.

# What features does it have?

* Full navigation: Back, Forward, Stop, Reload
* Network status indicator in the status bar
* Loading indicator in the toolbar
* Landscape support
* Action menu displays the current URL (usually — it’s still a little buggy ;)
* Action menu items: Open in Safari, Mail Link

# How do I use it?

1. Include the contents of this repository in your Xcode project using your favorite method of moving stuff around. Drag-and-drop usually works.
2. Ensure your project is linking against the `MessageUI.framework`.
3. Import the header in the file you’d like to use it with: `#import "AVWebViewController.h"`
4. Create a new instance of `AVWebViewController` using the designated initializer, and (probably) push it onto your `UINavigationController` stack:

```
AVWebViewController *webViewController = [[AVWebViewController alloc] initWithURLString: @"http://abr.vg/"];

[self.navigationController pushViewController: webViewController animated: YES];
[webViewController release];
```

**You’re done! Happy surfing!**

# What license is this offered under?

`AVWebViewController` is licensed under the BSD license. Check the `LICENSE` file for the full text and terms.