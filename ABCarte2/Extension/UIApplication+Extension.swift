//
//  UIApplication+Extension.swift
//  ABCarte2
//
//  Created by long nguyen on 6/26/19.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation

public extension UIApplication {
    //open web url
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
    
    func topSafeAreaMargin() -> CGFloat {
        var topMargin: CGFloat = 0
        if #available(iOS 11.0, *), let topInset = keyWindow?.safeAreaInsets.top {
            topMargin = topInset
        }
        
        return topMargin
    }
    
    func bottomSafeAreaMargin() -> CGFloat {
        var bottomMargin: CGFloat = 0
        if #available(iOS 11.0, *), let bottomInset = keyWindow?.safeAreaInsets.bottom {
            bottomMargin = bottomInset
        }
        
        return bottomMargin
    }
    
    func leftSafeAreaMargin() -> CGFloat {
        var leftMargin: CGFloat = 0
        if #available(iOS 11.0, *), let leftInset = keyWindow?.safeAreaInsets.left {
            leftMargin = leftInset
        }
        
        return leftMargin
    }
    
    func rightSafeAreaMargin() -> CGFloat {
        var rightMargin: CGFloat = 0
        if #available(iOS 11.0, *), let rightInset = keyWindow?.safeAreaInsets.right {
            rightMargin = rightInset
        }
        
        return rightMargin
    }
    
    func safeAreaSideMargin() -> CGFloat {
        return leftSafeAreaMargin() + rightSafeAreaMargin()
    }
}
