import Foundation
import Capacitor
import PassKit

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


    public func generatePass(
        passConfig: JSObject,
        passObject: JSObject,
        storageConfig: JSObject,
        miscData: JSObject? = nil
    )  {
        
    }
}


