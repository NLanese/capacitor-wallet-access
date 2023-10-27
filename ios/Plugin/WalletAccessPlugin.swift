import Foundation
import Capacitor
import PassKit
import JavaScriptCore
//import Amplify
//import FirebaseCore
//import FirebaseFirestore
import Firebase
import FirebaseStorage

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
    @objc func generatePass(_ call: CAPPluginCall){
        
        
        // Logs to denote the plugin function has successfully fired
        print("=======================")
        print("*")
        print("*")
        print("*")
        print("INSIDE CAPACITOR PLUGIN")
        print("*")
        print("*")
        print("*")
        print("=======================")
        
        // If Pass Library is Available
        if PKPassLibrary.isPassLibraryAvailable() {
            
            //----------------//
            // INPUT HANDLING //
            //----------------//
            
            // Needed Values for PKPass Creation
            // Recall that the ONLY param for a Capacitor plugin is `call`. The Params of this call function are declared in the plugin's definitions.ts and index.ts
            let serialNumberInput = call.getString("serialNumberInput") ?? "Invalid"
            let organizerNameInput = call.getString("organizerNameInput") ?? "Inavlid"
            
            let passCreationURL = call.getString("passCreationURL") ?? "Invalid"
            let passDownloadURL = call.getString("passDownloadURL") ?? "Invalid"
            let passAuthorizationKey = call.getString("passAuthorizationKey") ?? "Invalid"
            let webStorageInput = call.getString("webStorageInput") ?? "Invalid"
            let usesSerialNumberInDownloadURL = call.getBool("usesSerialNumberinDownload") ?? false
    
            // Fields (optional)
            // Since they are optional, you must declare an alternative of the same time. Thus we create an empty String Array if nothing is there
            let headerValueInput = call.getArray("headerValues") ?? [String]()
            let primaryValueInput = call.getArray("primaryValues") ?? [String]()
            let secondaryValueInput = call.getArray("secondaryValues") ?? [String]()
            let auxiliaryValueInput = call.getArray("auxiliaryValues") ?? [String]()
            let headerLabelInput = call.getArray("headerLabels") ?? [String]()
            let primaryLabelInput = call.getArray("primaryLabels") ?? [String]()
            let secondaryLabelInput = call.getArray("secondaryLabels") ?? [String]()
            let auxiliaryLabelInput = call.getArray("auxiliaryLabels") ?? [String]()
            
            
            // Firebase Related Fields
            let firebaseStorageUrl = call.getString("firebaseStorageUrl") ?? nil
            let googleAppID = call.getString("googleAppID") ?? nil
            let gcmSenderID = call.getString("gcmSenderID")
            
            
            // More Feedback Logs
            print("Processed all inputs...")
            print("SerialNumberInput -- " + serialNumberInput)
            print("OrganizerNameInput -- " + organizerNameInput)
            print("PassCreationURL -- " + passCreationURL)
            print("PassDownloadURL -- " + passDownloadURL)
            print("PassAuthorizationKey -- " + passAuthorizationKey)
            print("Web Storage Service -- " + webStorageInput)
            print("Uses Serial Number in Download? " + (usesSerialNumberInDownloadURL ? "True" : "False"))
            print("Headers")
            print(headerLabelInput)
            print(headerValueInput)
            print("Primary")
            print(primaryLabelInput)
            print(primaryValueInput)
            
            
            // Checks Validity of Serial Number
            if (serialNumberInput == "Invalid"){
                call.reject("Please enter a valid serialNumber")
            }
            
            // Checks Validity of Organizer Name
            if (organizerNameInput == "Invalid"){
                call.reject("Please enter a valid organizerName")
            }
            
            // Checks Validity of Pass Type Input
            if (passCreationURL == "Invalid"){
                call.reject("passURL needs to be supplied")
            }
            
            // Checks Validity of Web Storage
            if (
                webStorageInput != "firebase" &&
                webStorageInput != "aws"
            ){
                call.reject("The'webstorage' prop needs to be provided and needs to be either 'firebase' or 'aws'")
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
            
            print("Passed all param validations...")
            
            //-----------------------//
            // PASS CREATION PROCESS //
            //-----------------------//
            
            // fires the function declared at the bottom of this file
            createPass(
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
                auxiliaryValueInput: auxiliaryValueInput)
                {
                    // We then fire the `completion` funtion which is initialized here
                    
                    // 'createPassResult' being the return value of the called function. Think of this like a really complicated looking `.then(createPassResult => {} ` but in Swift
                    createPassResult in
                    // if the result exists, do this...
                    if (createPassResult){
                        
                        
                        // IF Serial Number is in URL
                        if (usesSerialNumberInDownloadURL){
                            downloadPass(
                                passDownloadURL: passDownloadURL,
                                webStorage: webStorageInput,
                                usesSerialNumber: true,
                                call: call,
                                serialNumber: serialNumberInput,
                                firebaseStorageUrl: firebaseStorageUrl,
                                googleAppID: googleAppID
                            ){
                                downloadPassResult in
                                if (downloadPassResult){
                                    print("Downloaded")
                                }
                            }
                        }
                        
                        // IF Serial Number is not in URL
                        else{
                            downloadPass(
                                passDownloadURL: passDownloadURL,
                                webStorage: webStorageInput,
                                usesSerialNumber: false,
                                call: call,
                                serialNumber: nil,
                                firebaseStorageUrl: firebaseStorageUrl,
                                googleAppID: googleAppID
                            ){
                                downloadPassResult in
                                if (downloadPassResult){
                                    print("Downloaded")
                                }
                            }
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
}


//----------------//
// PASS FUNCTIONS //
//----------------//

// Generates the Pass
func createPass(
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
    
    completion: @escaping((Bool) -> () )
){
    
        
    print("     Inside 'createPass' sub-function")
    //--------//
    // PARAMS //
    //--------//
        
        //---------//
        // HEADERS //
        //---------//
        // Creates a blank JS Array Object to store the call params from JS App
        var headerLabels = [String]()
        var headerValues = [String]()
        
        // For Each with Index through Label JSArray from params
        headerLabelInput.enumerated().forEach{ (index, label) in
            if let swiftString = label as? String {
                headerLabels.append(swiftString)
            }
            else{
                headerLabels.append("Invalid")
            }
        }
        // For Each with Index through Value JSArray from params
        headerValueInput.enumerated().forEach{ (index, value) in
            if let swiftString = value as? String {
                headerValues.append(swiftString)
            }
            else{
                headerValues.append("Invalid")
            }
        }
    
        // Creates the Headers Object for final params
        var headers = [[String: String]]()
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
        
        //---------//
        // PRIMARY //
        //---------//
        // Creates a blank JS Array Object to store the call params from JS App
        var primaryLabels = [String]()
        var primaryValues = [String]()
        primaryLabelInput.enumerated().forEach{ (index, label) in
            if let swiftString = label as? String {
                primaryLabels.append(swiftString)
            }
            else{
                primaryLabels.append("Invalid")
            }
        }
        primaryValueInput.enumerated().forEach{ (index, value) in
            if let swiftString = value as? String {
                primaryValues.append(swiftString)
            }
            else{
                primaryValues.append("Invalid")
            }
        }
        var primary = [[String: String]]()
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
        
        //-----------//
        // SECONDARY //
        //-----------//
        // Creates a blank JS Array Object to store the call params from JS App
        var secondaryLabels = [String]()
        var secondaryValues = [String]()
        secondaryLabelInput.enumerated().forEach{ (index, label) in
            if let swiftString = label as? String {
                secondaryLabels.append(swiftString)
            }
            else{
                secondaryLabels.append("Invalid")
            }
        }
        secondaryValueInput.enumerated().forEach{ (index, value) in
            if let swiftString = value as? String {
                secondaryValues.append(swiftString)
            }
            else{
                secondaryValues.append("Invalid")
            }
        }
        var secondary = [[String: String]]()
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
        
        //-----------//
        // AUXILIARY //
        //-----------//
        // Creates a blank JS Array Object to store the call params from JS App
        var auxiliaryLabels = [String]()
        var auxiliaryValues = [String]()
        auxiliaryLabelInput.enumerated().forEach{ (index, label) in
            if let swiftString = label as? String {
                auxiliaryLabels.append(swiftString)
            }
            else{
                auxiliaryLabels.append("Invalid")
            }
        }
        auxiliaryValueInput.enumerated().forEach{ (index, value) in
            if let swiftString = value as? String {
                auxiliaryValues.append(swiftString)
            }
            else{
                auxiliaryValues.append("Invalid")
            }
        }
        var auxiliary = [[String: String]]()
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
        
    print("     Created 'params' pre-objects...")
        
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
        
        
        print("     created full params body object")
        
        // Creates a bare request object
        var request = URLRequest(url: URL(string: passCreationURL)!)
        
        
        print("     created request")
        
        // Specifies Request Method
        request.httpMethod = "POST"
        
        // Specifies content in request will be sent via JSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Attemts to Serialize the input JSON object. Said JSON object will be the previous declared params object
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        print("     request configuration complete, about to send...")
        
        // Deploys the request
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(false)
                return
            }
            
            if httpResponse.statusCode != 200 {
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                let result = json["result"] as? String
                completion(result == "SUCCESS")
            } catch {
                print("JSON serialization error: \(error)")
                completion(false)
            }
        }
        .resume()
        print("Session Complete! ")
    }

// Downloads the Pass from Firebase
func downloadPass(
    passDownloadURL: String,
    webStorage: String,
    usesSerialNumber: Bool,
    call: CAPPluginCall,
    serialNumber: String?,
    firebaseStorageUrl: String?,
    googleAppID: String?,
    completion: @escaping((Bool) -> () )
) {
    var pathToDownload = passDownloadURL
    if usesSerialNumber{
        if serialNumber != nil {
            pathToDownload = pathToDownload + (serialNumber ?? "INVALIDSERIALNUMBER") + ".pkpass"
        }
    }
    else{
        pathToDownload = pathToDownload + ".pkpass"
    }
    
    // FIREBASE Storage
    if (webStorage == "firebase"){
        let checkedURL = (firebaseStorageUrl ?? "INVALID")
        let checkedID = (googleAppID ?? "INVALID")
        if (checkedURL == "INVALID"){
            call.reject("If using Firebase Storage, you need to provide a FirebaseStorageUrl")
        }
        if (checkedID == "INVALID"){
            call.reject("If using Firebase Storage, you need to provide a googleAppID. This can be found in your app's GoogleService-Info.plist")
        }
        initializeFirebase(
            firebaseStorageUrl: checkedURL,
            googleAppID: checkedID,
            gcmSenderID: <#T##String#>,
            capPluginCall: call
        )
        
        firebaseDownloadPkPass(capPluginCall: call, path: passDownloadURL)
    }
    
    // AWS Storage
    if (webStorage == "aws"){
        
    }
    
}

//------------------//
// DOWNLOAD HELPERS //
//------------------//

// Initializes Firebase Connection if Firebase is the used Storage
func initializeFirebase(
    firebaseStorageUrl: String,         // Access URL ro Firebase
    googleAppID: String,                // This can be found in the google-services.json (Android) or GoogleService-Info.plist (iOS) files
    gcmSenderID: String,
    capPluginCall: CAPPluginCall
    
){
    // Sets up appropriate values for finding the Firebase Storage Proejct
    let fileopts = FirebaseOptions(googleAppID: googleAppID, gcmSenderID: gcmSenderID)
    fileopts.storageBucket = firebaseStorageUrl
    
    // Sets up the Firebase Connection
    FirebaseApp.configure(options: fileopts)
}

func firebaseDownloadPkPass(
    capPluginCall: CAPPluginCall,
    path: String
){
    // Connects to the Storage, provided the Firebase App connected
    let storage = Storage.storage()
    
    // Creates a Reference to the Storage Object, so the storage can be interacted with as a variable
    let storageRef = storage.reference()
    
    // Finds the specific file
    let fileRef = storageRef.child(path)
    
    // Downloads the File
    fileRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
        if let error = error {
            capPluginCall.reject("Error in Downloading the File. The Pass, however, was successfully created in Firebase Storage. It will not be added to this device until installed \n \(error.localizedDescription)")
        }
        else {
            capPluginCall.resolve(data)
        }
    }
}
