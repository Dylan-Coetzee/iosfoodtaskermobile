//
//  APIManager.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/25.
//  Copyright © 2019 Dylan. All rights reserved.
//

//import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class APIManager {
    static let shared = APIManager()
    let baseURL = NSURL(string: BASE_URL)
    
    var accessToken = ""
    var refreshToken = ""
    var expired = Date()
    
    //Apli to login user
    func login(userType: String, completionHandler: @escaping (NSError?) -> Void) {
        let path = "api/social/convert-token/"
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "grant_type": "convert_token",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "backend": "facebook",
            "token": AccessToken.current!.tokenString,
            "user_type": userType
        ]
        //JSONEncoding.default fixed fixes immuteable error in django
        AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
                
                case .success(let value):
                    let jsonData = JSON(value)
                    self.accessToken = jsonData["access_token"].string!
                    self.refreshToken = jsonData["redresh_token"].string!
                    self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                    
                    completionHandler(nil)
                    
                case .failure(let error):
                    completionHandler(error as NSError?)
                    break
            }
        }
    }
    
    //Api to logout user
    func logout(completionHandler: @escaping (NSError?) -> Void) {
        let path = "api/social/revoke-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "token": self.accessToken,
        ]
        
        AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            switch response.result {
                case .success:
                    completionHandler(nil)
                    break
                    
                case .failure(let error):
                    completionHandler(error as NSError?)
                    break
            }
        }
    }
}
