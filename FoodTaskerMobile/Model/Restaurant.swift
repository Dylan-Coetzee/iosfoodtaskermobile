//
//  Restaurant.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/30.
//  Copyright © 2019 Dylan. All rights reserved.
//

import Foundation
import SwiftyJSON

class Restaurant {
    var id: Int?
    var name: String?
    var address: String?
    var logo: String?
    var phone: String?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.address = json["address"].string
        self.logo = json["logo"].string
        self.phone = json["phone"].string
    }
}
