//
//  CreateUserVC.swift
//  TestProject
//
//  Created by JD Castro on 09/06/2017.
//  Copyright © 2017 ImFree. All rights reserved.
//

import UIKit
import KRProgressHUD
import EvrythngiOS

class CreateUserVC: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    
    // MARK: IBActions
    
    @IBAction func actionCreateUser(_ sender: UIButton) {
        
        guard let firstName = self.tfFirstName.text, !firstName.isEmpty,
        let lastName = self.tfLastName.text, !lastName.isEmpty,
        let email = self.tfEmail.text, !email.isEmpty,
        let password = self.tfPassword.text, !password.isEmpty else {
                self.showAlertDialog(title: "Oops", message: "Please complete all fields", completionAction: nil)
                return
        }
        
        //let newUser = User(jsonData: ["firstName": firstName, "lastName": lastName, "email": email, "password": password])!
        
        let testUser = User()
        testUser.firstName = firstName
        testUser.lastName = lastName
        testUser.email = email
        testUser.password = password
        
        KRProgressHUD.show()
        self.createUser(user: testUser) { (credentials, err) in
            self.handleCredentialsResponse(credentials: credentials, err: err)
        }
    }
    
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createUser(user: User?, _ completion: ((Credentials?, Swift.Error?)->Void)?) {
        
        let apiManager = EvrythngApiManager(apiKey: Constants.API_KEY)
        apiManager.authService.evrythngUserCreator(user: user).execute(completionHandler: { (credentials, err) in
            if(err != nil) {
                completion?(nil, err)
            } else {
                if let createdCredentialsStringResp = credentials?.jsonData?.rawString() {
                    print("Created Credentials: \(createdCredentialsStringResp)")
                }
                completion?(credentials, nil)
            }
        })
    }
    
    func validateUser(userId: String, activationCode: String, completion: ((Credentials?, Swift.Error?)->Void)?) {
        
        let apiManager = EvrythngApiManager(apiKey: Constants.API_KEY)
        apiManager.authService.evrythngUserValidator(userId: userId, activationCode: activationCode).execute(completionHandler: { (credentials, err) in
            
            if(err != nil) {
                completion?(nil, err)
            } else {
                print("Creds: \(String(describing: credentials))")
                if let createdCredentialsStringResp = credentials?.jsonData?.rawString() {
                    print("Validation Credentials: \(createdCredentialsStringResp)")
                }
                completion?(credentials, nil)
            }
        })
        
    }
    
    func handleCredentialsResponse(credentials: Credentials?, err: Swift.Error?) {
        if(err != nil) {
            KRProgressHUD.dismiss()
            self.showErrorAlertDialog(err: err)
        } else {
            
            if let creds = credentials, let userId = creds.evrythngUser, let activationCode = creds.activationCode {
                self.validateUser(userId: userId, activationCode: activationCode, completion: { (validatedCreds, err) in
                    self.handleUserValidationResponse(credentials: validatedCreds, err: err)
                })
            } else {
                KRProgressHUD.dismiss()
                self.showAlertDialog(title: "Ooopss", message: "Unknown Error Occurred", completionAction: nil)
            }
        }
    }
    
    func handleUserValidationResponse(credentials: Credentials?, err: Swift.Error?) {
        
        if(err != nil) {
            KRProgressHUD.dismiss()
            self.showErrorAlertDialog(err: err)
        } else {
            KRProgressHUD.dismiss()
            self.showAlertDialog(title: "Congratulations", message: "New User Created and Activated!", completionAction: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        
    }
    
    internal func showAlertDialog(title: String, message: String, completionAction: (()->Void)?) {
        let alertDialog = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertDialog.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            alertDialog.dismiss(animated: true, completion: nil)
            completionAction?()
        }))
        self.present(alertDialog, animated: true, completion: nil)
    }
    
    internal func showErrorAlertDialog(err: Swift.Error?) {
        
        print("Error: \(err!.localizedDescription)")
        let alertTitle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        if case EvrythngNetworkError.ResponseError(let errorResponse) = err! {
            var errorMessage = ""
            if let errorList = errorResponse.errors {
                errorMessage = errorList.joined(separator: ", ")
            }
            if let errorCode = errorResponse.responseStatusCode {
                errorMessage += " [Code: \(errorCode)]"
            }
            self.showAlertDialog(title: alertTitle, message: errorMessage, completionAction: nil)
        } else {
            self.showAlertDialog(title: alertTitle, message: err!.localizedDescription, completionAction: nil)
        }
    }
}
