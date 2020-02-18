//
//  DeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2020/02/12.
//  Copyright © 2020 Dylan. All rights reserved.
//

import UIKit
import MapKit

class DeliveryViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var lbCustomerName: UILabel!
    @IBOutlet weak var lbCustomerAddress: UILabel!
    @IBOutlet weak var imgCustomerAvatar: UIImageView!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bComplete: UIButton!
    
    var orderId: Int?
    let activityIndicator =  UIActivityIndicatorView()
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    
    var locationManager: CLLocationManager!
    var driverPin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //Show current driver location
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization() //This got the prompt for location working.
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            //locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
        
        //Running the updating location process
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLocation(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func updateLocation(_ sender: AnyObject) {
        APIManager.shared.updateLocation(location: self.lastLocation) { (json) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Helpers.showActivityIndicator(activityIndicator, self.view)
        self.viewInfo.isHidden = true
        loadData()
    }
    
    func loadData() {
        APIManager.shared.getCurrentDriverOrder { (json) in
            let order = json["order"]
            
            if let id = order["id"].int, order["status"] == "On the way" {
                
                self.lbCustomerName.isHidden = false
                self.lbCustomerAddress.isHidden = false
                
                self.orderId = id
                let from = order["address"].string!
                let to = order["restaurant"]["address"].string!
                let customerName = order["customer"]["name"].string!
                let customerAvatar = order["customer"]["avatar"].string!
                
                self.lbCustomerName.text = customerName
                self.lbCustomerAddress.text = from
                self.imgCustomerAvatar.image =  try! UIImage(data: Data(contentsOf: URL(string: customerAvatar)!))
                self.imgCustomerAvatar.layer.cornerRadius = 50/2
                self.imgCustomerAvatar.clipsToBounds = true
                
                self.getLocation(to, "Restaurant", { (src) in
                    self.source = src
                    
                    self.getLocation(from, "Customer", { (des) in
                        self.destination = des
                        self.getDirections()
                    })
                })
                
            } else {
                self.map.isHidden = true
                self.viewInfo.isHidden = true
                self.bComplete.isHidden = true
                self.lbCustomerName.isHidden = true
                self.lbCustomerAddress.isHidden = true
                
                let lbMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
                lbMessage.center = self.view.center
                lbMessage.textAlignment = NSTextAlignment.center
                lbMessage.text = "You don't have any orders for delivery."
                
                self.view.addSubview(lbMessage)
            }
            self.viewInfo.isHidden = false
            Helpers.hideActivityIndicator(self.activityIndicator)
        }
    }

    @IBAction func completeOrder(_ sender: Any) {
        let alertView = UIAlertController (title: "Complete Order", message: "Are you sure?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            APIManager.shared.completeOrder(orderId: self.orderId!) { (json) in
                if json != nil {
                    //Stop updating driver location
                    self.timer.invalidate()
                    self.locationManager.stopUpdatingLocation()
                    //redirect to orders view
                    self.performSegue(withIdentifier: "ViewOrders", sender: self)
                }
            }
            
        })
        
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
}

extension DeliveryViewController : MKMapViewDelegate {
    
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
}

extension DeliveryViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        self.lastLocation = location.coordinate
        
        //Create pin annotation for driver
        if driverPin != nil {
            driverPin.coordinate = self.lastLocation
        } else {
            driverPin = MKPointAnnotation()
            driverPin.coordinate = self.lastLocation
            self.map.addAnnotation(driverPin)
        }
        
        //Reset zoom rect to cover 3 locations
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
