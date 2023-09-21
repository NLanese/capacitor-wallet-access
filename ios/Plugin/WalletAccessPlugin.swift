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

    // Returns a JSON object for each Pass in the User's Wallet
    @objc func getWallet(_ call: CAPPluginCall) {
        // If Pass Library is Available
        if PKPassLibrary.isPassLibraryAvailable() {
        // Creates Reference to PassLibrary (User Wallet)
            let passLibrary = PKPassLibrary()
            let userPasses = passLibrary.passes()
            
            // Creates an Array that can be converted into a JSON Object for return to JS/TS
            var passesInJSONEncodables: [[String: Any]] = []
            // iterates through all retrieved PKPasses
            for pass in userPasses{
                // Fills in Basic Information
                var passJSON : [String: Any] = [
                    "organization": pass.organizationName,
                    "serialNumber": pass.serialNumber,
                ]
                
                // If inputs are provided, this will track other key/value pairs and return them
                let fieldKeys = call.getArray("value") ?? [];
                print(fieldKeys)
                if (!fieldKeys.isEmpty){
                    print("Cap Input Params...")
                    print(fieldKeys)

                    // Adds content from Primary, Secondary, and Auxiliary Fields
                    for field in fieldKeys{
                        if let strField = field as? String{
                            if let strKeyValue = pass.localizedValue(forFieldKey: strField) as? String{
                                passJSON[strField] = strKeyValue
                            }
                        }
                    }
                }
                
                // If no inputs or they're not found since Capacitor is fucking stupid sometimes
                else{
                    print("No input params found")
                }
                
                // Adds the Individual Pass Json Object to the Main Return Array
                passesInJSONEncodables.append(passJSON)
            }

            
            // There will be no `return` in a CAAPlugin, rather we utilize the call
            // and its unique methods
            print("Returning Passes as JSON")
            call.resolve(["cards": passesInJSONEncodables])
        }
        
        // If PKPassLibrary is Unavailable
        else{
            // There will be no `return` in a CAAPlugin, rather we utilize the call
            // and its unique methods
            print("No Access to Pass Library")
            call.reject("No Access to Pass Library")
        }
    }
    
    @objc func createNewPass(_ call: CAPPluginCall){
        // If Pass Library is Available
        if PKPassLibrary.isPassLibraryAvailable() {
            // Fields (optional)
            let headerFieldInput = call.getArray("headerFields") ?? []
            let primaryFieldInput = call.getArray("primaryFields") ?? []
            let secondaryFieldInput = call.getArray("secondaryFields") ?? []
            let auxiliaryFieldInput = call.getArray("auxiliaryFields") ?? []
            
            // Needed Values for PKPass Creation
            let serialNumberInput = call.getString("serialNumber") ?? "Invalid"
            let organizerNameInput = call.getString("organizerName") ?? "Inavlid"
            let passTypeInput = call.getString("passType") ?? "Invalid"
            
            // Checks Validity of Serial Number
            if (serialNumberInput == "Invalid"){
                call.reject("Please enter a valid serialNumber")
            }
            
            if (organizerNameInput == "Invalid"){
                call.reject("Please enter a valid organizerName")
            }
            
            // Checks Validity of Pass Type Input
            if (
                passTypeInput != "Generic" &&
                passTypeInput != "Coupon" &&
                passTypeInput != "Boarding pass" &&
                passTypeInput != "Store card" &&
                passTypeInput != "Event ticket"
            ){
                call.reject("passTypeInput needs to be one of the following values: 'Generic', 'Coupon', 'Boarding pass', 'Store card', and 'Event ticket")
            }
        }
        
        
        // If PKPassLibrary is Unavailable
        else{
            print("No Access to Pass Library")
            call.reject("No Access to Pass Library")
        }
    }
}
