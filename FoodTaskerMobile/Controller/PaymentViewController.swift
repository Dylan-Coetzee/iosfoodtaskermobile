//
//  PaymentViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/11/24.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController {

    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func placeOrder(_ sender: AnyObject) {
        
        APIManager.shared.getLatestOrder {(json) in
            
            let status = json["order"]["status"].string
            
            // Customer can only create one or and wait for it to complete before creating a new one.
            if status == nil || status == "Delivered" {
                //Processing the payment and create an order
                
                //let card = self.cardTextField.cardParams
                
                let cardParams = STPCardParams()

                cardParams.number = self.cardTextField?.cardNumber!
                cardParams.expMonth = (self.cardTextField?.expirationMonth)!
                cardParams.expYear = (self.cardTextField?.expirationYear)!
                cardParams.cvc = self.cardTextField?.cvc
                
                //Connect to stripe
                //STPAPIClient.shared().createToken(withCard: cardParams, completion: { (token, error) in
                STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
                    if let myError = error {
                        print("Error:", myError)
                    } else if let stripeToken = token {
                        APIManager.shared.createOrder(stripeToken: stripeToken.tokenId) { (json) in
                            Tray.currentTray.reset()
                            self.performSegue(withIdentifier: "ViewOrder", sender: self)
                        }
                    }
                }
            } else {
                //Show an alert message, order not complete.
                
                let alertView = UIAlertController (title: "Already Ordered?", message: "Your current order isn't completed", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
                let okAction = UIAlertAction(title: "Go to order", style: UIAlertAction.Style.default, handler: { (action) in
                    self.performSegue(withIdentifier: "ViewOrder", sender: self)
                })
                
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
}
