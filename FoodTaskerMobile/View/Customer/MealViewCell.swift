//
//  MealViewCell.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/12/03.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit

class MealViewCell: UITableViewCell {

    
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealShortDescription: UILabel!
    @IBOutlet weak var lbMealPrice: UILabel!
    @IBOutlet weak var imgMealImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
