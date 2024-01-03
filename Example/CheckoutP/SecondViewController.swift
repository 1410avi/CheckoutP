//
//  SecondViewController.swift
//  CheckoutP_Example
//
//  Created by Avinash Soni on 03/01/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class SecondViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func pushBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
