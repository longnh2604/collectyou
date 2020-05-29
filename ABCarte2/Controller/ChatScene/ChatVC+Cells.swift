//
//  ChatVC+Cells.swift
//  ABCarte2
//
//  Created by Long on 2019/07/08.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import ConnectyCube

extension ChatVC {
    
    //MARK: - Register cells
    
    /// Register cells
    func registerCells() {
        tableView!.register(cellType: TextMessageCell.self)
        tableView!.register(cellType: TextLeftMessageCell.self)
        tableView!.register(cellType: ImageMessageCell.self)
        tableView!.register(cellType: ImageLeftTableViewCell.self)
    }
    
    //MARK: - Cell configuration
    
    /// Cell for row at indexPath
    ///
    /// - Parameter indexPath: Index path
    /// - Returns: Configured UITableViewCell instance
    func configureCell(withMessage message: ChatMessage, indexPath: IndexPath, id:UInt,avatar:String) -> UITableViewCell {
        var cell: TextMessageCell! = nil
        switch message.type() {
        case .text:
            cell = textCell(forRowAt: indexPath, message: message,id:id)
        case .png:
            cell = imageCell(forRowAt: indexPath, message: message,id:id)
        case .jpg:
            cell = imageCell(forRowAt: indexPath, message: message,id:id)
        case .jpeg:
            cell = imageCell(forRowAt: indexPath, message: message,id:id)
        case .mpg4:
            cell = imageCell(forRowAt: indexPath, message: message,id:id)
        case .gif:
            cell = imageCell(forRowAt: indexPath, message: message,id:id)
        }
        
        /// Base configuration
        cell.transform = tableView!.transform
        let sender: User? = Cache.users.object(forKey: ("\(message.senderID)"))
        cell.setTitle(title:sender?.fullName ?? "Unknown", imageUrl: sender?.avatar)
        cell.setText(text: message.text, dateSent: message.dateSent!, status: message.status)
        ChatApp.messages.readMessage(message)
        return cell!
    }
    
    func textCell(forRowAt indexPath: IndexPath, message: ChatMessage,id:UInt) -> TextMessageCell {
        
        if message.senderID == id
        {
            return tableView!.dequeueReusableCell(for: indexPath, cellType: TextLeftMessageCell.self)
        }
        return tableView!.dequeueReusableCell(for: indexPath, cellType: TextMessageCell.self)
    }
    
    func imageCell(forRowAt indexPath: IndexPath, message: ChatMessage,id:UInt) -> TextMessageCell {
        
        if message.senderID == id
        {
            let cell = tableView!.dequeueReusableCell(for: indexPath, cellType: ImageLeftTableViewCell.self)
            cell.previewImage(withUrl: message.attachments!.first!.url!)
            return cell
        }
        let cell = tableView!.dequeueReusableCell(for: indexPath, cellType: ImageMessageCell.self)
        cell.previewImage(withUrl: message.attachments!.first!.url!)
        return cell
    }
}
