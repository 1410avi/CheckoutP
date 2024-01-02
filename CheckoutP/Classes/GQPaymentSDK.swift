//
//  GQPaymentSDK.swift
//  CheckoutP
//
//  Created by Avinash Soni on 02/01/24.
//

import UIKit
import WebKit
import CashfreePGCoreSDK
import CashfreePGUISDK
import CashfreePG
import Razorpay

public class GQPaymentSDK: UIViewController, WKUIDelegate {
    func sdSuccess(data: [String : Any]?) {
        print("sdSucess web callback with data: \(String(describing: data))")
        delegate?.gqSuccessResponse(data: data)
    }
    
    func sdCancel(data: [String : Any]?) {
        print("sdCancel web callback received with data: \(String(describing: data))")
    }
    
    public var delegate: GQPaymentDelegate?
    
    var webView: WKWebView!
    
    public override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.configuration.userContentController.add(self, name: "Gqsdk")
//        webView.configuration.userContentController.add(self, name: "sdkSuccess")
//        webView.configuration.userContentController.add(self, name: "sdkError")
//        webView.configuration.userContentController.add(self, name: "sdkCancel")
//        webView.configuration.userContentController.add(self, name: "sendADOptions")
//        webView.configuration.userContentController.add(self, name: "sendPGOptions")
        
        webView.uiDelegate = self
//        webView.navigationDelegate = self
        
           webView.uiDelegate = self
           view = webView
       }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Initiate SDK Success")
        
        let successData: [String: Any] = ["Status": "Success"]
        let failedData: [String: Any] = ["Status": "Failed"]
        let cancelData: [String: Any] = ["Status": "Cancel"]

        // Simulate a successful scenario
        delegate?.gqSuccessResponse(data: successData)

        // Simulate a failure scenario
        self.delegate?.gqFailureResponse(data: failedData)

        // Simulate a cancellation scenario
        self.delegate?.gqCancelResponse(data: cancelData)
        
        let con: [String: Any] = [
            "client_id": "itsclientid",
            "client_secret": "itsclientsecret"
        ]
        
        let myURL = URL(string:"https://erp-sdk.graydev.tech/instant-eligibility?gapik=b59bf799-2a82-4298-b901-09c512ea4aaa&abase=R1EtMGQyZWQyNGUtY2MxZi00MDBiLWE0ZTMtNzIwOGM4OGI5OWI1OmE5NmRkN2VhLTdkNGEtNDc3Mi05MmMzLWFjNDgxNzEzYmU0YQ==&sid=demo_12345&m=8625960119&env=test&cid=34863&ccode=0a6c1b84-0cd7-4844-8f77-cd1807520273&pc=&s=asdk&user=existing&_v=\"1.1\"")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
//        let gqWebView = GQWebView()
//        gqWebView.webDelegate = self
//        DispatchQueue.main.async {
//            self.present(gqWebView, animated: true, completion: nil)
//        }
    }
    
    public var onSuccess: (([String: Any]) -> Void)?
    public var onFailed: (([String: Any]) -> Void)?
    public var onCancel: (([String: Any]) -> Void)?
}

