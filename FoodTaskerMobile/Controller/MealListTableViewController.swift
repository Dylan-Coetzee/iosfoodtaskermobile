//
//  MealListTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/20.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit

class MealListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        return cell
    }
}
