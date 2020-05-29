//
//  TableController.swift
//  ABCDB
//
//  Created by 福嶋伸之 on 2019/12/28.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

// This file inclueds two table view controller ( datasource & delegate ). First one is for editing category, another one is for editing items.
// Both two are using same Categories instance which provides a convenient way to handle categories and items.

//MARK: - Tableview datasource and delegate used for category editing.
class DatabaseCategoryTableManager<CategoryType:IsCategory, SubItemType:IsSubItem>:NSObject, CanHandleDatabaseObjectsList {
    
    //MARK: - properties
    var dbm = DatabaseManager<CategoryType, SubItemType>(addsUnspecified:false, includesInactives:true)
    var onSelectionChanged:((Object?) -> ())?
    var onMoveRowComplete: (() -> ())?
    var onMoveRowNotAllowed: (() -> ())?
    //MARK: - lifecycle

    //MARK: - table Showing
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbm.categories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"CategoryCell", for:indexPath)
        let category = dbm.categories[indexPath.row]
        cell.textLabel?.text = category.title
        cell.textLabel?.textColor = (category.object?.isActive ?? false) ? .darkText : .lightGray
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectionChanged?(dbm.categories[indexPath.row].object)
    }

    //MARK: - table Editing
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let object = dbm.categories[sourceIndexPath.row].object else { return }
        dbm.insertCategory(object, at:destinationIndexPath.row)
    }

    //MARK: - other functions
    func indexPath(for object:Object) -> IndexPath? {
        guard let object = object as? CategoryType else { return nil }
        guard let row = dbm.index(category:object) else { return nil }
        return IndexPath(row:row, section:0)
    }
    func createNew(_ objectType: Object.Type, nextTo:IndexPath?) -> Object {
        return dbm.createNewObject(objectType, nextTo:nextTo)
    }
}



//MARK: - Tableview datasource and delegate used for item editing. Can handle parent categories, including "category not specified".
class DatabaseItemTableManager<CategoryType:IsCategory, SubItemType:IsSubItem>:NSObject, CanHandleDatabaseObjectsList {
    
    //MARK: - properties
    var dbm = DatabaseManager<CategoryType, SubItemType>(addsUnspecified:true, includesInactives:false)
    var onSelectionChanged:((Object?) -> ())?
    var onMoveRowComplete: (() -> ())?
    var onMoveRowNotAllowed: (() -> ())?
    //MARK: - lifecycle

    //MARK: - table Showing
    func numberOfSections(in tableView: UITableView) -> Int {
        return dbm.categories.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbm.categories[section].subItems.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if CategoryType.className() == "RoomData" || CategoryType.className() == "JobCategoryData" {
            return nil
        }
        if section == 0 && dbm.categories[0].subItems.count == 0 {
            return nil
        }
        else {
            return dbm.categories[section].title
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ItemCell", for:indexPath)
        let object = dbm.categories[indexPath.section].subItems[indexPath.row]
        cell.textLabel?.text = object.titleForTable
        cell.textLabel?.textColor = object.isActive ? .darkText : .lightGray
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectionChanged?(dbm.categories[indexPath.section].subItems[indexPath.row])
    }

    //MARK: - table Editing
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movingObject = dbm.categories[sourceIndexPath.section].subItems[sourceIndexPath.row]
        dbm.insertSubItem(object: movingObject, at: destinationIndexPath, from: sourceIndexPath) { (success) in
            if success {
                self.onMoveRowComplete?()
            }
        }
    }
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if CategoryType.className() == "PaymentCategoryData" {
            if sourceIndexPath.section != proposedDestinationIndexPath.section {
                self.onMoveRowNotAllowed?()
                return sourceIndexPath
            }
        }
        return proposedDestinationIndexPath
    }

    //MARK: - functions
    func indexPath(for object:Object) -> IndexPath? {
        guard let object = object as? SubItemType else { return nil }
        return dbm.indexPath(subItem:object)
    }
    func createNew(_ objectType: Object.Type, nextTo:IndexPath?) -> Object {
        return dbm.createNewObject(objectType, nextTo:nextTo)
    }
}
