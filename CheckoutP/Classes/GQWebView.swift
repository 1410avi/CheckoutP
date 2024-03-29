//
//  GQWebView.swift
//  CheckoutP
//
//  Created by Avinash Soni on 02/01/24.
//

import Foundation
import UIKit
import WebKit
import CashfreePGCoreSDK
import CashfreePGUISDK
import CashfreePG
import Razorpay

class GQWebView: UIViewController, CFResponseDelegate, RazorpayPaymentCompletionProtocolWithData, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    
    var paymentSessionId: String?
    var orderId: String?
    var rOrderId: String?
    var recurring: Bool?
    var notes: [String:Any]?
    var customer_id: String?
    var callBackUrl: String?
    let customInstance = Custom()
    var vName: String?
    var loadURL: String?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received message from web -> \(message.body)")
        if (message.name == "sdkSuccess") {
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as! [String: Any]
                print("sdkSuccess: \(con)")
                print("sdkSuccessdata: \(data)")
                webDelegate?.sdSuccess(data: con)
                //                delegate?.gqSuccessResponse(data: con)
            } catch {
                print(error)
                //                delegate?.gqErrorResponse(error: true, message: error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
            }
        }else if (message.name == "sdkCancel") {
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [String: Any]
                print("sdkCancel: \(con)")
                webDelegate?.sdCancel(data: con)
                self.dismiss(animated: true, completion: nil)
            } catch {
                print(error)
                //                delegate?.gqErrorResponse(error: true, message: error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
            }
            //            self.dismiss(animated: true, completion: nil)
        }else if (message.name == "sendPGOptions") {
            let data = message.body as! String
            
            if let jsonData = data.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let name = json["name"] as? String{
                    
                        vName = name
                        print("Name: \(vName)")
                        
                        if name == "CASHFREE"{
                            if let pgOptions = json["pgOptions"] as? [String: Any],
                               let orderCode1 = pgOptions["order_code"] as? String,
                               let mdMappingCode = pgOptions["md_mapping_code"] as? String,
                               let paymentSessionId1 = pgOptions["payment_session_id"] as? String {
                                
                                paymentSessionId = paymentSessionId1
                                orderId = orderCode1
                                
                                // Use the extracted values
                                print("Name: \(name)")
                                print("Order Code: \(orderCode1)")
                                print("MD Mapping Code: \(mdMappingCode)")
                                print("Payment Session ID: \(paymentSessionId1)")
                                
                                DispatchQueue.main.async {
                                    self.openPG(paymentSessionId: paymentSessionId1, orderId: orderCode1)
                                }
                            }
                            
                        } else if let pgOptions = json["pgOptions"] as? [String: Any],
                                  let key = pgOptions["key"] as? String,
                                  let order_id = pgOptions["order_id"] as? String,
                                  var redirect = pgOptions["redirect"] as? Bool,
                                  let prefillObj = pgOptions["prefill"] as? [String: Any],
                                  let notes = pgOptions["notes"] as? [String: Any]
                        {
                            let name = prefillObj["name"] as? String
                            let email = prefillObj["email"] as? String
                            let contact = prefillObj["contact"] as? String
                            
                            print("key: \(key)")
                            
                            razorpay = RazorpayCheckout.initWithKey(key, andDelegateWithData: self)
                            
                            let options: [String:Any] = [
                                "order_id": order_id,
                                "recurring": 0,
                                "redirect": redirect,
                                "notes": notes,
                                "prefill": [
                                    "contact": contact,
                                    "email": email
                                ]
                            ]
                            DispatchQueue.main.async {
                                self.razorpay!.open(options, displayController: self)
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }else if (message.name == "sendADOptions") {
            
            let data = message.body as! String
            
            if let jsonData = data.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let key = json["key"] as? String,
                       let customer_id = json["customer_id"] as? String,
                       let order_id = json["order_id"] as? String,
                       let recurring = json["recurring"] as? String,
                       let redirect = json["redirect"] as? Bool,
                       let callback_url = json["callback_url"] as? String,
                       let notes = json["notes"] as? [String: Any]{
                        print("AdKey: \(key)")
                        callBackUrl = callback_url
                        
                        razorpay = RazorpayCheckout.initWithKey(key, andDelegateWithData: self)
                        
                        var recuring_flag: Bool = false
                        
                        if recurring == "1"{
                            recuring_flag = true
                        }
                        let options: [String:Any] = [
                            "customer_id": customer_id,
                            "order_id": order_id,
                            "recurring": recuring_flag,
                            "redirect": redirect,
                            "notes": notes,
                        ]
                        DispatchQueue.main.async {
                            self.razorpay!.open(options, displayController: self)
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            //            checkout_details = CheckoutDetails(order_id: order_id as? String ?? "", razorpay_key: (razorpay_key as! String), recurring: recurring_flag ?? true, notes: (notes as? [String : Any] ?? ["nil": "nil"]), customer_id: (customer_id as! String), callback_url: (callback_url as! String))
            //
            //            let newViewController = CheckoutViewController()
            //            newViewController.checkout_details = checkout_details
            //            newViewController.delegate = self
            //            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
                //               delegate?.gqErrorResponse(error: true, message: error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
            }
        }
        return nil
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.showPaymentForm()
    }
    
    //    internal func showPaymentForm(){
    //        let options: [String:Any] = [
    //            //            "amount": "100", //This is in currency subunits. 100 = 100 paise= INR 1.
    //            //            "currency": "INR",//We support more that 92 international currencies.
    //            //            "description": "purchase description",
    //            "order_id": rOrderId,
    //            "recurring": recurring,
    //            //            "image": "https://url-to-image.jpg",
    //            //            "name": "business or product name",
    //            "notes": notes,
    //            "customer_id": customer_id
    //            //            "prefill": [
    //            //                "contact": "9797979797",
    //            //                "email": "foo@bar.com"
    //            //            ],
    //            //            "theme": [
    //            //                "color": "#F37254"
    //            //            ]
    //        ]
    //        DispatchQueue.main.async {
    //            //            self.razorpay!.open(options, displayController: self)
    //        }
    //    }
    
    public var delegate: GQPaymentDelegate?
    var webDelegate: WebDelegate?
    var webView: WKWebView!
    let pgService = CFPaymentGatewayService.getInstance()
    var razorpay: RazorpayCheckout!
    
    public override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.configuration.userContentController.add(self, name: "Gqsdk")
        webView.configuration.userContentController.add(self, name: "sdkSuccess")
        webView.configuration.userContentController.add(self, name: "sdkError")
        webView.configuration.userContentController.add(self, name: "sdkCancel")
        webView.configuration.userContentController.add(self, name: "sendADOptions")
        webView.configuration.userContentController.add(self, name: "sendPGOptions")
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.uiDelegate = self
        view = webView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        pgService.setCallback(self)
        
        let environment = Environment.shared
        print("Global Env: \(environment.env)")
        //
        //        let myURL = URL(string:"https://erp-sdk.graydev.tech/instant-eligibility?gapik=b59bf799-2a82-4298-b901-09c512ea4aaa&abase=R1EtMGQyZWQyNGUtY2MxZi00MDBiLWE0ZTMtNzIwOGM4OGI5OWI1OmE5NmRkN2VhLTdkNGEtNDc3Mi05MmMzLWFjNDgxNzEzYmU0YQ==&sid=demo_12345&m=8625960119&env=test&cid=34863&ccode=0a6c1b84-0cd7-4844-8f77-cd1807520273&pc=&s=asdk&user=existing&_v=\"1.1\"")
        let myURL = URL(string:loadURL ?? "https://grayquest.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    //    private func getSession() -> CFSession? {
    //            do {
    //                let session = try CFSession.CFSessionBuilder()
    //                    .setEnvironment(.SANDBOX)
    //                    .setPaymentSessionId(paymentSessionId)
    //                    .setOrderID(orderId)
    //                    .build()
    //                return session
    //            } catch let e {
    //                let error = e as! CashfreeError
    //                print(error.localizedDescription)
    //                // Handle errors here
    //            }
    //            return nil
    //        }
    
    func openPG(paymentSessionId: String, orderId: String) {
        
        do {
            let session = try CFSession.CFSessionBuilder()
                .setPaymentSessionId(paymentSessionId)
                .setOrderID(orderId)
                .setEnvironment(.SANDBOX)
                .build()
            
            // Set Components
            let paymentComponents = try CFPaymentComponent.CFPaymentComponentBuilder()
                .enableComponents([
                    "order-details",
                    "card",
                    "paylater",
                    "wallet",
                    "emi",
                    "netbanking",
                    "upi"
                ])
                .build()
            
            // Set Theme
            let theme = try CFTheme.CFThemeBuilder()
            
                .setNavigationBarBackgroundColor("#4563cb")
                .setNavigationBarTextColor("#FFFFFF")
                .setButtonBackgroundColor("#4563cb")
                .setButtonTextColor("#FFFFFF")
                .setPrimaryTextColor("#000000")
                .setSecondaryTextColor("#000000")
            //                .setPrimaryFont("Source Sans Pro")
            //                .setSecondaryFont("Gill Sans")
            //                .setButtonTextColor("#FFFFFF")
            //                .setButtonBackgroundColor("#FF0000")
            //                .setNavigationBarTextColor("#FFFFFF")
            //                .setNavigationBarBackgroundColor("#FF0000")
            //                .setPrimaryTextColor("#FF0000")
            //                .setSecondaryTextColor("#FF0000")
                .build()
            
            let webCheckoutPayment = try CFDropCheckoutPayment.CFDropCheckoutPaymentBuilder()
                .setSession(session).setComponent(paymentComponents).setTheme(theme)
                .build()
            try pgService.doPayment(webCheckoutPayment, viewController: self)
        } catch let e {
            let err = e as! CashfreeError
            print(err.description)
        }
        
        
        //        do {
        //            let session = try CFSession.CFSessionBuilder()
        //                .setEnvironment(.SANDBOX)
        //                .setPaymentSessionId(paymentSessionId)
        //                .setOrderID(orderId)
        //                .build()
        //
        //            let webCheckoutPayment = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
        //                .setSession(session)
        //                .build()
        //
        //            try self.cfPaymentGatewayService.doPayment(webCheckoutPayment, viewController: self)
        //
        //        } catch let e {
        //            let error = e as! CashfreeError
        //            print(error.localizedDescription)
        //            // Handle errors here
        //        }
        
        //        if let session = self.getSession() {
        //            do {
        //
        //                // Set Components
        //                let paymentComponents = try CFPaymentComponent.CFPaymentComponentBuilder()
        //                    .enableComponents([
        //                        "order-details",
        //                        "card",
        //                        "paylater",
        //                        "wallet",
        //                        "emi",
        //                        "netbanking",
        //                        "upi"
        //                    ])
        //                    .build()
        //
        ////                // Set Theme
        //                let theme = try CFTheme.CFThemeBuilder()
        //                    .setPrimaryFont("Source Sans Pro")
        //                    .setSecondaryFont("Gill Sans")
        //                    .setButtonTextColor("#FFFFFF")
        //                    .setButtonBackgroundColor("#FF0000")
        //                    .setNavigationBarTextColor("#FFFFFF")
        //                    .setNavigationBarBackgroundColor("#FF0000")
        //                    .setPrimaryTextColor("#FF0000")
        //                    .setSecondaryTextColor("#FF0000")
        //                    .build()
        //
        //                // Native payment
        //                let webCheckoutPayment = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
        //                    .setSession(session)
        //                    .build()
        //
        //                // Invoke SDK
        //                try self.cfPaymentGatewayService.doPayment(webCheckoutPayment, viewController: self)
        //
        //
        //            } catch let e {
        //                let error = e as! CashfreeError
        //                print(error.localizedDescription)
        //                // Handle errors here
        //            }
        //        }
    }
    
    public func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        var userInfo = response as NSDictionary? as? [String: Any]
        if ((callBackUrl?.isEmpty) != nil){
            userInfo?["callback_url"] = callBackUrl
        }
        print("ErrorCode: \(code)")
        print("ErrorDescription: \(str)")
        print("ErrorResponse: \(String(describing: userInfo))")
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: userInfo!) {
            print("JSON String: \(jsonString)")
            if ((vName=="UNIPG") != nil) {
                print("VName: \(String(describing: vName))")
                webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            }else {
                print("VNameCash; \(String(describing: vName))")
                webView.evaluateJavaScript("javascript:sendADPaymentResponse(\(jsonString));")
            }
            
        } else {
            print("Conversion to JSON failed.")
        }
    }
    
    public func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        var userInfo = response as NSDictionary? as? [String: Any]
        if ((callBackUrl?.isEmpty) != nil){
            userInfo?["callback_url"] = callBackUrl
        }
        print("success: ", response)
        let paymentId = response?["razorpay_payment_id"] as! String
        let rezorSignature = response?["razorpay_signature"] as! String
        print("SuccessPaymentID: \(payment_id)")
        print("SuccessResponse: \(userInfo)")
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: userInfo!) {
            print("JSON String: \(jsonString)")
            if ((vName=="UNIPG") != nil) {
                print("VName: \(String(describing: vName))")
                webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            }else {
                print("VNameCash; \(String(describing: vName))")
                webView.evaluateJavaScript("javascript:sendADPaymentResponse(\(jsonString));")
            }
            
        } else {
            print("Conversion to JSON failed.")
        }
    }
    
    public func onError(_ error: CashfreePGCoreSDK.CFErrorResponse, order_id: String) {
        print("ErrorResponse: ")
        print(order_id)
        print(error.status)
        print(error.message)
        let paymentResponse: [String: Any] = [
            "status": error.status,
            "order_code": order_id,
            "message": error.message,
            "code": error.code,
            "type": error.type
        ]
        print("SuccessResponse: ")
        print(order_id)
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
            print("JSON String: \(jsonString)")
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
//            webDelegate?.sdSuccess(data: paymentResponse)
//            self.dismiss(animated: true, completion: nil)
        } else {
            print("Conversion to JSON failed.")
        }
    }
    
    public func verifyPayment(order_id: String) {
        let paymentResponse: [String: Any] = [
            "status": "SUCCESS",
            "order_code": order_id
        ]
        print("SuccessResponse: ")
        print(order_id)
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
            print("JSON String: \(jsonString)")
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
//            webDelegate?.sdSuccess(data: paymentResponse)
//            self.dismiss(animated: true, completion: nil)
        } else {
            print("Conversion to JSON failed.")
        }
    }
}
