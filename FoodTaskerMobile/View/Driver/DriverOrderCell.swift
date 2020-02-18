//
//  DriverOrderCell.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2020/02/13.
//  Copyright © 2020 Dylan. All rights reserved.
//

import UIKit

class DriverOrderCell: UITableViewCell {

    @IBOutlet weak var lbRestaurantName: UILabel!
    @IBOutlet weak var lbCustomerName: UILabel!
    @IBOutlet weak var lbCustomerAddress: UILabel!
    @IBOutlet weak var imgCustomerAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
