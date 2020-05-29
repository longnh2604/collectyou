//
//  BaseImageView.swift
//  Chat
//
//  Created by None on 8/29/19.
//  Copyright © 2019 ConnectyCube. All rights reserved.
//

import UIKit

class BaseImageView: UIImageView {

    let shapeLayer = CAShapeLayer()
    
    var incomingTail = true
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        setup();
    }
    
    func setup() {
        
        // Create a CAShapeLayer
        
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        shapeLayer.path = createBezierPath().cgPath
        
        if (incomingTail) {
            shapeLayer.transform = CATransform3DMakeRotation(.pi, 0.0, 0.0, 1.0)
            
            // apply other properties related to the path
            shapeLayer.strokeColor = #colorLiteral(red: 0.3333333333, green: 0.1843137255, blue: 0, alpha: 1)
            shapeLayer.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            // apply other properties related to the path
            shapeLayer.strokeColor = #colorLiteral(red: 0.3333333333, green: 0.1843137255, blue: 0, alpha: 1)
            shapeLayer.fillColor = #colorLiteral(red: 0.968627451, green: 0.9882352941, blue: 0.6235294118, alpha: 1)
        }
        
        shapeLayer.lineWidth = 1.0
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.path = createBezierPath().cgPath
        if (incomingTail) {
            shapeLayer.position = CGPoint(x: bounds.width + 1.2, y: bounds.height + 1.5)
        } else {
            shapeLayer.position = CGPoint(x: -1.2, y: -1.5)
        }
    }

    func createBezierPath() -> UIBezierPath {
        
        let border: CGFloat = 4;
        
        let width = bounds.width;//40
        let height = bounds.height;//29
        
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: 5, y: 8))
        shape.addLine(to: CGPoint(x: 5, y: height - border))
        shape.addCurve(to: CGPoint(x: 9, y: height), controlPoint1: CGPoint(x: 5, y: height - border/2), controlPoint2: CGPoint(x: 6.79, y: height))
        
        shape.addLine(to: CGPoint(x: width - border, y: height))
        shape.addCurve(to: CGPoint(x: width - border/2, y: height - border), controlPoint1: CGPoint(x: width - border, y: height), controlPoint2: CGPoint(x: width - border/2, y: height - border/2))
        
        shape.addLine(to: CGPoint(x: width - 2, y: height/2 + 2))
        shape.addLine(to: CGPoint(x: width + 4, y: height/2))
        shape.addLine(to: CGPoint(x: width - 2, y: height/2 - 2))
        shape.addLine(to: CGPoint(x: width - 2, y: 8))
        
        shape.addCurve(to: CGPoint(x: width - border, y: 4), controlPoint1: CGPoint(x: width - border/2, y: 6), controlPoint2: CGPoint(x: width - border, y: 4))
        shape.addLine(to: CGPoint(x: 9, y: 4))
        shape.addCurve(to: CGPoint(x: 5, y: 8), controlPoint1: CGPoint(x: 7, y: 4), controlPoint2: CGPoint(x: 5, y: 6))
        shape.close()
        
        return shape
    }

}
