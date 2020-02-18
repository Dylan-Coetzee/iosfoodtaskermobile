//
//  StatisticViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2020/02/12.
//  Copyright © 2020 Dylan. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
