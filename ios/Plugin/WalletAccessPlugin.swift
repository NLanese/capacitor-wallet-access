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

    @objc func getWallet(_ call: CAPPluginCall) {
        if PKPassLibrary.isPassLibraryAvailable() {
            let userPasses = PKPassLibrary.passes(<#T##self: PKPassLibrary##PKPassLibrary#>)
        }
        else{
            return
        }
        
        
        
        
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
}
