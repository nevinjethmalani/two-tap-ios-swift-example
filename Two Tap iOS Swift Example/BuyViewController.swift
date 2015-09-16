//
//  BuyViewController.swift
//  Two Tap iOS Swift Example
//
//  Created by Radu Spineanu on 9/15/15.
//  Copyright (c) 2015 amber.io, Inc. All rights reserved.
//

import UIKit

class BuyViewController: UIViewController, UIWebViewDelegate {

  @IBOutlet var ttWebView : UIWebView!
  @IBOutlet var loadingIndicator: UIActivityIndicatorView!
  
  var productURL : NSString?

  override func prefersStatusBarHidden() -> Bool {
    return true;
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let encodedProductURL = self.productURL!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())

    let customCSSURL = "http://localhost:2500/stylesheets/integration_twotap_ios.css"
    let ttPath = "http://localhost:2500/integration_iframe?custom_css_url=\(customCSSURL)&product=\(encodedProductURL!)"
    
    let ttURL = NSURL(string:ttPath)
    let ttRequest = NSURLRequest(URL:ttURL!)
    
    self.ttWebView.loadRequest(ttRequest)
    self.loadingIndicator.startAnimating()
  }


  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    self.checkPostMessages()
  }

  
  func checkPostMessages() {
    var error: NSError?
    let messagesJSON = self.ttWebView.stringByEvaluatingJavaScriptFromString("postMessagesJSON()")
    let messagesJSONData = messagesJSON!.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)

    let messagesArray = JSON(data: messagesJSONData!)

    for (index: String, message: JSON) in messagesArray {
      if message["action"] == "close_pressed" {
        self.closeModal()
      }
    }
    
    if (self.isViewLoaded() && self.view.window != nil) {
      let delayInSeconds = 0.3
      let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
      dispatch_after(delay, dispatch_get_main_queue(), {
        self.checkPostMessages()
      })
    }
  }
  
  func closeModal() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    let delayInSeconds = 2.0
    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
    dispatch_after(delay, dispatch_get_main_queue(), {
      self.loadingIndicator.stopAnimating()
    })
  }
  
  func webView(WebViewNews: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    
    let localURLs = ["checkout.twotap.com", "localhost"]
    let reqURL = request.URL!.absoluteString
    var openInSafari = true
    
    for URL:String in localURLs {
      if reqURL!.rangeOfString(URL) != nil {
        openInSafari = false
      }
    }
    
    if (openInSafari == true) {
      UIApplication.sharedApplication().openURL(request.URL!)
      return false
    } else {
      return true
    }
  }
}
