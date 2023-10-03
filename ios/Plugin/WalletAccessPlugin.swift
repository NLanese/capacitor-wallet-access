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
    
    // Creates an Apple Pass using Parameters
    @objc func createNewPass(_ call: CAPPluginCall){
        
        // If Pass Library is Available
        if PKPassLibrary.isPassLibraryAvailable() {
            
            //----------------//
            // INPUT HANDLING //
            //----------------//
    
            // Fields (optional)
            let headerValueInput = call.getArray("headerValues") ?? []
            let primaryValueInput = call.getArray("primaryValues") ?? []
            let secondaryValueInput = call.getArray("secondaryValues") ?? []
            let auxiliaryValueInput = call.getArray("auxiliaryValues") ?? []
            let headerLabelInput = call.getArray("headerLabels") ?? []
            let primaryLabelInput = call.getArray("primaryLabels") ?? []
            let secondaryLabelInput = call.getArray("secondaryLabels") ?? []
            let auxiliaryLabelInput = call.getArray("auxiliaryLabels") ?? []
            
            // Needed Values for PKPass Creation
            let serialNumberInput = call.getString("serialNumber") ?? "Invalid"
            let organizerNameInput = call.getString("organizerName") ?? "Inavlid"
            let passCreationURL = call.getString("passCreationURL") ?? "Invalid"
            let passDownloadURL = call.getString("passDownloadURL") ?? "Invalid"
            
            
            
            // Checks Validity of Serial Number
            if (serialNumberInput == "Invalid"){
                call.reject("Please enter a valid serialNumber")
            }
            
            // Checks Validity of Organizer Name
            if (organizerNameInput == "Invalid"){
                call.reject("Please enter a valid organizerName")
            }
            
            // Checks Validity of Pass Type Input
            if (
                passCreationURL == "Invalid"
            ){
                call.reject("passURL needs to be supplied")
            }
            
            // Checks every Label has a corresponding Value and vice versa
            if (
                headerLabelInput.length !== headerValueInput.length ||
                primaryLabelInput.length !== primaryValueInput.length ||
                secondaryLabelInput.length !== secondaryValueInput.length ||
                auxiliaryLabelInput.length !== auxiliaryValueInput.length
            ){
                call.reject("For every label, there must be a value! Check your LabelInput and ValueInput params!")
            }
            
            
            //-----------------------//
            // PASS CREATION PROCESS //
            //-----------------------//
            generatePass(passCreationURL, completion: <#T##(Bool) -> Void#>)
            downloadPass(passDownloadURL, completion: <#T##(Bool) -> Void#>)
            
            
            
        }
        
        
        // If PKPassLibrary is Unavailable
        else{
            print("No Access to Pass Library")
            call.reject("No Access to Pass Library")
        }
    }
}


//----------------//
// PASS FUNCTIONS //
//----------------//

// Generates the Pass
func generatePass(_ passCreationURL: String, completion: @escaping((Bool) -> () )){
    
    //--------//
    // PARAMS //
    //--------//
    
    let params : [String: Any] = [
        "qrText": "This is a string that turns into a QR Code",
        "header": [
        ],
        "primary": [
        ],
        "secondary": [
        ],
        "auxiliary": [
        ],
        "serialNumber": serialNumberInput
    ]
    
    // Populates Params with Header Labels and Values
    headerLabelInput.forEach{ (label, index) in
        params["header"][index]["label"] = label
    }
    headerValueInput.forEach{ (value, index) in
        params["header"][index]["value"] = value
    }
    
    // Populates Params with Primary Labels and Values
    headerLabelInput.forEach{ (label, index) in
        params["primary"][index]["label"] = label
    }
    headerValueInput.forEach{ (value, index) in
        params["primary"][index]["value"] = value
    }
    
    // Populates Params with Secondary Labels and Values
    headerLabelInput.forEach{ (label, index) in
        params["secondary"][index]["label"] = label
    }
    headerValueInput.forEach{ (value, index) in
        params["secondary"][index]["value"] = value
    }
    
    // Populates Params with Auxiliary Labels and Values
    headerLabelInput.forEach{ (label, index) in
        params["auxiliary"][index]["label"] = label
    }
    headerValueInput.forEach{ (value, index) in
        params["auxiliary"][index]["value"] = value
    }
    
    //---------//
    // REQUEST //
    //---------//
    
    // Creates a bare request object
    var request = URLRequest(url: URL(string: passCreationURL)!)
    
    // Specifies Request Method
    request.httpMethod = "POST"
    
    // Specifies content in request will be sent via JSON
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Attemts to Serialize the input JSON object. Said JSON object will be the previous declared params object
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    
    
    // Deploys the request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
            completion(json["result"]! as! String == "SUCCESS" ? true : false)
        }
        catch {
            print("error")
            completion(false)
        }
    }
}

// Downloads the Pass from Firebase
func downloadPass(_ passDownloadURL: String, completion: @escaping((Bool) -> () )) {
    self.storageRef.child(passDownloadURL).getData(maxSize: 1 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error Downloading Local Resource:" + error.localizedDescription)
            completion(false)
        }
        else{
            do {
                let canAddPass = PKAddPassesViewController.canAddPasses()
                if (canAddPass){
                    print("Creating a Pass")
                    self.newPass = try PKPass.init(data: data!)
                    completion(true)
                }
                else{
                    print("Device Cannot Add Passes")
                }
            }
            catch{
                print ("Unknown Error")
                completion(false)
            }
        }
    }
}
