import Foundation
import Capacitor
import PassKit

///////////////////////
// Class Declaration //
///////////////////////

// Denotes that the WalletAccessPlugin in this swift file will be compatible with Objective-C
@objc(WalletAccessPlugin)

// Main Plugin Class : extends CAAPlugin (given by Capacitor)
public class WalletAccessPlugin: CAPPlugin {
    
    ////////////
    // Set Up //
    ////////////

    // Name of Plugin
    private let implementation = WalletAccess()

    ///////////////
    // Functions //
    ///////////////
    
    // Returns a JSON object for each Pass in the User's Wallet
    @objc func getWallet(_ call: CAPPluginCall) {
        
        let fieldKeys = call.getArray("fields") ?? []
        print("Cap Input Params...")
        print(fieldKeys)

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
                
                // Adds the Individual Pass Json Object to the Main Return Array
                passesInJSONEncodables.append(passJSON)
            }

            // There will be no `return` in a CAAPlugin, rather we utilize the call
            // and its unique methods
            call.resolve(["cards": passesInJSONEncodables])
        }
        else{
            // There will be no `return` in a CAAPlugin, rather we utilize the call
            // and its unique methods
            call.reject("No Access to Pass Library")
        }
    }
    
//   @objc func goToCard(_ call: CAPPluginCall){
//       let desiredPassOrganizer = call.getString("organizer") ?? "IEEE"
//       if PKPassLibrary.isPassLibraryAvailable() {
//           // Creates Reference to PassLibrary (User Wallet)
//           let passLibrary = PKPassLibrary()
//           let userPasses = passLibrary.passes()
//
//           // Empty Value to Popuate when the proper Pass is found
//           var desiredPass = nil
//
//           for pass in userPasses{
//               if (pass.organizationName === desiredPassOrganizer){
//                   desiredPass = pass
//               }
//           }
//           if (desiredPass){
//               open(pass.passURL)
//           }
//       }
//   }
}