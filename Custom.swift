//
//  Custom.swift
//  CheckoutP
//
//  Created by Avinash Soni on 03/01/24.
//

import Foundation
class Custom {
    public func convertDictionaryToJson(dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                print("Error converting JSON data to string.")
                return nil
            }
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    func encodeStringToBase64(_ inputString: String) -> String? {
        if let inputData = inputString.data(using: .utf8) {
            return inputData.base64EncodedString()
        }
        return nil
    }
    
    func outputJSON(dictionary: [String: Any]) -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary as Any, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
//            print("customizationString: \(jsonString)")
            return jsonString
        } else {
            print("Error converting customization to JSON string.")
            return nil
        }
    }
}
