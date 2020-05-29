//
//  UserImage.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import Foundation
import PINCache
import PINRemoteImage
import LetterAvatarKit

extension UIImageView {
    
    /// Set placeholder / Download / Crop with self size
    ///
    /// - Parameters:
    ///   - url: image url
    ///   - title: Placholder title
    func setImage(from url: String?, title: String) {
        //Configure letter avatar
        if url != nil && url != "" {
            let targetSize = CGSize(width: 40, height: 40)
            let processorKey = "resized_\(targetSize.width)x\(targetSize.height)"
            self.pin_setImage(from: URL(string: url ?? ""), placeholderImage: nil, processorKey: processorKey) { (result, unsafePointer) -> UIImage? in
                guard let image = result.image else { return nil }
                return image.resizedImage(newSize: targetSize)
            }
        } else {
            let placeholder = letterPlaceholder(forTitle: title, size: Int(self.frame.size.height))
            let targetSize = self.frame.size
            let processorKey = "resized_\(targetSize.width)x\(targetSize.height)"
            self.pin_setImage(from: URL(string: url ?? ""), placeholderImage: placeholder, processorKey: processorKey) { (result, unsafePointer) -> UIImage? in
                 guard let image = result.image else { return nil }
                return image.resizedImage(newSize: targetSize)
            }
        }
    }
    
    private func letterPlaceholder(forTitle title: String, size: Int = 40) -> UIImage {
        let key = "\(size)_\(title.hashValue)"
        if let image = PINRemoteImageManager.shared().cache.object(forKey: key) as? UIImage {
            return image
        }
        else {
            //Configure
            let configuration = LetterAvatarBuilderConfiguration()
            configuration.size = CGSize(width: size, height: size)
            configuration.username = title
            //Make placeholder
            let placehodler = UIImage.makeLetterAvatar(withConfiguration: configuration)!
            PINRemoteImageManager.shared().cache.setObject(placehodler, forKey: key)
            return placehodler
        }
    }
}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        let resizeFactor = size.height > size.width ? heightFactor : widthFactor
        let newSize = CGSize(width: size.width / resizeFactor, height: size.height / resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
}
