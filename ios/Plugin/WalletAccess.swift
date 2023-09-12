import Foundation
import Capacitor
import PassKit

public class WalletAccess: NSObject {
    
    public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    public func getWallet() -> [PKPass] {
        let passLibrary = PKPassLibrary()
        let userPasses = passLibrary.passes()
        print("====== INSIDE SWIFT ======")
        print("====== LOGGING USER PASSES NOW... ======")
        print(userPasses)
        return userPasses
    }
}
