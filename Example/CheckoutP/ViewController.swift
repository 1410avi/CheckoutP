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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CheckoutP.init(pointlessParam: "dosen't Matter")
        let valid = CheckoutP.validateEmail(email: "abc.gmail.com")
        print("Valid Email: \(valid)")
    }
    @IBAction func openSDK(_ sender: Any) {
        
        let auth: [String: Any] = [
            "client_id": "GQ-0d2ed24e-cc1f-400b-a4e3-7208c88b99b5",
            "client_secret": "a96dd7ea-7d4a-4772-92c3-ac481713be4a",
            "gq_api_key": "b59bf799-2a82-4298-b901-09c512ea4aaa"
        ]
        
        let ppConfig: [String: Any] = [
            "slug": "masira-darvesh-gile",
            "card_code": "card_code"
        ]
        
        let feeHeaders: [String: Any] = [
            "Payable_fee_EMI": 12000,
            "Payable_fee_Auto_Debit": 10000,
            "Payable_fee_PG": 100
        ]
        
        let customization: [String: Any] = [
            "fee_helper_text": "fee_helper_text",
            "logo_url": "logo_url",
            "theme_color": "45AC45"
        ]
        
        let config: [String: Any] = [
            "auth": auth,
            "student_id": "demo_1022",
            "env": "test",
            "customer_number": "8425900022",
            "pp_config": ppConfig,
            "fee_headers": feeHeaders,
            "customization": customization
        ]
        
        let gqPaymentSDK = GQPaymentSDK()
        gqPaymentSDK.delegate = self
        gqPaymentSDK.clientJSONObject = config
        DispatchQueue.main.async {
//            self.navigationController?.pushViewController(self.gqPaymentSDK, animated: true)
//            self.present(self.gqPaymentSDK, animated: true, completion: nil)
            self.present(gqPaymentSDK, animated: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

