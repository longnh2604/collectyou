//
//  BaseCell.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import LetterAvatarKit
import PINRemoteImage
import PINCache
import Reusable

protocol PressDelegate: class {
    func didLongPress(_ cell: BaseCell)
    func didLinkPress(url:String)
    func didPhonePress(no:String)
}

/// Base class for the Chat cells

class BaseCell: UITableViewCell, NibReusable {
    
    //    ///Incoming Tail Bubble
    //    lazy var incomingTailImage: UIImage = {
    //        let image = #imageLiteral(resourceName: "Incoming Tail Bubble")
    //        let resizableImage = image.resizableImage(
    //            withCapInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10),
    //            resizingMode: .stretch
    //        )
    //        return resizableImage
    //    }()
    //
    //    lazy var outgoingTailImage: UIImage = {
    //        let image = #imageLiteral(resourceName: "Outgoing Tail Bubble")
    //        let resizableImage = image.resizableImage(
    //            withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20),
    //            resizingMode: .stretch
    //        )
    //        return resizableImage
    //    }()
    
    /// Letter image view
    @IBOutlet weak var letterImageView: UIImageView!
    
    /// Title lable
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Backgroud Image
    @IBOutlet weak var backgroundImageView: BaseImageView!
    
    weak var pressDelegate: PressDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        letterImageView.layer.cornerRadius = letterImageView.frame.size.width / 2
        letterImageView.clipsToBounds = true
        letterImageView.layer.drawsAsynchronously = true
        
        setupLongPressGesture()
    }
    
    func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.55 // 1 second press
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        guard gestureRecognizer.state == .began,
            let delegate = self.pressDelegate else {
                return
        }
        delegate.didLongPress(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        letterImageView.image = nil
    }
    
    // MARK: - Set cell data
    
    /// Set title and image for cell
    ///
    /// - Parameters:
    ///   - title: Title text
    ///   - imageUrl: Image url
    public func setTitle(title: String?, imageUrl: String?) {
        if let title = title {
            titleLabel?.text = title
            letterImageView.setImage(from: imageUrl, title: title)
        } else {
            letterImageView.setImage(from: imageUrl, title: "")
        }
    }
}
