//
//  TestVC.swift
//  TestProject
//
//  Created by JD Castro on 09/06/2017.
//  Copyright © 2017 ImFree. All rights reserved.
//

import UIKit
import EvrythngiOS

class TestVC: UIViewController {

    @IBAction func actionTest(_ sender: Any) {
        let evrythngScanner = EvrythngScanner.init(presentedBy: self)
        evrythngScanner.scanBarcode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
