// swift-tools-version:5.5

import Foundation
import Capacitor
import PassKit
import JavaScriptCore

//import FirebaseCore
//import FirebaseAuth
//import Firebase
//import FirebaseStorage

import Amplify
import ClientRuntime
import AWSS3



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
    @objc func generatePass(_ call: CAPPluginCall) async {
        
        // If Pass Library is Available
        if PKPassLibrary.isPassLibraryAvailable() {
            
            //----------------//
            // INPUT HANDLING //
            //----------------//
            
            // Needed Values for PKPass Creation
            let serialNumberInput = call.getString("serialNumberInput") ?? "Invalid"
            let organizerNameInput = call.getString("organizerNameInput") ?? "Inavlid"
            
            let passCreationURL = call.getString("passCreationURL") ?? "Invalid"
            let passDownloadPath = call.getString("passDownloadPath") ?? ""
            let passStoredAs = call.getString("passStoredAs") ?? "pkpass"
            let passAuthorizationKey = call.getString("passAuthorizationKey") ?? "Invalid"
            let webStorageInput = call.getString("webStorageInput") ?? "Invalid"
            let usesSerialNumberInDownloadURL = call.getBool("usesSerialNumberinDownload") ?? false
    
            // Fields (optional)
            let headerValueInput = call.getArray("headerValues") ?? [String]()
            let primaryValueInput = call.getArray("primaryValues") ?? [String]()
            let secondaryValueInput = call.getArray("secondaryValues") ?? [String]()
            let auxiliaryValueInput = call.getArray("auxiliaryValues") ?? [String]()
            let headerLabelInput = call.getArray("headerLabels") ?? [String]()
            let primaryLabelInput = call.getArray("primaryLabels") ?? [String]()
            let secondaryLabelInput = call.getArray("secondaryLabels") ?? [String]()
            let auxiliaryLabelInput = call.getArray("auxiliaryLabels") ?? [String]()
            
            
            // Firebase Related Fields
            let googleAppID = call.getString("googleAppID") ?? "INVALID"
            let gcmSenderID = call.getString("gcmSenderID") ?? "INVALID"
            
            // AWS Related Fields
            let awsRegion = call.getString("awsRegion") ?? "INVALID"
            let awsBucketName = call.getString("awsBucketCode") ?? "INVALID"
            
            
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
            await createPass(
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
                auxiliaryValueInput: auxiliaryValueInput
            )
            await downloadPass(
                passDownloadPath: passDownloadPath,
                passStoredAs: passStoredAs,
                webStorage: webStorageInput,
                usesSerialNumber: usesSerialNumberInDownloadURL,
                call: call,
                serialNumber: serialNumberInput,
                googleAppID: googleAppID,
                gcmSenderID: gcmSenderID,
                awsRegion: awsRegion,
                awsBucketName: awsBucketName
            ){
                downloadPassResult in
                if (downloadPassResult){
                    print("Downloaded")
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
    auxiliaryValueInput: JSArray
) async throws -> String {
    
        
    print("     Inside 'createPass' sub-function")
    let headers = populatePassBlock(labelArrayJS: headerLabelInput, valueArrayJS: headerValueInput, keyname: "header")
    let primary = populatePassBlock(labelArrayJS: primaryLabelInput, valueArrayJS: primaryValueInput, keyname: "primary")
    let secondary = populatePassBlock(labelArrayJS: secondaryLabelInput, valueArrayJS: secondaryValueInput, keyname: "secondary")
    let auxiliary = populatePassBlock(labelArrayJS: auxiliaryLabelInput, valueArrayJS: auxiliaryValueInput, keyname: "auxiliary")
    
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
        
        // Specifies Request Method, values, and body content
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        print("     request configuration complete, about to send...")
        
        // Deploys the request
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
//                return"Error: \(error)"
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            if httpResponse.statusCode != 200 {
                print("HTTP status code: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                let result = json["result"] as? String
                return result
            } catch {
                print("JSON serialization error: \(error)")
                return
            }
        }
    }

// Downloads the Pass from Firebase
func downloadPass(
    
    passDownloadPath: String,
    passStoredAs: String,
    webStorage: String,
    usesSerialNumber: Bool,
    call: CAPPluginCall,
    serialNumber: String?,
    
    googleAppID: String,
    gcmSenderID: String,
    
    awsRegion: String,
    awsBucketName: String,
    
    completion: @escaping((Bool) -> () )
    
) async {
    
    print("     Entered downloadPass()")
    var pathToDownload = passDownloadPath
    
    if usesSerialNumber{
        if serialNumber != nil {
            pathToDownload = pathToDownload + (serialNumber ?? "INVALID-SERIAL-NUMBER")
        }
    }
    pathToDownload = pathToDownload + "." + passStoredAs
    
    // FIREBASE Storage
    if (webStorage == "firebase"){
        print("Firebase Storage")
        print("Searching for " + pathToDownload)
    }
    
    // AWS Storage
    if (webStorage == "aws"){
        print("AWS S3 Storage")
        print("Searching for " + pathToDownload)
        if (awsRegion == "INVALID"){
            call.reject("If using AWS S3 Storage, you need to provide an awsRegion value. For example, 'us-north-2' or 'af-south-1' " )
        }
        if (awsBucketName == "INVALID"){
            call.reject("If using AWS S3 Storage, you need to provide a awsBucketNAme. This can be found in your AWS S3 List")
        }
        
        await awsDownloadPkPass(
            capPluginCall: call,
            awsRegion: awsRegion,
            awsBucketName: awsBucketName,
            awsFilePath: pathToDownload
        )
    }
    
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
    else{
        return([
            [
                "label": reqLabels[0],
                "value": reqValues[0],
                "key": (keyname + "0")
            ]
        ])
    }
}

//------------------//
// DOWNLOAD HELPERS //
//------------------//
 func awsDownloadPkPass(
    capPluginCall: CAPPluginCall,
    awsRegion: String,
    awsBucketName: String,
    awsFilePath: String
 ) async{
    
    do { let client = try S3Client(region: awsRegion)
    do { let s3 = try await S3Client()
          
        let inputObject = GetObjectInput(bucket: awsBucketName, key: awsFilePath)
    }
        
    // If the Client Service Cannot be established
    catch {
            
    }}


    // If no valid awsRegion was provided
    catch {
        print("Error creating S3Client: \(error)")
        capPluginCall.reject("There was an invalid awsRegion value applied. Please make sure when using aws as your webStorage to fill in all aws field. For example, this should look something like 'us-east-1'")
    }}
 





