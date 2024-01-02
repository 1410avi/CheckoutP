

import Foundation

public class CheckoutP {
    
    var pointlessProperty: Any
    
    public init(pointlessParam: Any) {
            self.pointlessProperty = pointlessParam
        }
    
    public func temp() {
            print("this prints to the console so we can see if this is working!")
        }
    
    public static func validateEmail(email: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
