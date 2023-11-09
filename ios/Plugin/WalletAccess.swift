import Foundation
import Capacitor
import PassKit
import JavaScriptCore

//import Amplify
//import FirebaseCore
//import FirebaseAuth

import Firebase
import FirebaseStorage



public class WalletAccess: NSObject {
    
    public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    public func getWallet(_ fields: Array<String>) -> [PKPass] {
        let passLibrary = PKPassLibrary()
        let userPasses = passLibrary.passes()
        print("====== INSIDE SWIFT ======")
        print("INPUTS:")
        print(userPasses)
        print("====== LOGGING USER PASSES NOW... ======")
        print(userPasses)
        return userPasses
    }
}
