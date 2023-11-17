// swift-tools-version:5.5

import Foundation
import Capacitor
import PassKit
import JavaScriptCore

//import FirebaseCore
//import FirebaseAuth
import Firebase
import FirebaseStorage

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
            
            // Values for PKPass Creation And Maintainance
            let passConfig = call.getObject("passConfig")
                let serialNumberInput = passConfig?["serialNumber"] as? String ?? "Invalid"
                let organizerNameInput = passConfig?["organizerName"] as? String ?? "Inavlid"
                let passCreationURL = passConfig?["passCreationURL"] as? String ?? "Invalid"
                let passAuthorizationKey = passConfig?["passAuthKey"] as? String ?? "Invalid"
    
            // Fields (optional)
            let passObject = call.getObject("passObject")
            
                // Header
                let headerLabelsInput = passObject?["headerLanels"] as? [String] ?? [String]()
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
            
            let passDownloadPath = storageConfig?["passDownloadPath"] as? String ?? ""
            let passStoredAs = storageConfig?["passStoredAs"] as? String ?? "pkpass"
            let webStorageInput = storageConfig?["webResourceUsed"] as? String ?? "INVALID"
            let usesSerialNumberInDownloadURL = storageConfig?["usesSerialNumberinDownload"] as? Bool ?? false

            
                // Firebase Related Fields
                let firebaseStorageUrl = storageConfig?["firebaseStorageUrl"] as? String ?? "INVALID"
                let googleAppID = storageConfig?["googleAppID"] as? String ?? "INVALID"
                let gcmSenderID = storageConfig?["gcmSenderID"] as? String ?? "INVALID"
                
                // AWS Related Fields
                let awsRegion = storageConfig?["awsRegion"] as? String ?? "INVALID"
                let awsBucketName = storageConfig?["awsBucketCode"] as? String ?? "INVALID"
            
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
            
            // Checks Validity of Web Storage
            if (
                webStorageInput != "firebase" &&
                webStorageInput != "aws"
            ){
                call.reject("The'webstorage' prop needs to be provided and needs to be either 'firebase' or 'aws'")
            }
                        
            // Checks every Label has a corresponding Value and vice versa
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
            
            do {
                let creationResult = try await createPass(
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
                )
                print("Pass Creation Completed!")
                print("Result...")
                print(creationResult)
            }
            catch{
                print("Error Creating the Pass!")
                call.reject("Error creating the pass")
            }
            
            await downloadPass(
                passDownloadPath: passDownloadPath,
                passStoredAs: passStoredAs,
                webStorage: webStorageInput,
                usesSerialNumber: usesSerialNumberInDownloadURL,
                call: call,
                serialNumber: serialNumberInput,
                firebaseStorageUrl: firebaseStorageUrl,
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
    passAuthorizationKey: String?,
    
    
    headerLabelInput: JSArray,
    headerValueInput: JSArray,
    primaryLabelInput: JSArray,
    primaryValueInput: JSArray,
    secondaryLabelInput: JSArray,
    secondaryValueInput: JSArray,
    auxiliaryLabelInput: JSArray,
    auxiliaryValueInput: JSArray,
    miscData: [String]
) async throws -> String {
    
    
    print("     Inside 'createPass' sub-function")
    let headers = populatePassBlock(labelArrayJS: headerLabelInput, valueArrayJS: headerValueInput, keyname: "header")
    let primary = populatePassBlock(labelArrayJS: primaryLabelInput, valueArrayJS: primaryValueInput, keyname: "primary")
    let secondary = populatePassBlock(labelArrayJS: secondaryLabelInput, valueArrayJS: secondaryValueInput, keyname: "secondary")
    let auxiliary = populatePassBlock(labelArrayJS: auxiliaryLabelInput, valueArrayJS: auxiliaryValueInput, keyname: "auxiliary")
    
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
        "miscData": miscData
    ]
    
    if let authKey = passAuthorizationKey {
        params["authenticationToken"] = authKey
    }
    
    print("     created full params body object")
    
    // Creates a bare request object
    // Specifies Request Method, values, and body content
    var request = URLRequest(url: URL(string: passCreationURL)!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    print("     request configuration complete, about to send...")
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        do {
            let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            let result = json["result"] as? String
            return result ?? "Error"
        }
        catch {
            print("JSON Serialization Error: \(error)")
            throw error
        }
    }
    catch {
        print("Error: \(error)")
        throw error
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
    
    firebaseStorageUrl: String,
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

// Downloads Pass from Firebase
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
            if let returnData = data?.base64EncodedString(){
                capPluginCall.resolve(["newPass": returnData])
            }
            else{
                capPluginCall.reject("Issue occurred in resolving the pkpass to string for return.")
            }
        }
    }
}
 




