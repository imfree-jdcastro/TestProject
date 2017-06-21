//
//  MainDashboardVC.swift
//  Evrythng-iOS-SampleApp
//
//  Created by JD Castro on 29/05/2017.
//  Copyright © 2017 ImFree. All rights reserved.
//

import UIKit
import KRProgressHUD
import EvrythngiOS

public enum DashboardItems : String {
    case SCAN = "Scan"
    case ACTIVATE_USER = "Activate User"
}

class MainDashboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Static Variables
    
    static let SEGUE = "segueMainDashboard"
    static let CELL_ID = "mainDashboardCellId"
    
    // MARK: Private Variables
    
    private var tableViewItems = [DashboardItems.SCAN.rawValue,
                                  DashboardItems.ACTIVATE_USER.rawValue]
    
    // MARK: Public Variables
    
    public var credentials: Credentials?
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblUserId: UILabel!
    @IBOutlet weak var lblUserStatus: UILabel!
    @IBOutlet weak var lblApiKey: UILabel!
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(MainDashboardVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        self.checkCredentials()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bindDataToView()
    }
    
    func checkCredentials() {
        if let credentials = self.credentials, let status = credentials.status {
            
            if case CredentialStatus.Inactive = status {
                
                let alertDialog = UIAlertController.init(title: title, message: "User Status is still unauthenticated. Activate now?", preferredStyle: .alert)
                
                alertDialog.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
                    alertDialog.dismiss(animated: true, completion: nil)
                    print("UserID: \(String(describing: credentials.evrythngUser)) Activation Code: \(String(describing: credentials.activationCode))")
                    self.validateUser(userId: credentials.evrythngUser!, activationCode: credentials.activationCode!, completion: { (creds, err) in
                        self.handleUserValidationResponse(credentials: creds, err: err)
                    })
                }))
                
                alertDialog.addAction(UIAlertAction.init(title: "Later", style: .default, handler: { (action) in
                    alertDialog.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alertDialog, animated: true, completion: nil)
            } else {
                self.removeItem(itemName: DashboardItems.ACTIVATE_USER.rawValue)
            }
        } else {
            self.removeItem(itemName: DashboardItems.ACTIVATE_USER.rawValue)
        }
    }
    
    func bindDataToView() {
        if let credentials = self.credentials {
            if let status = credentials.status {
                self.lblUserStatus.text = status.rawValue
            }
            if let userId = credentials.evrythngUser {
                self.lblUserId.text = userId
            }
            if let apiKey = credentials.evrythngApiKey {
                self.lblApiKey.text = apiKey
            }
        }
    }
    
    func removeItem(itemName: String) {
        let newItems = self.tableViewItems.filter{$0 != itemName}
        self.tableViewItems.removeAll()
        self.tableViewItems.append(contentsOf: newItems)
        self.tableView.reloadData()
    }
    
    func back(sender: UIBarButtonItem) {
        self.logoutUser { (logoutResp, err) in
            if(err != nil) {
                print("Error in Logging Out! \(#function)")
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainDashboardVC.CELL_ID, for: indexPath)
        
        cell.textLabel?.text = self.tableViewItems[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(self.tableViewItems[indexPath.row]) {
        case DashboardItems.SCAN.rawValue:
            self.performSegue(withIdentifier: ViewController.SEGUE, sender: nil)
        case DashboardItems.ACTIVATE_USER.rawValue:
            if let credentials = self.credentials {
                self.validateUser(userId: credentials.evrythngUser!, activationCode: credentials.activationCode!, completion: { (creds, err) in
                    self.handleUserValidationResponse(credentials: creds, err: err)
                })
            }
        default:
            return
        }
    }
    
    // MARK: Segue 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch(identifier) {
                //case ViewController.SEGUE:
                case "abc":
                    if let viewController = segue.destination as? ViewController {
                        viewController.credentials = self.credentials
                    }
                    break
                default:
                    break
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension MainDashboardVC {
    internal func showAlertDialog(title: String, message: String) {
        let alertDialog = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertDialog.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            alertDialog.dismiss(animated: true, completion: nil)
        }))
        self.present(alertDialog, animated: true, completion: nil)
    }
    
    internal func validateUser(userId: String, activationCode: String, completion: ((Credentials?, Swift.Error?)->Void)?) {
        
        KRProgressHUD.show()
        
        let apiManager = EvrythngApiManager()
        apiManager.authService.evrythngUserValidator(userId: userId, activationCode: activationCode).execute(completionHandler: { (credentials, err) in
            
            KRProgressHUD.dismiss()
            if(err != nil) {
                completion?(nil, err)
            } else {
                if let createdCredentialsStringResp = credentials?.jsonData?.rawString() {
                    print("Validation Credentials: \(createdCredentialsStringResp)")
                }
                completion?(credentials, nil)
            }
        })
    }
    
    internal func handleUserValidationResponse(credentials: Credentials?, err: Swift.Error?) {
        self.credentials = credentials
        self.bindDataToView()
    }
    
    internal func logoutUser(_ completion: ((EvrythngLogoutResponse?, Swift.Error?)->Void)?) {
        KRProgressHUD.show()
        
        if let credentials = self.credentials {
            let apiManager = EvrythngApiManager()
            apiManager.authService.evrythngUserLogouter(apiKey: credentials.evrythngApiKey!).execute(completionHandler: { (logoutResp, err) in
                
                KRProgressHUD.dismiss()
                if(err != nil) {
                    completion?(nil, err)
                } else {
                    if let logoutStringResp = logoutResp?.jsonData?.rawString() {
                        print("Logout Response: \(logoutStringResp)")
                    }
                    completion?(logoutResp, nil)
                }
            })
        }
    }
}

