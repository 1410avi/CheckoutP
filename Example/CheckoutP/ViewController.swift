//
//  ViewController.swift
//  CheckoutP
//
//  Created by 1410avi on 01/02/2024.
//  Copyright (c) 2024 1410avi. All rights reserved.
//

import UIKit
import CheckoutP

class ViewController: UIViewController, GQPaymentDelegate {
    func gqSuccessResponse(data: [String : Any]?) {
        print("Success callback received with data: \(String(describing: data))")
    }
    
    func gqFailureResponse(data: [String : Any]?) {
        print("Failed callback received with error: \(String(describing: data))")
    }
    
    func gqCancelResponse(data: [String : Any]?) {
        print("Cancel callback received: \(String(describing: data))")
    }
    
    
    let gqPaymentSDK = GQPaymentSDK()

    override func viewDidLoad() {
        super.viewDidLoad()
        gqPaymentSDK.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        CheckoutP.init(pointlessParam: "dosen't Matter")
        let valid = CheckoutP.validateEmail(email: "abc.gmail.com")
        print("Valid Email: \(valid)")
    }
    @IBAction func openSDK(_ sender: Any) {
        DispatchQueue.main.async {
            self.present(self.gqPaymentSDK, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

