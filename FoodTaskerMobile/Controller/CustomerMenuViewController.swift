//
//  CustomerMenuViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/19.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit

class CustomerMenuViewController: UITableViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbName.text = User.currentUser.name
        imgAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
        imgAvatar.layer.cornerRadius = 70/2
        imgAvatar.layer.borderWidth = 1.0
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.clipsToBounds = true
        
        view.backgroundColor = UIColor(displayP3Red: 0.19, green: 0.18, blue: 0.31, alpha: 1.0)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(identifier == "CustomerLogout") {
            APIManager.shared.logout { (error) in
                if(error == nil) {
                    FBManager.shared.logOut()
                    User.currentUser.resetInfo()

                    //Re-render the view once logout
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let appController = storyboard.instantiateViewController(identifier: "MainController") as! LoginViewController

                    let frame = UIScreen.main.bounds
                    let window = UIWindow(frame: frame)

                    window.rootViewController = appController
                    self.performSegue(withIdentifier: "CustomerLogout", sender: self)
                }
            }
            return false
        }
        return true
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "CustomerLogout") {
//            APIManager.shared.logout { (error) in
//                if(error == nil) {
//                    FBManager.shared.logOut()
//                    User.currentUser.resetInfo()
//
//                    //Re-render the view once logout
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let appController = storyboard.instantiateViewController(identifier: "MainController") as! LoginViewController
//
//                    let frame = UIScreen.main.bounds
//                    let window = UIWindow(frame: frame)
//
//                    window.rootViewController = appController
//                }
//            }
//        }
//    }
}
