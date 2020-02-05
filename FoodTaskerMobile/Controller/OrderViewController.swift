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
            
            if let orderDetails = json["order"]["order_details"].array {
                
                self.lbStatus.text = order["status"].string!.uppercased()
                self.tray = orderDetails
                self.tbvMeals.reloadData()
            }
            
            let from = order["restaurant"]["address"].string!
            let to = order["address"].string!
            
            self.getLocation(from, "Restaurant", { (src) in
                self.source = src
                
                self.getLocation(to, "Customer", { (des) in
                    self.destination = des
                    self.getDirections()
                })
            })
        }
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

        DispatchQueue.main.async {
            for route in response.routes {
                self.map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            }
        }

        for route in response.routes {
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
