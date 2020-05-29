//
//  UIButton+Extension.swift
//  ABCarte2
//
//  Created by long nguyen on 6/26/19.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation

public extension UIButton {
    
    //*****************************************************************
    // MARK: - Round Corner Top of UIButton
    //*****************************************************************
    func roundTopCorner(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii:CGSize(width:8.0, height:8.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
}
