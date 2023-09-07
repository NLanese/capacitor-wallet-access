import Foundation
import Capacitor
import PassKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

// Denotes that the WalletAccessPlugin in this swift file will be compatible with Objective-C
@objc(WalletAccessPlugin)

// Main Plugin Class : extends CAAPlugin (given by Capacitor)
public class WalletAccessPlugin: CAPPlugin {
    // Name of Plugin
    private let implementation = WalletAccess()
    
    // Creates Reference to PassLibrary (User Wallet)
    let passLibrary = PKPassLibrary()

    // This Obejctive-C Wrapped Function is still in Swift. It, however,
    // is doing a lot of work behind the scenes to get this ready to be converted
    // to JavaScript on the FrontEnd. This is why the only param ALWAYS has to be
    // a CAAPLugin call, otherwise this will not work with Capactitor.
    // However, we can still add our own custom parameters and accesses them
    // as shown below....
    @objc func getWallet(_ call: CAPPluginCall) {
        
        // Had we uncommented this line below, inputValues would equal whatever value was
        // input for the exampleParamName value
        // let inputValues = call.getString("exampleParamName")
        
        if PKPassLibrary.isPassLibraryAvailable() {
            let userPasses = PKPassLibrary.passes()
        }
        else{
            // There will be no `return` in a CAAPlugin, rather we utilize the call
            // and its unique methods
            call.reject("No Access to Pass Library")
        }
    }
}
