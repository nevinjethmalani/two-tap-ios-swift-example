//
//  ViewController.swift
//  Two Tap iOS Swift Example
//
//  Created by Radu Spineanu on 9/15/15.
//  Copyright (c) 2015 amber.io, Inc. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

  @IBOutlet var tapMeButton : UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "checkout" {
      let viewController:BuyViewController = segue.destinationViewController as! BuyViewController
      viewController.productURL = "http://www.forever21.com/Product/Product.aspx?BR=f21&Category=sweater_sweatshirts-hoodies&ProductID=2000083990&VariantID=";
    }
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true;
  }
}

