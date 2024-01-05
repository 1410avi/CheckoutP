//
//  WebDelegate.swift
//  CheckoutP
//
//  Created by Avinash Soni on 02/01/24.
//

import Foundation
protocol WebDelegate{
    func sdSuccess(data: [String: Any]?)
    func sdCancel(data: [String: Any]?)
}
