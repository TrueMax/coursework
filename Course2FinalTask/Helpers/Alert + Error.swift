//
//  Alert + Error.swift
//  Course3FinalTask
//
//  Created by Maxim on 2020. 05. 05..
//  Copyright © 2020. Bardincom. All rights reserved.
//

import Foundation
import UIKit

enum DataProviderError: Error {
    case noUserError
    case noPostError
    
    var alertMessage: String {
        switch self {
        case .noUserError:
            return "No user found"
        case .noPostError:
            return "No post found"
        }
    }
}

class AlertFactory {
    
    func createAlert(error: DataProviderError) -> UIAlertController {
        let controller = UIAlertController(title: "Alert title", message: error.alertMessage, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Error", style: .cancel, handler: nil))
        return controller
    }
    
}
