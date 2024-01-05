//
//  APIService.swift
//  CheckoutP
//
//  Created by Avinash Soni on 04/01/24.
//

import Foundation
class APIService {
    static let shared = APIService()
    
    let environment = Environment.shared
    let customInstance = Custom()
    
    func fetchData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Replace with your API endpoint URL
        let apiUrl = environment.baseURL() + Environment.customerAPI
        print("APIBaseURL: \(apiUrl)")
        
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        print("API-ClientID: \(environment.clientID)")
        print("API-ClientSecret: \(environment.clientSecret)")
        print("API-ApiKey: \(environment.gqApiKey)")
        print("API-Abase: \(environment.abase)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(environment.gqApiKey, forHTTPHeaderField: "GQ-API-Key")
        request.setValue(environment.abase, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add your request body if needed (replace "yourRequestBody" with the actual data)
        let requestBody: [String: Any] = [
            "customer_mobile": environment.customerNumber
        ]
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: requestBody) {
            print("API-Body: \(jsonString)")
        } else {
            print("Conversion to JSON failed.")
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(jsonObject))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
