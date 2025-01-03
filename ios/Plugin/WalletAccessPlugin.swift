// swift-tools-version:5.5

import Foundation
import Capacitor
import PassKit
import JavaScriptCore


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
            print("Wallet available")
            
            // Creates Reference to PassLibrary (User Wallet)
            let passLibrary = PKPassLibrary()
            
            let userPasses = passLibrary.passes()
            print("User Passes...")
            print(userPasses)
            
            // Creates an Array that can be converted into a JSON Object for return to JS/TS
            var passesInJSONEncodables: [[String: Any]] = []
            // iterates through all retrieved PKPasses
            for pass in userPasses{
                print(pass)
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
    
    // Creates an Apple Pass using Parameters
    @objc func generatePass(_ call: CAPPluginCall){
        // If Pass Library is Available
        if PKPassLibrary.isPassLibraryAvailable() {
            
            //----------------//
            // INPUT HANDLING //
            //----------------//
            
            // Values for PKPass Creation And Maintainance
            let passConfig = call.getObject("passConfig")
            print("PASS CONFIG")
            print(passConfig)
            let serialNumberInput = passConfig?["serialNumber"] as? String ?? "Invalid"
            let organizerNameInput = passConfig?["organizerName"] as? String ?? "Inavlid"
            let passCreationURL = passConfig?["passCreationURL"] as? String ?? "Invalid"
            let passAuthorizationKey = passConfig?["passAuthKey"] as? String ?? "Invalid"
            
            // Fields (optional)
            let passObject = call.getObject("passObject")
            
            // Header
            let headerLabelsInput = passObject?["headerLabels"] as? [String] ?? [String]()
            let headerValueInput = passObject?["headerValues"] as? [String] ?? [String]()
            
            // Primary
            let primaryLabelsInput = passObject?["primaryLabels"] as? [String] ?? [String]()
            let primaryValueInput = passObject?["primaryValues"] as? [String] ?? [String]()
            
            // Secondary
            let secondaryLabelsInput = passObject?["secondaryLabels"] as? [String] ?? [String]()
            let secondaryValueInput = passObject?["secondaryValues"] as? [String] ?? [String]()
            
            // Auxiliary
            let auxiliaryLabelsInput = passObject?["auxiliaryLabels"] as? [String] ?? [String]()
            let auxiliaryValueInput = passObject?["auxiliaryValues"] as? [String] ?? [String]()
            
            // Download Configuration
            let storageConfig = call.getObject("storageConfig")
            
            let miscData = call.getObject("miscData")
            
            
            // Checks Validity of Serial Number
            if (serialNumberInput == "Invalid"){
                call.reject("Passes need a valid passConfig Object. You appear to be missing a 'serialNumber' from your 'passConfig' parameter.")
            }
            
            // Checks Validity of Organizer Name
            if (organizerNameInput == "Invalid"){
                call.reject("Passes need a valid passConfig Object. You appear to be missing a 'organizerName' from your 'passConfig' parameter.")
            }
            
            // Checks Validity of Pass Type Input
            if (passCreationURL == "Invalid"){
                call.reject("Passes need a valid passConfig Object. You appear to be missing a 'passCreationUrl' from your 'passConfig' parameter.")
            }
            
            
            // Checks every Label has a corresponding Value and vice versa
            print("PASS OBJECT INPUT")
            print(headerLabelsInput , " " , headerValueInput)
            print(primaryLabelsInput , " " , primaryValueInput)
            print(secondaryLabelsInput , " " , secondaryValueInput)
            print(auxiliaryLabelsInput , " " , auxiliaryValueInput)
            if (
                headerLabelsInput.count != headerValueInput.count ||
                primaryLabelsInput.count != primaryValueInput.count ||
                secondaryLabelsInput.count != secondaryValueInput.count ||
                auxiliaryLabelsInput.count != auxiliaryValueInput.count
            ){
                call.reject("You have submitted an invalid passObject. Your passObject should have 'headerLabels', 'headerValues' \n 'primaryLabels', 'primaryValues' \n 'secondaryLabels', 'secondaryValues' \n 'auxiliaryLabels' and 'auxiliaryValues' \n properties. These properties should all be arrays conraining Strings, and each value/label pair must be of the same length. This means to say you cannot have 'headerLabels' contain 2 elements while 'headerValues' contains only 1")
            }
            
            print("Passed all param validations...")
            
            //-----------------------//
            // PASS CREATION PROCESS //
            //-----------------------//
            
            createPass(
                passCreationURL,
                serialNumberInput: serialNumberInput,
                organizerNameInput: organizerNameInput,
                passAuthorizationKey: passAuthorizationKey,
                
                headerLabelInput: headerLabelsInput,
                headerValueInput: headerValueInput,
                primaryLabelInput: primaryLabelsInput,
                primaryValueInput: primaryValueInput,
                secondaryLabelInput: secondaryLabelsInput,
                secondaryValueInput: secondaryValueInput,
                auxiliaryLabelInput: auxiliaryLabelsInput,
                auxiliaryValueInput: auxiliaryValueInput,
                
                miscData: miscData
            ){ result, error in
                if let error = error {
                    print("Error Creating the Pass!")
                    print(error)
                    call.reject("Error creating the pass")
                } else {
                    print("Pass Creation Completed!")
                    let addedPass = self.addToWallet(base64: result)
                    if (addedPass == "SUCCESS"){
                        call.resolve(["newPass": result])
                    }
                    else{
                        print("Pass created but Save to Wallet failed!!")
                        call.resolve(["newPass": result])
                    }
                    
                }
            }
        }
        
        // If PKPassLibrary is Unavailable
        else{
            print("No Access to Pass Library")
            call.reject("No Access to Pass Library")
        }
    }
    
    
    //----------------//
    // PASS FUNCTIONS //
    //----------------//
    
    // Generates the Pass
    func createPass(
        _ passCreationURL: String,
        serialNumberInput: String,
        organizerNameInput: String,
        passAuthorizationKey: String?,
        
        
        headerLabelInput: JSArray,
        headerValueInput: JSArray,
        primaryLabelInput: JSArray,
        primaryValueInput: JSArray,
        secondaryLabelInput: JSArray,
        secondaryValueInput: JSArray,
        auxiliaryLabelInput: JSArray,
        auxiliaryValueInput: JSArray,
        miscData: JSObject?,
        completion: @escaping (String, Error?) -> Void) {
            
            
            print("     Inside 'createPass' sub-function")
            let headers = populatePassBlock(labelArrayJS: headerLabelInput, valueArrayJS: headerValueInput, keyname: "header")
            let primary = populatePassBlock(labelArrayJS: primaryLabelInput, valueArrayJS: primaryValueInput, keyname: "primary")
            let secondary = populatePassBlock(labelArrayJS: secondaryLabelInput, valueArrayJS: secondaryValueInput, keyname: "secondary")
            let auxiliary = populatePassBlock(labelArrayJS: auxiliaryLabelInput, valueArrayJS: auxiliaryValueInput, keyname: "auxiliary")
            print(headers)
            print(primary)
            print(secondary)
            print(auxiliary)
            print(miscData)
            print(passAuthorizationKey)
            
            //---------//
            // REQUEST //
            //---------//
            
            var params: [String: Any] = [
                "organizerName": organizerNameInput,
                "serialNumber": serialNumberInput,
                "webServiceUrl": passCreationURL,
                "header": headers,
                "primary": primary,
                "secondary": secondary,
                "auxiliary": auxiliary,
                "miscData": miscData ?? ""
            ]
            
            if let authKey = passAuthorizationKey {
                params["authenticationToken"] = authKey
            }
            
            // Creates a bare request object
            // Specifies Request Method, values, and body content
            var request = URLRequest(url: URL(string: passCreationURL)!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            print("Sending Request to Server...")
            
            // Asynchronous code for making HTTP request
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    print("Error: \(error)")
                    completion("Error", error)
                } else if let data = data {
                    print("Raw Data")
                    print(data)
                    // Extract the String from response
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response String: \(responseString.prefix(3000))")
                        completion(responseString, nil)
                    } else {
                        print("Error converting data to string")
                        completion("Error", NSError(domain: "ConversionErrorDomain", code: 0, userInfo: ["message": "Please make sure the data being sent in the response is an encoded string"]))
                    }
                } else {
                    completion("Error", NSError(domain: "UnknownErrorDomain", code: 0, userInfo: ["message": "Please make sure the passCreationUrl has been supplied and is a valid endpoint."]))
                }
            }.resume()

        }
    
    
    // Adds Pass to device
    func addToWallet(base64: String) -> String {
        print("Base64 String: \(base64.prefix(100))")
        let data = base64
        print("Inside the addToWallet function... below is the data to be converted")
        print(data.prefix(100))
        validateBase64(base64String: data)

        guard let dataPass = Data(base64Encoded: data, options: .ignoreUnknownCharacters) else {
            print("Error decoding base64 data")
            let error = """
                {"code": 102,"message": "Error with base64 data"}
                """
            return error
        }

        print("Data Pass!")
        print(dataPass)

        do {
            // Creates a PKPass Object with the provided data
            let pass = try PKPass(data: dataPass)

            // If Valid New Pass
            do {
                try PKPassLibrary().addPasses([pass])
                
                // Perform UI-related operations on the main thread
                DispatchQueue.main.async {
                    if let vc = PKAddPassesViewController(pass: pass) {
                        vc.modalPresentationStyle = .formSheet
                        self.bridge?.viewController?.present(vc, animated: true, completion: nil)
                    }
                }
                
                return "SUCCESS"
            } 
            
            // Catches Invalid New Pass
            catch {
                print("Error adding pass to library: \(error)")
                let error = """
                    {"code": 103,"message": "Error adding pass to library"}
                    """
                return error
            }

        } 
        
        // Pass could NOT be created
        catch {
            print("Error creating PKPass object: \(error)")
            let error = """
                {"code": 101,"message": "\(error.localizedDescription)"}
                """
            return error
        }

        print("Invalid input somehow")
        return "INVALID INPUT"
    }

     

    
    //-----------------//
    // REQUEST HELPERS //
    //-----------------//
    func populatePassBlock(
        labelArrayJS: JSArray,
        valueArrayJS: JSArray,
        keyname: String
    ) -> [[String : String]]{
        var reqLabels = [String]()
        var reqValues = [String]()
        
        // Populates Labels
        labelArrayJS.enumerated().forEach{ (index, label) in
            if let swiftString = label as? String {
                reqLabels.append(swiftString)
            }
            else{
                reqLabels.append("Invalid")
            }
        }
        // Populates Values
        valueArrayJS.enumerated().forEach{ (index, value) in
            if let swiftString = value as? String {
                reqValues.append(swiftString)
            }
            else{
                reqValues.append("Invalid")
            }
        }
        
        // Creates the Headers Object for final params
        if (reqLabels.count == 2){
            return([
                [
                    "label": reqLabels[0],
                    "value": reqValues[0],
                    "key": (keyname + "0")
                ],
                [
                    "label": reqLabels[1],
                    "value": reqValues[1],
                    "key": (keyname + "1")
                ]
            ])
        }
        else if (!reqLabels.isEmpty){
            return([
                [
                    "label": reqLabels[0],
                    "value": reqValues[0],
                    "key": (keyname + "0")
                ]
            ])
        }
        else{
            return ([
                [
                "errer": "No response"
                ]
            ])
        }
    }
    

    func validateBase64(base64String: String){
        // Check length
        if base64String.count % 4 != 0 {
            print("Base64 string length is not a multiple of 4")
        }

        // Check characters
        let validBase64Characters = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=")
        if Set(base64String).isSubset(of: validBase64Characters) {
            print("Base64 string contains only valid characters")
        } else {
            print("Base64 string contains invalid characters")
        }
    }
}
