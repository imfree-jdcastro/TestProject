//
//  LoginVC.swift
//  Evrythng-iOS-SampleApp
//
//  Created by JD Castro on 26/05/2017.
//  Copyright © 2017 ImFree. All rights reserved.
//

import UIKit
import EvrythngiOS
import KRProgressHUD

class LoginVC: UIViewController {
    
    private var credentials: Credentials?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    // MARK: IBActions
    
    @IBAction func actionLogin(_ sender: UIButton) {
        
        let email = tfEmail.text!
        let password = tfPassword.text!
        
        if(StringUtils.isStringEmpty(string: email) && StringUtils.isStringEmpty(string: password)) {
            let err = NSError(domain:"Invalid Email / Password", code:999, userInfo:["Test":"Abc"])
            self.showErrorAlertDialog(err: err)
        } else {
            KRProgressHUD.show()
            self.authenticateUser(email: email, password: password) { (credentials, err) in
                KRProgressHUD.dismiss()
                self.handleCredentialsResponse(credentials: credentials, err: err)
            }
        }
    }
    
    @IBAction func actionLoginAnonymous(_ sender: UIButton) {
        KRProgressHUD.show()
        self.createAnonymousUser() { (credentials, err) in
            KRProgressHUD.dismiss()
            self.handleCredentialsResponse(credentials: credentials, err: err)
        }
    }
    
    // MARK: ViewController Life Cyle
    
    func handleCredentialsResponse(credentials: Credentials?, err: Swift.Error?) {
        if(err != nil) {
            self.showErrorAlertDialog(err: err)
        } else {
            self.credentials = credentials
            self.performSegue(withIdentifier: MainDashboardVC.SEGUE, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch(id) {
            case MainDashboardVC.SEGUE:
                if let mainDashboardTVC = segue.destination as? MainDashboardVC, let credentials = self.credentials {
                    mainDashboardTVC.credentials = credentials
                }
            default:
                return
            }
        }
    }
    
    // MARK: Other Funcs
    
    func createAnonymousUser(_ completion: ((Credentials?, Swift.Error?)->Void)?) {
        
        let apiManager = EvrythngApiManager()
        apiManager.authService.evrythngUserCreator(user: nil).execute(completionHandler: { (credentials, err) in
            if(err != nil) {
                completion?(nil, err)
            } else {
                if let createdCredentialsStringResp = credentials?.jsonData?.rawString() {
                    print("Created Credentials: \(createdCredentialsStringResp)")
                }
                completion?(credentials, nil)
                /*
                 if let userIdToDelete = user?.id {
                 print("Deleting User: \(userIdToDelete)")
                 self.deleteUser(userId: userIdToDelete, completion: nil)
                 } else {
                 print("Unable to delete user since userId is nil")
                 }
                 */
            }
        })
    }
    
    func authenticateUser(email: String, password: String, completion: ((Credentials?, Swift.Error?)->Void)?) {
        let apiManager = EvrythngApiManager(apiKey: Constants.API_KEY)
        apiManager.authService.evrythngUserAuthenticator(email: email, password: password).execute(completionHandler: { (credentials, err) in
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
}

extension LoginVC {
    
    internal func showAlertDialog(title: String, message: String) {
        let alertDialog = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertDialog.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            alertDialog.dismiss(animated: true, completion: nil)
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
            self.showAlertDialog(title: alertTitle, message: errorMessage)
        } else {
            self.showAlertDialog(title: alertTitle, message: err!.localizedDescription)
        }
    }
    
}
