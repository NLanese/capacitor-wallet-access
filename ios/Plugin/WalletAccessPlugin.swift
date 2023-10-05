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
            let headerValueInput = call.getArray("headerValues") ?? [String]()
            let primaryValueInput = call.getArray("primaryValues") ?? [String]()
            let secondaryValueInput = call.getArray("secondaryValues") ?? [String]()
            let auxiliaryValueInput = call.getArray("auxiliaryValues") ?? [String]()
            let headerLabelInput = call.getArray("headerLabels") ?? [String]()
            let primaryLabelInput = call.getArray("primaryLabels") ?? [String]()
            let secondaryLabelInput = call.getArray("secondaryLabels") ?? [String]()
            let auxiliaryLabelInput = call.getArray("auxiliaryLabels") ?? [String]()
            
            // Needed Values for PKPass Creation
            let serialNumberInput = call.getString("serialNumber") ?? "Invalid"
            let organizerNameInput = call.getString("organizerName") ?? "Inavlid"
            let passCreationURL = call.getString("passCreationURL") ?? "Invalid"
            let passDownloadURL = call.getString("passDownloadURL") ?? "Invalid"
            let usesSerialNumberInDownloadURL = call.getBool("usesSerialNumberForDownload") ?? false
            
            
            
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
                headerLabelInput.count != headerValueInput.count ||
                primaryLabelInput.count != primaryValueInput.count ||
                secondaryLabelInput.count != secondaryValueInput.count ||
                auxiliaryLabelInput.count != auxiliaryValueInput.count
            ){
                call.reject("For every label, there must be a value! Check your LabelInput and ValueInput params!")
            }
            
            
            //-----------------------//
            // PASS CREATION PROCESS //
            //-----------------------//
            generatePass(
                passCreationURL,
                serialNumberInput: serialNumberInput,
                organizerNameInput: organizerNameInput,
                headerLabelInput: headerLabelInput,
                headerValueInput: headerValueInput,
                primaryLabelInput: primaryLabelInput,
                primaryValueInput: primaryValueInput,
                secondaryLabelInput: secondaryLabelInput,
                secondaryValueInput: secondaryValueInput,
                auxiliaryLabelInput: auxiliaryLabelInput,
                auxiliaryValueInput: auxiliaryValueInput,
                
                completion: <#T##(Bool) -> Void#>
            )
            
            // If Serial Number is Appended at the end of the File Name for Downloads
            if (usesSerialNumberInDownloadURL){
                downloadPass(
                    passDownloadURL,
                    usesSerialNumberInDownloadURL: true,
                    serialNumber: serialNumberInput
                    completion: <#T##(Bool) -> Void#>
                )
            }
            
            // If the Serial Number is NOT in the Download URL
            else{
                downloadPass(
                    passDownloadURL,
                    usesSerialNumberInDownloadURL: false,
                    serialNumber: nil
                    completion: <#T##(Bool) -> Void#>
                )
            }
            
            
            
            
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
func generatePass(
    _ passCreationURL: String,
    serialNumberInput: String,
    organizerNameInput: String,
    headerLabelInput: JSArray,
    headerValueInput: JSArray,
    primaryLabelInput: JSArray,
    primaryValueInput: JSArray,
    secondaryLabelInput: JSArray,
    secondaryValueInput: JSArray,
    auxiliaryLabelInput: JSArray,
    auxiliaryValueInput: JSArray,
    
    completion: @escaping((Bool) -> () )){
    
    //--------//
    // PARAMS //
    //--------//
        
        // Populates Params with Header Labels and Values
        var headerLabels = JSArray()
        var headerValues = JSArray()
        headerLabelInput.enumerated().forEach{ (index, label) in
            headerLabels[index] = label
        }
        headerValueInput.enumerated().forEach{ (index, value) in
            headerValues[index] = value
        }
        var headers = [[String: any JSValue]]()
        if (headerLabels.count == 2){
            headers = [
                [
                    "label": headerLabels[0],
                    "value": headerValues[0],
                    "key": "header0"
                ],
                [
                    "label": headerLabels[1],
                    "value": headerValues[1],
                    "key": "header1"
                ]
            ]
        }
        else{
            headers = [
                [
                    "label": headerLabels[0],
                    "value": headerValues[0],
                    "key": "header0"
                ]
            ]
        }
        
        // Populates Params with Primary Labels and Values
        var primaryLabels = JSArray()
        var primaryValues = JSArray()
        primaryLabelInput.enumerated().forEach{ (index, label) in
            primaryLabels[index] = label
        }
        primaryValueInput.enumerated().forEach{ (index, value) in
            primaryValues[index] = value
        }
        var primary = [[String: any JSValue]]()
        if (primaryLabels.count == 2){
            primary = [
                [
                    "label": primaryLabels[0],
                    "value": primaryValues[0],
                    "key": "primary0"
                ],
                [
                    "label": primaryLabels[1],
                    "value": primaryValues[1],
                    "key": "primary1"
                ]
            ]
        }
        else{
            primary = [
                [
                    "label": primaryLabels[0],
                    "value": primaryValues[0],
                    "key": "primary0"
                ]
            ]
        }
        
        // Populates Params with Secondary Labels and Values
        var secondaryLabels = JSArray()
        var secondaryValues = JSArray()
        secondaryLabelInput.enumerated().forEach{ (index, label) in
            secondaryLabels[index] = label
        }
        secondaryValueInput.enumerated().forEach{ (index, value) in
            secondaryValues[index] = value
        }
        var secondary = [[String: any JSValue]]()
        if (secondaryLabels.count == 2){
            secondary = [
                [
                    "label": secondaryLabels[0],
                    "value": secondaryValues[0],
                    "key": "secondary0"
                ],
                [
                    "label": secondaryLabels[1],
                    "value": secondaryValues[1],
                    "key": "secondary1"
                ]
            ]
        }
        else{
            secondary = [
                [
                    "label": secondaryLabels[0],
                    "value": secondaryValues[0],
                    "key": "secondary0"
                ]
            ]
        }
        
        // Populates Params with Axuiliary Labels and Values
        var auxiliaryLabels = JSArray()
        var auxiliaryValues = JSArray()
        auxiliaryLabelInput.enumerated().forEach{ (index, label) in
            auxiliaryLabels[index] = label
        }
        auxiliaryValueInput.enumerated().forEach{ (index, value) in
            auxiliaryValues[index] = value
        }
        var auxiliary = [[String: any JSValue]]()
        if (auxiliaryLabels.count == 2){
            auxiliary = [
                [
                    "label": auxiliaryLabels[0],
                    "value": auxiliaryValues[0],
                    "key": "auxiliary0"
                ],
                [
                    "label": auxiliaryLabels[1],
                    "value": auxiliaryValues[1],
                    "key": "auxiliary1"
                ]
            ]
        }
        else{
            auxiliary = [
                [
                    "label": auxiliaryLabels[0],
                    "value": auxiliaryValues[0],
                    "key": "auxiliary0"
                ]
            ]
        }
        
    
        
    //---------//
    // REQUEST //
    //---------//
    
        let params: [String: Any] = [
            "organizerName": organizerNameInput,
            "serialNumber": serialNumberInput,
            "header": headers,
            "primary": primary,
            "secondary": secondary,
            "auxiliary": auxiliary
        ]
        
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
func downloadPass(
    _ passDownloadURL: String,
    usesSerialNumber: Bool,
    serialNumber: String?
    completion: @escaping((Bool) -> () )
) {
    let pathToDownload = passDownloadURL
    if (usesSerialNumber){
        let splitURL = pathToDownload.split(separator: ".pkpass")
        pathToDownload = splitURL[0] + serialNumber + splitURL[1]
    }
    self.storageRef.child(pathToDownload).getData(maxSize: 1 * 1024 * 1024) { data, error in
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
