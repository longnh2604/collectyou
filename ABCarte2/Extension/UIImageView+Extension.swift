//
//  UIImageView+Extension.swift
//  ABCarte2
//
//  Created by long nguyen on 6/26/19.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation

public extension UIImageView {
    
    //*****************************************************************
    // MARK: - UIImageView Handler
    //*****************************************************************
    
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func alphaAtPoint(_ point: CGPoint) -> CGFloat {
        
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let alphaInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: alphaInfo) else {
            return 0
        }
        
        context.translateBy(x: -point.x, y: -point.y);
        
        layer.render(in: context)
        
        let floatAlpha = CGFloat(pixel[3])
        
        return floatAlpha
    }
}

public func roundImage(with Image: UIImageView) {
    Image.contentMode = UIView.ContentMode.scaleAspectFill
    Image.layer.borderWidth = 1.0
    Image.layer.masksToBounds = false
    Image.layer.borderColor = UIColor.white.cgColor
    Image.layer.cornerRadius = (Image.frame.width)/2
    Image.clipsToBounds = true
}
