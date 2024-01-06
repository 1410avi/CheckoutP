//
//  APIService.swift
//  CheckoutP
//
//  Created by Avinash Soni on 04/01/24.
//

import Foundation

enum YourCustomErrorType: Error {
//    case statusCode(String)
    case apiError(String)
//    case apiError(code: Int, message: String)
    case networkError(String)
    case parsingError(String)
}

class APIService{
    static func makeAPICall(completion: @escaping ([String: Any]?, String?) -> Void) {
        let environment = Environment.shared
        
        let url = URL(string:environment.baseURL()+Environment.customerAPI)!
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(environment.gqApiKey)", forHTTPHeaderField: "GQ-API-Key")
        request.setValue("Basic \(environment.abase)", forHTTPHeaderField: "Authorization")
        
//        
//        
//        
//        // Prepare body parameters
//        let bodyParameters: [String: Any] = ["customer_mobile": "8425900022"]
//        
//        do {
//            // Convert body parameters to JSON data
//            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
//        } catch {
//            print("Error encoding body parameters: \(error)")
//            return
//        }
        
        let parameters: [String: Any] = [
            "customer_mobile": "\(environment.customerNumber)",
        ]
        request.httpBody = parameters.percentEncoded()
        
        // Make API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Check for fundamental networking error
                guard error == nil else {
//                    completion(nil, YourCustomErrorType.networkError(error!.localizedDescription))
                    return
                }
                
                // Check for HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    print( "Unexpected response format")
//                    completion(nil, YourCustomErrorType.networkError("Unexpected response format"))
                    return
                }
                
                // Check for HTTP errors
                guard (200 ... 299) ~= httpResponse.statusCode else {
                    if let data = data {
                        do {
                            // Attempt to parse error response JSON
                            if let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let errorMessage = errorJSON["message"] as? String {
                                print("errorCode: \(httpResponse.statusCode)")
                                print("errorMessage: \(errorMessage)")
                                completion(nil, errorMessage)
                            } else {
                                print("Unable to parse error response as JSON")
//                                completion(nil, YourCustomErrorType.parsingError("Unable to parse error response as JSON"))
                            }
                        } catch {
                            print("Error parsing error JSON: \(error)")
//                            completion(nil, YourCustomErrorType.parsingError("Error parsing error JSON: \(error)"))
                        }
                    } else {
                        print("No data in the error response")
//                        completion(nil, YourCustomErrorType.networkError("No data in the error response"))
                    }
                    return
                }
                
                // Process the successful response
                guard let responseData = data else {
                    print("No data in the response")
//                    completion(nil, YourCustomErrorType.networkError("No data in the response"))
                    return
                }
                
                do {
                    let responseObject = try JSONSerialization.jsonObject(with: responseData) as? [String: Any]
                    completion(responseObject, nil)
                } catch {
                    print("Error parsing response JSON: \(error)")
//                    completion(nil, YourCustomErrorType.parsingError("Error parsing response JSON: \(error)"))
                }
            }
        
        
        task.resume()
    }
    
//    static func handleAPIResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ([String: Any]?, Error?) -> Void) {
//        // Check for fundamental networking error
//        guard error == nil else {
//            completion(nil, YourCustomErrorType.networkError(error!.localizedDescription))
//            return
//        }
//        
//        // Check for HTTP response
//        guard let httpResponse = response as? HTTPURLResponse else {
//            print( "Unexpected response format")
//            completion(nil, YourCustomErrorType.networkError("Unexpected response format"))
//            return
//        }
//        
//        // Check for HTTP errors
//        guard (200 ... 299) ~= httpResponse.statusCode else {
//            if let data = data {
//                do {
//                    // Attempt to parse error response JSON
//                    if let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let errorMessage = errorJSON["message"] as? String {
//                        print("errorCode: \(httpResponse.statusCode)")
//                        print("errorMessage: \(errorMessage)")
//                        completion(nil, YourCustomErrorType.apiError(code: httpResponse.statusCode, message: errorMessage))
//                    } else {
//                        print("Unable to parse error response as JSON")
//                        completion(nil, YourCustomErrorType.parsingError("Unable to parse error response as JSON"))
//                    }
//                } catch {
//                    print("Error parsing error JSON: \(error)")
//                    completion(nil, YourCustomErrorType.parsingError("Error parsing error JSON: \(error)"))
//                }
//            } else {
//                print("No data in the error response")
//                completion(nil, YourCustomErrorType.networkError("No data in the error response"))
//            }
//            return
//        }
//        
//        // Process the successful response
//        guard let responseData = data else {
//            print("No data in the response")
//            completion(nil, YourCustomErrorType.networkError("No data in the response"))
//            return
//        }
//        
//        do {
//            let responseObject = try JSONSerialization.jsonObject(with: responseData) as? [String: Any]
//            completion(responseObject, nil)
//        } catch {
//            print("Error parsing response JSON: \(error)")
//            completion(nil, YourCustomErrorType.parsingError("Error parsing response JSON: \(error)"))
//        }
//    }
    
}
