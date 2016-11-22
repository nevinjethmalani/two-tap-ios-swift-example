//
//  BuyViewController.swift
//  Two Tap iOS Swift Example
//
//  Created by Radu Spineanu on 9/15/15.
//  Copyright (c) 2015 amber.io, Inc. All rights reserved.
//

import Alamofire
import UIKit
import SwiftyJSON

class BuyViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var ttWebView : UIWebView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var productURL : NSString?
    
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare the checkout.
        //Put in your own token info 
        let parameters = [
            "checkout_request": [
                "public_token": "YOUR PUBLIC TOKEN",
                "unique_token": "YOUR UNIQUE TOKEN",
                "close_button": ["show": "true"],
                "confirm": [
                    "method": "sms",
                    "skip_confirm": "http://YOUR_CONFIRM_URL",
                    "sms_finished_url": "http://www.shoplooq.com"
                ],
                "products": [
                    [
                        "url": "https://www.jcrew.com/mens_category/polostees/shortsleevepolos/PRDOVR~93952/93952.jsp",
                        ]
                ],
                //"custom_css_url": "",
                "top_banner": ["standard_message": "shipping and taxes will get re-calculated", "standard_url":"javascript:void(0)", "success_message":"Thanks for your purchase! Send any questions to support@shoplooq.com", "success_url":"javascript:void(0)"]
                //"input_fields": ["email":email, "shipping_first_name":firstName, "shipping_last_name":lastName, "shipping_address":address, "shipping_zip": zip, "shipping_city": city, "shipping_state": state, "shipping_telephone":phoneNumber]
                //"test_mode" : "fake_confirm"
            ]
        ]
        
        Alamofire.request("https://checkout.twotap.com/prepare_checkout", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let ttPath = json["url"].string
                let ttURL = NSURL(string:ttPath!)
                let ttRequest = NSURLRequest(url:ttURL! as URL)
                
                self.ttWebView.loadRequest(ttRequest as URLRequest)
                self.loadingIndicator.startAnimating()
            //print("JSON: \(json)")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkPostMessages()
    }
    
    
    func checkPostMessages() {
        let messagesJSON = self.ttWebView.stringByEvaluatingJavaScript(from: "postMessagesJSON()")
        let messagesJSONData = messagesJSON!.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        let messagesArray = JSON(data: messagesJSONData!)
        
        for (_, message): (String, JSON) in messagesArray {
            if message["action"] == "close_pressed" {
                self.closeModal()
            }
        }
        
        if (self.isViewLoaded && self.view.window != nil) {
            let delayInSeconds = 0.3
            let delay = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                self.checkPostMessages()
            })
        }
    }
    
    func closeModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let delayInSeconds = 2.0
        let delay = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay, execute: {
            self.loadingIndicator.stopAnimating()
        })
    }
    
    func webView(_ WebViewNews: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let localURLs = ["checkout.twotap.com", "localhost"]
        let reqURL = request.url!.absoluteString
        var openInSafari = true
        
        for URL:String in localURLs {
            if reqURL.range(of: URL) != nil {
                openInSafari = false
            }
        }
        
        if (openInSafari == true) {
            UIApplication.shared.openURL(request.url!)
            return false
        } else {
            return true
        }
    }
}
