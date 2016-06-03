//
//  SyncDataViewController.swift
//  Todo
//
//  Created by xincun li on 3/10/16.
//  Copyright © 2016 Xincun Li. All rights reserved.
//

import UIKit

class SyncDataViewController: UIViewController {
    
    @IBOutlet weak var syncButton: UIButton!
    private let kKeychainItemName = "Drive API"
    private let kClientID = "702235373985-vmaqh3ggq4b36ujl76dkrd8h0f05a7k5.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeDriveMetadataReadonly]
    
    private let service = GTLServiceDrive()
    var fileID: String = "";
    //let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        let bgImage     = UIImage(named: "background.png");
        let imageView   = UIImageView(frame: self.view.bounds);
        imageView.image = bgImage
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
//
//        output.frame = view.bounds
//        output.editable = false
//        output.contentInset = UIEdgeInsets(top: 120, left: 0, bottom: 220, right: 0)
//        output.autoresizingMask =  [.FlexibleWidth, .FlexibleHeight]
//        view.addSubview(output);
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
                service.authorizer = auth
        }
    }
    
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
                fetchFiles()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // Construct a query to get names and IDs of 10 files using the Google Drive API
    func fetchFiles() {
        //output.text = "Getting files..."
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 10
        query.fields = "nextPageToken, files(id, name)"
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
        )
    }
    
    // Parse results and display
    func displayResultWithTicket(ticket : GTLServiceTicket,
        finishedWithObject response : GTLDriveFileList,
        error : NSError?) {
            
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
            
            //var filesString = ""
            
            if let files = response.files where !files.isEmpty {
                //filesString += "Files:\n"
                for file in files as! [GTLDriveFile] {
                    print( "\(file.name) (\(file.identifier))\n")
                    if file.name == TodoDBParameters.dbName {
                        fileID = file.identifier
                        break;
                    }
                }
            } else {
                //filesString = "No files found."
                fileID = "";
            }
            
            //output.text = filesString
    }
    
    
    // Creates the auth controller for authorizing access to Drive API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: "viewController:finishedWithAuth:error:"
        )
    }
    
    // Handle completion of the authorization process, and update the Drive API
    // with the new credentials.
    func viewController(vc : UIViewController,
        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
            
            if let error = error {
                service.authorizer = nil
                showAlert("Authentication Error", message: error.localizedDescription)
                return
            }
            
            service.authorizer = authResult
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Save the todo item
    @IBAction func okTapped(sender: AnyObject) {
        uploadPhoto()
    }
    
    func uploadPhoto() {
        let dbFilePath = "\(TodoDBParameters.dbPath)/\(TodoDBParameters.dbName)"
        let file = GTLDriveFile()
        file.name = TodoDBParameters.dbName
        file.descriptionProperty = "MyTodo Database file"
        file.mimeType = "application/x-mytodo-app"
        
        let data: NSData? = NSData(contentsOfFile: dbFilePath)
        
        
        let uploadParameters = GTLUploadParameters(data: data!, MIMEType: file.mimeType)
        let queryCreate = GTLQueryDrive.queryForFilesCreateWithObject(file, uploadParameters: uploadParameters)
        //let queryUpdate = GTLQueryDrive.queryForFilesUpdateWithObject(file, fileId: fileID, uploadParameters: uploadParameters)
        let waitIndicator = self.showWaitIndicator("Uploading To Google Drive")
        print(fileID.characters.count)
        self.service.executeQuery(/*fileID.characters.count > 0 ? queryUpdate : */queryCreate , completionHandler:  { (ticket, insertedFile , error) -> Void in
            let myFile = insertedFile as? GTLDriveFile
            
            waitIndicator.dismissWithClickedButtonIndex(0, animated: true)
            if error == nil {
                print("File ID \(myFile?.identifier)")
                self.showAlert("Google Drive", message: "File updated")
            } else {
                print("An Error Occurred! \(error)")
                self.showAlert("Google Drive", message: "Sorry, an error occurred!")
            }
            
        })
    }
    
    func showWaitIndicator(title:String) -> UIAlertView {
        //        println("showWaitIndicator \(title)")
        let progressAlert = UIAlertView()
        progressAlert.title = title
        progressAlert.message = "Please Wait...."
        progressAlert.show()
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.center = CGPointMake(progressAlert.bounds.size.width / 2, progressAlert.bounds.size.height - 45)
        progressAlert.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        return progressAlert
    }
}

