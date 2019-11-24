//
//  FBManager.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/24.
//  Copyright © 2019 Dylan. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON

class FBManager {
    static let shared = LoginManager()
    
    public class func getFBUserData(completionHandler: @escaping () -> Void) {
        if(AccessToken.current != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"]).start { (connection, result, error) in
                if(error != nil) {
                    LoginManager().logOut()
                    return
                } else if (result == nil) {
                    LoginManager().logOut()
                    return
                } else {
                    let json = JSON(result!)
                    print(json)
                    User.currentUser.setInfo(json: json)
                    completionHandler()
                }
            }
        }
        
    }
}
