//
//  UIView+Extension.swift
//  ABCarte2
//
//  Created by long nguyen on 6/26/19.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation

public extension UIView {
    
    //*****************************************************************
    // MARK: - UIView Convert UIImage
    //*****************************************************************
    func asImage() -> UIImage {
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.scale = 1.0
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: renderFormat)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    //*****************************************************************
    // MARK: - Gradient View
    //*****************************************************************
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}
