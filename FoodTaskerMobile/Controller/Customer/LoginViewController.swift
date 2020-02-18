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

    @IBOutlet weak var bLogin: UIButton!
    @IBOutlet weak var bLogout: UIButton!
    @IBOutlet weak var switchUser: UISegmentedControl!
    
    var fbLoginSuccess = false
    var userType: String = USERTYPE_CUSTOMER
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (AccessToken.current != nil)
        {
            bLogout.isHidden = true
            FBManager.getFBUserData(completionHandler: {
                self.bLogin.setTitle("Continue as \(User.currentUser.email!)", for: .normal)
                self.bLogin.sizeToFit()
            })
        } else {
            bLogout.isHidden = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        userType = userType.capitalized
        
        if(AccessToken.current != nil && fbLoginSuccess == true) {
            performSegue(withIdentifier: "\(userType)View", sender: self)
        }
    }
    
    @IBAction func facebookLogout(_ sender: Any) {
        
        APIManager.shared.logout { (error) in
            if (error == nil) {
                FBManager.shared.logOut()
                User.currentUser.resetInfo()
                
                self.bLogout.isHidden = true
                self.bLogin.setTitle("Login with Facebook", for: .normal)
            }
        }
        
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        if(AccessToken.current != nil) {
            APIManager.shared.login(userType: userType) { (error) in
                if (error == nil) {
                    self.fbLoginSuccess = true
                    self.viewDidAppear(true)
                }
            }
        }
        else {
            FBManager.shared.logIn(
                permissions: ["public_profile", "email"],
                from: self,
                handler: { (result, error) in
                    if(error == nil) {
                        FBManager.getFBUserData(completionHandler: {
                            APIManager.shared.login(userType: self.userType) { (error) in
                                if (error == nil) {
                                    self.fbLoginSuccess = true
                                    self.viewDidAppear(true)
                                }
                            }
                        })
                    }
            })
        }
    }
    
    //Switch Segment Driver vs Customer
    @IBAction func switchAccount(_ sender: AnyObject) {
        let type = switchUser.selectedSegmentIndex
        
        if type == 0 {
            userType = USERTYPE_CUSTOMER
        } else {
            userType = USERTYPE_DRIVER
        }
    }
    
}
