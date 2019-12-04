//
//  MealListTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/20.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit

class MealListTableViewController: UITableViewController {

    var restaurant : Restaurant?
    var meals = [Meal]()
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restaurantName = restaurant?.name {
            self.navigationItem.title = restaurantName
        }
        
        loadMeals()
    }
    
    func loadMeals() {
        
        Helpers.showActivityIndicator(activityIndicator, view)
        
        if let restaurantId = restaurant?.id {
            APIManager.shared.getMeals(restaurantId: restaurantId, completionHandler: {(json) in
                if json != nil {
                    self.meals = []
                    if let tempMeals = json["meals"].array {
                        for item in tempMeals {
                            let meal = Meal(json: item)
                            self.meals.append(meal)
                        }
                        
                        self.tableView.reloadData()
                        Helpers.hideActivityIndicator(self.activityIndicator)
                    }
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MealDetails" {
            let controller = segue.destination as! MealDetailsViewController
            controller.meal = meals[(tableView.indexPathForSelectedRow?.row)!]
            controller.restaurant = restaurant
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealViewCell
        let meal = meals[indexPath.row]
        cell.lbMealName.text = meal.name
        cell.lbMealShortDescription.text = meal.short_description
        
        if let price = meal.price {
            cell.lbMealPrice.text = "R\(price)"
        }
        
        if let imgName = meal.image {
            let url = "\(imgName)"
            Helpers.loadImage(cell.imgMealImage, url)
        }
        
        return cell
    }
}
