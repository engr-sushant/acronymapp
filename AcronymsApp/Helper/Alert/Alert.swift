//
//  Alert.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 13/02/23.
//

import UIKit

class Alert {
    static func display(viewController: UIViewController,
                        title: String = "Alert",
                        message: String = "",
                        action: UIAlertAction? = nil) {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        
        if action == nil {
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        } else {
            ac.addAction(action!)
        }
        DispatchQueue.main.async {
            viewController.present(ac, animated: true)
        }
    }
}
