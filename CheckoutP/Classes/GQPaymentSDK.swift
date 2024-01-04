//
//  GQPaymentSDK.swift
//  CheckoutP
//
//  Created by Avinash Soni on 02/01/24.
//

import UIKit

public class GQPaymentSDK: UIViewController, WebDelegate {
    func sdSuccess(data: [String : Any]?) {
        print("sdSucess webview callback with data: \(String(describing: data))")
        delegate?.gqSuccessResponse(data: data)
        self.dismiss(animated: true, completion: nil)
    }
    
    func sdCancel(data: [String : Any]?) {
        print("sdCancel web callback received with data: \(String(describing: data))")
        delegate?.gqCancelResponse(data: data)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    public var delegate: GQPaymentDelegate?
    let customInstance = Custom()
    let environment = Environment.shared
    
    public var clientJSONObject: [String: Any]?
    private var mobileNumber: String?
    
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: clientJSONObject ?? ["errpr":"Invalid JSON Object"]) {
            print("JSON String: \(jsonString)")
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        // Accessing values
                        if let auth = json["auth"] as? [String: Any],
                           let clientId = auth["client_id"] as? String,
                           let clientSecret = auth["client_secret"] as? String,
                           let apiKey = auth["gq_api_key"] as? String {
                            print("Auth Object: \(auth)")
                            print("Auth Object111: \(customInstance.convertDictionaryToJson(dictionary: auth))")
                            print("Client ID: \(clientId)")
                            print("Client Secret: \(clientSecret)")
                            print("API Key: \(apiKey)")
                            environment.updateClientId(clientID: clientId)
                            environment.updateClientSecret(clientSecret: clientSecret)
                            environment.updateApiKey(apiKey: apiKey)
                            var abase = customInstance.encodeStringToBase64(environment.clientID+":"+environment.clientSecret)
                            
                            environment.updateAbase(abase: abase!)
                        } else {
                            print("No Auth Object available")
                        }
                        
                        if let studentID = json["student_id"] as? String {
                            print("Student ID: \(studentID)")
                            environment.updateStudentID(stdId: studentID)
                        }
                        
                        if let env = json["env"] as? String {
                            if containsAnyValidEnvironment(env){
                                environment.update(environment: env)
                                print("Environment: \(env)")
                            }else{
                                print("Invalid Environment: \(env)")
                            }
                        }else{
                            print("Environment Not Available ")
                        }
                        
                        if let customization = json["customization"] as? [String: Any],
                           let theme_color = customization["theme_color"] as? String {
                            print("themeColor: \(theme_color)")
                            environment.updateTheme(theme: theme_color)
                            print("customization: \(json["customization"] as? [String: Any])")
                            if let customizationData = try? JSONSerialization.data(withJSONObject: customization as Any, options: .prettyPrinted),
                               let customizationString = String(data: customizationData, encoding: .utf8) {
                                environment.updateCustomization(customization: customizationString)
                                print("customizationString: \(customizationString)")
                            } else {
                                print("Error converting customization to JSON string.")
                            }
                        }
                        
                        if var ppConfig = json["pp_config"] as? [String: Any]{
                            if let slug = ppConfig["slug"] as? String, !slug.isEmpty {
                                print("slug: \(slug)")
                                if let ppConfigData = try? JSONSerialization.data(withJSONObject: ppConfig as Any, options: .prettyPrinted),
                                   let ppConfigString = String(data: ppConfigData, encoding: .utf8) {
                                    print("ppConfigString: \(ppConfigString)")
                                    environment.updatePpConfig(ppConfig: ppConfigString)
                                } else {
                                    print("Invalid ppConfig JSON")
                                }
                            } else {
                                print("Slug Not available")
                            }
                        } else {
                            print("ppConfig Not avaibale")
                        }
                        
                        if var feeHeaders = json["fee_headers"] as? [String: Any]{
                            if let feeHeadersData = try? JSONSerialization.data(withJSONObject: feeHeaders as Any, options: .prettyPrinted),
                               let feeHeadersString = String(data: feeHeadersData, encoding: .utf8) {
                                print("feeHeadersString: \(feeHeadersString)")
                                environment.updateFeeHeaders(feeHeader: feeHeadersString)
                            } else {
                                print("Invalid Fee Headers JSON")
                            }
                        } else {
                            print("Fee Headers Not avaibale")
                        }
                        
                        if let customerNumber = json["customer_number"] as? String {
                            if validate(value: customerNumber){
                                print("Customer Number: \(customerNumber)")
                                environment.updateCustomerNumber(customerNumber: customerNumber)
                                mobileNumber = customerNumber
                                
                                DispatchQueue.main.async {
                                    self.customer()
                                }
                            }else{
                                print("Invalid Customer Number: \(customerNumber)")
                            }
                        }else{
                            environment.updateCustomerType(custType: "new")
                            print(getURL())
                            print("Customer Number Not Available ")
                        }
                    } else {
                        print("Failed to convert JSON data.")
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            } else {
                print("Failed to convert JSON string to data.")
            }
        } else {
            print("Conversion to JSON failed.")
        }
        
        let successData: [String: Any] = ["Status": "Success"]
        let failedData: [String: Any] = ["Status": "Failed"]
        let cancelData: [String: Any] = ["Status": "Cancel"]
        
        // Simulate a successful scenario
        delegate?.gqSuccessResponse(data: successData)
        
        // Simulate a failure scenario
        self.delegate?.gqFailureResponse(data: failedData)
        
        // Simulate a cancellation scenario
        self.delegate?.gqCancelResponse(data: cancelData)
    }
    
    func validate(value: String) -> Bool {
        let phoneRegex = #"^\d{10}$"#
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let result = phoneTest.evaluate(with: value)
        return result
    }
    
    func containsAnyValidEnvironment(_ value: String) -> Bool {
        let validEnvironments = ["test", "stage", "preprod", "live"]
        return validEnvironments.contains(value.lowercased())
    }
    
    public func customer() {
        guard mobileNumber != nil else {
            print("Mobile Number cannot be empty!")
            return
        }
        Customer().makeCustomerRequest(mobile: "\(mobileNumber!)") { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "Unknown error")
                self.delegate?.gqFailureResponse(data: ["error": true, "message": "You are unauthorized to access the SDK, please check your GQKey, and GQSecret"])
                return
            }
            
            DispatchQueue.main.async {
                let message = responseObject["message"] as! String
                
                if (message == "Customer Exists") {
                    print("existing")
                    self.environment.updateCustomerType(custType: "existing")
                }
                else {
                    print("new")
                    self.environment.updateCustomerType(custType: "new")
                }
                
                let data = responseObject["data"] as! [String:AnyObject]
                print("ResponseData: \(data)")
                self.environment.updateCustomerCode(custCode: data["customer_code"] as! String)
                self.environment.updateCustomerId(custId: data["customer_id"] as! Int)
                
                print(self.getURL())
                
                //                self.elegibity()
            }
        }
    }
    
    private func getURL(){
        
        var webloadUrl: String = ""
        
        let baseURL = self.environment.webLoadURL()
        
        webloadUrl = baseURL
        
        webloadUrl += "instant-eligibility?gapik=\(environment.gqApiKey)"
        
        webloadUrl += "&abase=\(environment.abase)"
        
        webloadUrl += "&sid=\(environment.studentID)"
        
        if !environment.customerNumber.isEmpty{
            webloadUrl += "&m=\(environment.customerNumber)"
        }
        
        webloadUrl += "&env=\(environment.env)"
        
        if environment.customerID != 0{
            webloadUrl += "&cid=\(environment.customerID)"
        }
        
        if !environment.customerCode.isEmpty {
            webloadUrl += "&ccode=\(environment.customerCode)"
        }
        
        if !environment.theme.isEmpty {
            webloadUrl += "&pc=\(environment.theme)"
        }
        
        webloadUrl += "&s=\(Environment.source)"
        webloadUrl += "&user=\(environment.customerType)"
        
        if !environment.customizationString.isEmpty{
            webloadUrl += ""
        }
        
        if !environment.ppConfigString.isEmpty {
            webloadUrl += "&_pp_config=\(environment.ppConfigString)"
        }
        
        if !environment.feeHeadersString.isEmpty {
            webloadUrl += "&_fee_headers=\(environment.feeHeadersString)"
        }
        
        webloadUrl += "&_v=\(Environment.version)"
        
        print("Complete WebUrl: \(webloadUrl)")
        
        let gqWebView = GQWebView()
        gqWebView.webDelegate = self
        gqWebView.loadURL = webloadUrl
        DispatchQueue.main.async {
            self.present(gqWebView, animated: true, completion: nil)
        }
        
    }
    
    public var onSuccess: (([String: Any]) -> Void)?
    public var onFailed: (([String: Any]) -> Void)?
    public var onCancel: (([String: Any]) -> Void)?
}
