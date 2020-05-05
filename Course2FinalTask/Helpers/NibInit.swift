//
//  NibInit.swift
//  Course2FinalTask
//
//  Created by Aleksey Bardin on 27.02.2020.
//  Copyright © 2020 Bardincom. All rights reserved.
//

import UIKit

protocol NibInit {}

extension NibInit where Self: UIView {
    
    static func initFromNib() -> Self {
        let nibName = String(describing: Self.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! Self
    }
}

