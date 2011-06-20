# What is this?

`AVWebViewController` is a `UIViewController` subclass for the iPhone, designed to be used as the top view in a `UINavigationController`.

It presents a `UIWebView` and the controls a user expects to be available for navigating the web. It also provides an action menu that allows a user to open the current URL in Mobile Safari, or email the current URL.

# What user features does it have?

* **Full navigation**: Back, Forward, Stop, Reload
* Network status indicator in the status bar
* Loading indicator in the toolbar
* **Landscape support**
* Action menu displays the current URL
* Action menu items: Open in Safari, Mail Link
* Page title is shown in the navigation bar

# What geek features does it have?

* The class provides all of its UI in code, sans-nib. The images it requires are packaged up into a handy `.bundle` to minimize clutter.
* You can provide a URL using an initializer.
* Alternatively, you can navigate to a new URL at any time by just setting a property.
* The URL the user is browsing to emits KVO notifications when it changes.
* UI strings are wrapped in calls to the `NSLocalizedString()` macro, making localization simple.

# How do I use it?

1. Include the contents of this repository in your Xcode project using your favorite method of moving stuff around. (Drag-and-drop usually works.)
2. Ensure your project is linking against the `MessageUI` framework.
3. Import the header in the file you’d like to use it with: `#import "AVWebViewController.h"`
4. Create a new instance of `AVWebViewController`, and push it onto your navigation stack:

```
AVWebViewController *webViewController = [[AVWebViewController alloc] initWithURLString: @"http://www.apple.com/"];

[self.navigationController pushViewController: webViewController animated: YES];
[webViewController release];
```

**You’re done! Happy surfing!**

# What license is this offered under?

`AVWebViewController` is licensed under the BSD license. Check the [`LICENSE`](https://github.com/abrahamvegh/AVWebViewController/blob/master/LICENSE) file for the full text and terms.

# Credits

`AV` stands for [Abraham Vegh](http://abrahamvegh.com/), the name of the guy who wrote this cheesy readme. This project was created and is maintained by @abrahamvegh.

This project is largely inspired by and intended to mimic the look and feel of the in-app web browser in the official Twitter iPhone app, originally created by @atebits.

Many genius contributions have been made by @monoceroi. She is amazing.

@samvermette is a stand-up guy who has made helpful suggestions. You should check out his similar project, [`SVWebViewController`](https://github.com/samvermette/SVWebViewController).

# Screenshots

<a href="http://c.abr.vg/1s2y3S2Z2p2H2o3w0I0B"><img src="http://f.cl.ly/items/0l3R2G0b0H2Q3r152m2e/AVWebViewController-Portrait.png" width="92" height="179" /></a>
<a href="http://c.abr.vg/0P0P1k2y2M271O3G2A1U"><img src="http://f.cl.ly/items/121t0Z3X0R0f0Z3g2l0y/AVWebViewController-Landscape.png" width="179" height="92" /></a>
