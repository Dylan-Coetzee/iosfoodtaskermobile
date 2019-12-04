//
//  Helpers.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2019/12/03.
//  Copyright © 2019 Dylan. All rights reserved.
//

import Foundation

class Helpers {
    
    //Helpers method to load images async
    static func loadImage(_ imageView: UIImageView,_ urlString: String) {
        let imgURL: URL = URL(string: urlString)!
        URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    //helper to show activity indicator
    static func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView,_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = UIColor.black

        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    //helper to hide activity indicator
    static func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
    }
}
