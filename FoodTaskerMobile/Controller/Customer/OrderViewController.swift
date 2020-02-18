//
//  OrderViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/24.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class OrderViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var tbvMeals: UITableView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbStatus: UILabel!
    
    var tray = [JSON]()
    
    var destination: MKPlacemark? //Customer address
    var source: MKPlacemark?      //Restaurant address
    
    var driverPin: MKPointAnnotation!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        getLatestOrder()
    }
    
    func getLatestOrder() {
        APIManager.shared.getLatestOrder{(json) in
            print(json)
            
            let order = json["order"]
            var orderStatus: String?
            orderStatus = order["status"].string
            
            //If the customer has an order
            if orderStatus != nil {
                
                self.lbStatus.isHidden = false
                self.map.isHidden = false
                self.tbvMeals.isHidden = false
                
                if let orderDetails = json["order"]["order_details"].array {
                    
                    self.lbStatus.text = order["status"].string!.uppercased()
                    self.tray = orderDetails
                    self.tbvMeals.reloadData()
                }
                
                let from = order["restaurant"]["address"].string!
                let to = order["address"].string!
                
                self.getLocation(from, "RES", { (src) in
                    self.source = src
                    
                    self.getLocation(to, "CUS", { (des) in
                        self.destination = des
                        self.getDirections()
                    })
                })
                
                if order["status"] != "Delivered" {
                    self.setTimer()
                }
            } else {
                //You have no order sorry
                let lbEmptyTray = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
                lbEmptyTray.center = self.view.center
                lbEmptyTray.textAlignment = NSTextAlignment.center
                lbEmptyTray.text = "You currently have no orders."
                
                self.view.addSubview(lbEmptyTray)
            }
        }
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5,
                                     target: self,
                                     selector: #selector(getDriverLocation(_:)),
                                     userInfo: nil, repeats: true)
    }
    
    @objc func getDriverLocation(_ sender: AnyObject) {
        APIManager.shared.getDriverLocation { (json) in
            if let location = json["location"].string {
                self.lbStatus.text = "ON THE WAY"
                let split = location.components(separatedBy: ",")
                let lat = split[0]
                let lng = split[1]
                
                let coordinate = CLLocationCoordinate2D(latitude:CLLocationDegrees(lat)!, longitude: CLLocationDegrees(lng)!)
                
                //Create pin annotation for driver
                if self.driverPin != nil {
                    self.driverPin.coordinate = coordinate
                } else {
                    self.driverPin = MKPointAnnotation()
                    self.driverPin.coordinate = coordinate
                    self.driverPin.title = "DRI"
                    self.map.addAnnotation(self.driverPin)
                }
                //Reset zoom rect to cover 3 locations
                self.autoZoom()
            } else {
                self.timer.invalidate()
            }
        }
    }
    
    func autoZoom()
    {
        var zoomRect = MKMapRect.null
        for annotation in self.map.annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(pointRect)
        }

        let insetWidth = -zoomRect.size.width * 0.2
        let insetHeight = -zoomRect.size.height * 0.2
        let insetRect = zoomRect.insetBy(dx: insetWidth, dy: insetHeight)

        self.map.setVisibleMapRect(insetRect, animated: true)
    }
}

extension OrderViewController : MKMapViewDelegate {
    
    // #1 - Delegate method of MKMapView Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    // #2 - Convert an address string to a location on the map
    func getLocation(_ address: String,_ title: String,_ completionHandler: @escaping (MKPlacemark) -> Void) {
    
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                print("Error: ", error)
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate

                //Create drop pin for the map
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                
                self.map.addAnnotation(dropPin)
                completionHandler(MKPlacemark.init(placemark: placemark))
            }
        }
    }
    
    // #3 - Get direction and zoom to address
    func getDirections() {
        let request = MKDirections.Request()
        request.source = MKMapItem.init(placemark: source!)
        request.destination = MKMapItem.init(placemark: destination!)
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            
            if (error != nil) {
                print("Error: ", error)
            } else {

                // #4 Show route between location and make visiable zoom
                guard let unwrappedResponse = response else { return }
                
                for route in unwrappedResponse.routes {
                    self.map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                }
                
                var zoomRect = MKMapRect.null
                for annotation in self.map.annotations {
                    let annotationPoint = MKMapPoint(annotation.coordinate)
                    let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
                    zoomRect = zoomRect.union(pointRect)
                }
                
                let insetWidth = -zoomRect.size.width * 0.2
                let insetHeight = -zoomRect.size.height * 0.2
                let insetRect = zoomRect.insetBy(dx: insetWidth, dy: insetHeight)
                
                self.map.setVisibleMapRect(insetRect, animated: true)
            }
        }
    }
    
    // #4 Show route between location and make visiable zoom
    func showRoute(response: MKDirections.Response) {

        for route in response.routes {
            self.map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
    }
    
    //5 #Customize pin point with image
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "MyPin"
        var annotationView: MKAnnotationView?
        if let dequeueAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeueAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView, let name = annotation.title! {
            switch name {
            case "DRI" :
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_car")
            case "RES" :
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "pin_restaurant")
            case "CUS" :
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "pin_customer")
            default :
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "pin_car")
            }
        }
        return annotationView
    }
}

extension OrderViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderViewCell
        
        let item = tray[indexPath.row]
        cell.lbQty.text = String(item["quantity"].int!)
        cell.lbMealName.text = item["meal"]["name"].string
        cell.lbSubTotal.text = "R\(String(item["sub_total"].float!))"
        
        return cell
    }
    
}
