//
//  UINavigation+Extension.swift
//  ABCarte2
//
//  Created by long nguyen on 6/26/19.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation

public extension UINavigationBar
{
    //*****************************************************************
    // MARK: - Gradient Navigation
    //*****************************************************************
    
    /// Applies a background gradient with the given colors
    func apply(gradient colors : [UIColor]) {
        var frameAndStatusBar: CGRect = self.bounds
        frameAndStatusBar.size.height += 25 // add 20 to account for the status bar
        
        setBackgroundImage(UINavigationBar.gradient(size: frameAndStatusBar.size, colors: colors), for: .default)
    }
    
    /// Creates a gradient image with the given settings
    static func gradient(size : CGSize, colors : [UIColor]) -> UIImage?
    {
        // Turn the colors into CGColors
        let cgcolors = colors.map { $0.cgColor }
        
        // Begin the graphics context
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        // If no context was retrieved, then it failed
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // From now on, the context gets ended if any return happens
        defer { UIGraphicsEndImageContext() }
        
        // Create the Coregraphics gradient
        var locations : [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgcolors as NSArray as CFArray, locations: &locations) else { return nil }
        
        // Draw the gradient
        context.drawLinearGradient(gradient, start: CGPoint(x: size.width/2, y: 0.0), end: CGPoint(x: size.width/2, y: size.height), options: [])
        
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public func addNavigationBarColor(navigation: UINavigationController,type:Int) {
    switch type {
    case AppColorSet.standard.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET000.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET000.kHEADER_BACKGROUND_COLOR_DOWN])
    case AppColorSet.jbsattender.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET001.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET001.kHEADER_BACKGROUND_COLOR_DOWN])
    case AppColorSet.romanpink.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET002.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET002.kHEADER_BACKGROUND_COLOR_DOWN])
    case AppColorSet.hisul.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET003.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET003.kHEADER_BACKGROUND_COLOR_DOWN])
    case AppColorSet.lavender.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET004.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET004.kHEADER_BACKGROUND_COLOR_DOWN])
    case AppColorSet.pinkgold.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET005.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET005.kHEADER_BACKGROUND_COLOR_DOWN])
    case AppColorSet.mysteriousnight.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET006.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET006.kHEADER_BACKGROUND_COLOR_DOWN])
    case AppColorSet.gardenparty.rawValue:
        navigation.navigationBar.apply(gradient: [COLOR_SET007.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET007.kHEADER_BACKGROUND_COLOR_DOWN])
    default:
        navigation.navigationBar.apply(gradient: [COLOR_SET000.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET000.kHEADER_BACKGROUND_COLOR_DOWN])
    }
}
