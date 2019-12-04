//
//  MealDetailsViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/20.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit

class MealDetailsViewController: UIViewController {

    @IBOutlet weak var imgMeal: UIImageView!
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealShortDescription: UILabel!
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    
    var meal: Meal?
    var restaurant: Restaurant?
    var qty = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMeal()
    }
    
    func loadMeal() {
        if let price = meal?.price {
            lbTotal.text = "R\(price)"
        }
        
        lbMealName.text = meal?.name
        lbMealShortDescription.text = meal?.short_description
        
        if let imageUrl = meal?.image {
            Helpers.loadImage(imgMeal, "\(imageUrl)")
        }
    }

    @IBAction func addToTray(_ sender: UIButton) {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        image.image = UIImage(named: "button_chicken")
        image.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height-100)
        self.view.addSubview(image)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {image.center = CGPoint(x: self.view.frame.width - 40, y: 24 ) } , completion: { _ in image.removeFromSuperview() })
        
        let trayItem = TrayItem(meal: self.meal!, qty: self.qty)
        guard let trayRestaurant = Tray.currentTray.restaurant, let currentRestaurant = self.restaurant else {
            Tray.currentTray.restaurant = self.restaurant
            Tray.currentTray.items.append(trayItem)
            return
        }
        
        if trayRestaurant.id == currentRestaurant.id {
            let inTray = Tray.currentTray.items.index(where: {(item) -> Bool in
                return item.meal.id! == trayItem.meal.id!
            })
            
            if let index = inTray {
                let alertView = UIAlertController (title: "Add more?", message: "Your tray already has this meal. Do you want to add more?", preferredStyle: .alert)
                //let okAction = IUAlertAction(title: "A")
            }
        } else {
            
        }
        
    }
    
    @IBAction func addQty(_ sender: UIButton) {
        if qty < 99 {
            qty += 1
            lbQty.text = String(qty)

            if let price = meal?.price {
                lbTotal.text = "R\(price * Float(qty))"
            }
        }
    }
    
    @IBAction func removeQty(_ sender: UIButton) {
        if qty >= 2 {
            qty -= 1
            lbQty.text = String(qty)

            if let price = meal?.price {
                lbTotal.text = "R\(price * Float(qty))"
            }
        }
    }
}
