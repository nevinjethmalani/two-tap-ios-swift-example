//
//  BuyViewController.swift
//  Two Tap iOS Swift Example
//
//  Created by Radu Spineanu on 9/15/15.
//  Copyright (c) 2015 amber.io, Inc. All rights reserved.
//

import Alamofire
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

    // Prepare the checkout.
    let parameters = [
      "checkout_request": [
        "public_token": "YOUR PUBLIC TOKEN",
        "unique_token": "YOUR UNIQUE TOKEN",
        "confirm": [
          "method": "sms",
          "sms_confirm_url": "http://YOUR_CONFIRM_URL"
        ],
        "products": [
          [
            "url": "http://www.nastygal.com/clothes-dresses/american-retro-mila-metallic-dress"
          ]
        ]
      ]
    ]
    

    Alamofire.request(.POST, "https://checkout.twotap.com/prepare_checkout", parameters: parameters, encoding: .JSON)
      .responseJSON { response in
        
        if let JSON = response.result.value {
          
          // Open the URL from the response.
          let ttPath = JSON["url"] as! String
          let ttURL = NSURL(string:ttPath)
          let ttRequest = NSURLRequest(URL:ttURL!)
          
          self.ttWebView.loadRequest(ttRequest)
          self.loadingIndicator.startAnimating()
        }
    }
  }


  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    self.checkPostMessages()
  }

  
  func checkPostMessages() {
    let messagesJSON = self.ttWebView.stringByEvaluatingJavaScriptFromString("postMessagesJSON()")
    let messagesJSONData = messagesJSON!.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)

    let messagesArray = JSON(data: messagesJSONData!)

    for (_, message): (String, JSON) in messagesArray {
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
      if reqURL.rangeOfString(URL) != nil {
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
