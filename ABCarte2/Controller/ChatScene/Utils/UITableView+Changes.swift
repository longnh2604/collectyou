//
//  UITableView+Changes.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import YapDatabase

extension UITableView: ChangesPresenter {
    
    func changeReceive(changes: [YapDatabaseViewRowChange]) {
        UIView.performWithoutAnimation {
            self.beginUpdates()
            changes.forEach{
                switch $0.type {
                case .insert:
                    self.insertRows(at: [$0.newIndexPath!], with: .none)
                case .delete:
                    self.deleteRows(at: [$0.indexPath!], with: .none)
                case .move:
                    self.deleteRows(at: [$0.indexPath!], with: .none)
                    self.insertRows(at: [$0.newIndexPath!], with: .none)
                case .update:
                    self.reloadRows(at: [$0.indexPath!], with: .none)
                }
            }
            self.endUpdates()
        }
    }
}
