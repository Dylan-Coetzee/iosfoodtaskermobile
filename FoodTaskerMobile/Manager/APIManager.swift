//
//  APIManager.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/25.
//  Copyright © 2019 Dylan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit
import MapKit

class APIManager {
    static let shared = APIManager()
    let baseURL = NSURL(string: BASE_URL)
    
    var accessToken : String?
    var refreshToken : String?
    var expired = Date()
    
    //Apli to login user
    func login(userType: String, completionHandler: @escaping (NSError?) -> Void) {
        let path = "api/social/convert-token/"
        //let headers = ["Content-Type": "application/x-www-form-urlencoded"]
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
        AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            switch response.result {
                
                case .success(let value):
                    
                    let data = value.data(using: .utf8)!
                    
                    do {
                        if let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]{
                            self.accessToken = jsonData["access_token"] as! String
                            self.refreshToken = jsonData["refresh_token"] as! String
                            self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"] as! Int))
                        }
                    }
                    catch { print(error.localizedDescription) }
                    
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
    
    //Refresh token when it expired
    func refreshTokenIfNeed(completionHandler: @escaping () -> Void) {
        let path = "api/social/refresh-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "refresh_token": self.refreshToken,
        ]
        
        if (Date() > self.expired) {
            AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseString { (response) in
                switch response.result {
                    case .success(let value):
                        
                        let data = value.data(using: .utf8)!
                        
                        do {
                            if let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]{
                                self.accessToken = jsonData["access_token"] as! String
                                //self.refreshToken = jsonData["refresh_token"] as! String
                                self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"] as! Int))
                            }
                        }
                        catch { print(error.localizedDescription) }
                        
                        completionHandler()
                        break
                        
                    case .failure:
                        break
                }
            }
        } else {
            completionHandler()
        }
    }
    
    //Server request reuse able code
    func requestServer(_ method: Alamofire.HTTPMethod,_ path: String,_ params: [String: Any]?,_ encoding: ParameterEncoding,_ completionHandler: @escaping (JSON) -> Void ) {
        
        let url = baseURL!.appendingPathComponent(path)
        
        //TODO: This needs auth
        refreshTokenIfNeed {
            AF.request(url!, method: method, parameters: params, encoding: encoding, headers: nil).responseJSON { (response) in
                switch response.result {
                    case .success(let value):
                        let jsonData = JSON(value)
                        completionHandler(jsonData)
                        break
                        
                    case .failure(let fail):
                        let jsonFail = JSON(fail)
                        completionHandler(jsonFail)
                        break
                }
            }
        }
    }
    
    //API for getting Restaurant list
    func getRestaurants(completionHandler: @escaping (JSON) -> Void) {
        let path = "api/customer/restaurants/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    //API get list of meals for a specific restaurants
    func getMeals(restaurantId: Int, completionHandler: @escaping (JSON) -> Void) {
        let path = "api/customer/meals/\(restaurantId)"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    //API create new order
    func createOrder(stripeToken: String, completionHandler: @escaping (JSON) -> Void) {
        let path = "api/customer/order/add/"
        let simpleArray = Tray.currentTray.items
        let jsonArray = simpleArray.map { item in
            return [
                "meal_id": item.meal.id!,
                "quantity": item.qty
            ]
        }
        
        if JSONSerialization.isValidJSONObject(jsonArray) {
            do {
                let data = try  JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                
                let params: [String: Any] = [
                    "access_token": self.accessToken!,
                    "stripe_token": stripeToken,
                    "restaurant_id": "\(Tray.currentTray.restaurant!.id!)",
                    "order_details": dataString,
                    "address": Tray.currentTray.address!
                ]
                
                requestServer(.post, path, params, URLEncoding.httpBody, completionHandler)
                //UrlEncoding.http fix the issue with parameters not picking up in django side
                //(AccessToken matching query does not exist.)
            }
            catch {
                print("JSON serialization failed: \(error)")
            }
        }
    }
    
    // API - Getting the latest order (Customer)
    func getLatestOrder(completionHandler: @escaping (JSON) -> Void) {
        let path = "api/customer/order/latest/"
        let params : [String: Any] = [
            "access_token": self.accessToken!
        ]
        
        requestServer(.get, path, params, URLEncoding(), completionHandler)
    }
    
    // API - Getting drivers location
    func getDriverLocation(completionHandler: @escaping (JSON) -> Void) {
        let path = "api/customer/driver/location/"
        let params : [String: Any] = [
            "access_token": self.accessToken!
        ]
        requestServer(.get, path, params, URLEncoding(), completionHandler)
    }
    
    
    //***DRIVERS***
    
    //API - getting list of orders that are ready
    func getDriverOrders(completionHandler: @escaping (JSON) -> Void) {
        let path = "api/driver/orders/ready/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    
    //API - Picking up a ready order
    
    func pickOrder(orderId: Int, completionHandler: @escaping (JSON) -> Void) {
        let path = "api/driver/orders/pick/"
        let params: [String: Any] = [
            "order_id": "\(orderId)",
            "access_token": self.accessToken!
        ]
        
        requestServer(.post, path, params, URLEncoding.httpBody, completionHandler)
    }
    
    func getCurrentDriverOrder(completionHandler: @escaping (JSON) -> Void) {
        let path = "api/driver/orders/latest/"
        let params: [String: Any] = [
            "access_token": self.accessToken!
        ]
        
        requestServer(.get, path, params, URLEncoding(), completionHandler)
    }
    
    //API - Update drivers location
    func updateLocation(location: CLLocationCoordinate2D, completionHandler: @escaping (JSON) -> Void) {
        let path = "api/driver/location/update/"
        let params: [String: Any] = [
            "access_token": self.accessToken!,
            "location": "\(location.latitude),\(location.longitude)"
        ]
        
        requestServer(.post, path, params, URLEncoding.httpBody, completionHandler)
    }
    
    // API - Complete the order
    func completeOrder(orderId: Int, completionHandler: @escaping (JSON) -> Void) {
        let path = "api/driver/orders/complete/"
        let params: [String: Any] = [
            "access_token": self.accessToken!,
            "order_id": "\(orderId)"
        ]
        
        requestServer(.post, path, params, URLEncoding.httpBody, completionHandler)
    }
}
