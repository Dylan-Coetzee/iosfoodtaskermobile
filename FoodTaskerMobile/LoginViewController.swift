//
//  LoginViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/24.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    var fbLoginSuccess = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if(AccessToken.current != nil && fbLoginSuccess == true) {
            performSegue(withIdentifier: "CustomerView", sender: self)
        }
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        if(AccessToken.current != nil) {
            fbLoginSuccess = true
            self.viewDidAppear(true)
        }
        else {
            FBManager.shared.logIn(
                permissions: ["public_profile", "email"],
                from: self,
                handler: { (result, error) in
                    if(error == nil) {
                        self.fbLoginSuccess = true
                    }
            })
        }
    }
}
