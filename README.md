# What is this?

`AVWebViewController` is a `UIViewController` subclass for the iPhone, designed to be used as the top view in a `UINavigationController`.

It presents a `UIWebView` and the controls a user would expect to be available for navigating the web. An action menu is also provided, which enables a user to open the current URL in Mobile Safari, or email the current URL.

# What user features does it have?

* **Full navigation**: Back, Forward, Stop, Reload
* Network status indicator in the status bar
* Loading indicator in the toolbar
* **Landscape support**
* Action menu displays the current URL
* Action menu items: Open in Safari, Mail Link
* Page title is shown in the navigation bar

# What programmer features does it have?

* The class provides all of its UI in code, sans-nib. The images it requires are packaged up into a handy `.bundle` to minimize clutter.
* You can provide a starting URL using an initializer.

# How do I use it?

1. Include the contents of this repository in your Xcode project using your favorite method of moving stuff around. (Drag-and-drop usually works.)
1. Ensure your project is linking against the `MessageUI` framework.
1. Import the header in the file you’d like to use it with: `#import "AVWebViewController.h"`  
(Alternatively, if you want to use the view controller in a number of places, add the `#import` statement to your `.pch` file.)
1. Create a new instance of `AVWebViewController`, and push it onto your navigation stack:  
  
```
AVWebViewController *webViewController = [[AVWebViewController alloc] initWithURLString: @"http://www.google.com/"];

[self.navigationController pushViewController: webViewController animated: YES];
[webViewController release];
```

**That’s all there is to it.**

# What license is this offered under?

`AVWebViewController` is licensed under the BSD license. Check the [`LICENSE`](https://github.com/abrahamvegh/AVWebViewController/blob/master/LICENSE) file for the full text and terms.

# Credits

`AV` stands for [Abraham Vegh](http://abrahamvegh.com/), the name of the guy who wrote this cheesy readme. This project was created and is maintained by @[abrahamvegh](https://github.com/abrahamvegh).

This project is largely inspired by and intended to mimic the look and feel of the in-app web browser in Tweetie 2. We’ll miss you, Tweetie.

Many genius contributions have been made by @[monoceroi](https://github.com/monoceroi). She is amazing.

@[samvermette](https://github.com/samvermette) is a stand-up guy who has made helpful suggestions. You should check out his similar project, [`SVWebViewController`](https://github.com/samvermette/SVWebViewController).

# Screenshots

<a href="http://c.abr.vg/1s2y3S2Z2p2H2o3w0I0B"><img src="http://f.cl.ly/items/0l3R2G0b0H2Q3r152m2e/AVWebViewController-Portrait.png" width="92" height="179" /></a>
<a href="http://c.abr.vg/0P0P1k2y2M271O3G2A1U"><img src="http://f.cl.ly/items/121t0Z3X0R0f0Z3g2l0y/AVWebViewController-Landscape.png" width="179" height="92" /></a>
