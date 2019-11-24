//
//  User.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/24.
//  Copyright © 2019 Dylan. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    var name: String?
    var email: String?
    var pictureURL: String?
    
    static let currentUser = User()
    
    func setInfo(json: JSON) {
        self.name = json["name"].string
        self.email = json["email"].string
        let imageData = json["picture"].dictionary
        self.pictureURL = imageData?["url"]?.string
    }
    
    func resetInfo() {
        self.name = nil
        self.email = nil
        self.pictureURL = nil
    }
}
