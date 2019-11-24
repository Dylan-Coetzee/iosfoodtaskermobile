//
//  CustomerMenuViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/19.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit

class CustomerMenuViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(displayP3Red: 0.19, green: 0.18, blue: 0.31, alpha: 1.0)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CustomerLogout") {
            FBManager.shared.logOut()
            User.currentUser.resetInfo()
        }
    }
}
