//
//  DatabaseProtocols.swift
//  ABCDB
//
//  Created by 福嶋伸之 on 2020/01/01.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

// Various of protocols and protocol extensions. Adds some constrains and functions to Database models and view controller.

//MARK: - Automatically make and set a new Int Primary Key by increasing exists maximum.
protocol CanMakeNewPrimaryKeyInt {
    func setNewPrimaryKeyInt()
}
extension CanMakeNewPrimaryKeyInt where Self:Object {
    func setNewPrimaryKeyInt() {
        guard let key = Self.primaryKey() else { fatalError() }
        let lastID = RealmServices.shared.realm.objects(Self.self)
            .sorted(byKeyPath:key, ascending:false).first?[key] as? Int ?? 0
        setValue(lastID + 1, forKeyPath:key)
    }
}

//MARK: - To handle of different properties about name and num of multiple models in a unified way.
protocol HasPropertiesForTable {
    //MARK: Property Names
    static var propertyNameOfTitle:String { get }
    static var propertyNameOfDisplayNum:String { get }
    //MARK: Unified Properties
    var titleForTable:String { get }
    var displayNum:Int? { get }
    func setNewDisplayNum()
    var isActive:Bool { get set }
}
extension HasPropertiesForTable where Self:Object {
    //MARK: Property Names
    static var propertyNameOfTitle:String {
        return ["category_name","staff_name","course_name","item_name","company_name","bed_name","credit_company","job"]
            .filter{instancesRespond(to:Selector($0))}.first ?? ""
    }
    static var propertyNameOfDisplayNum:String {
        return ["display_num","account_id"]
            .filter{instancesRespond(to:Selector($0))}.first ?? ""
    }

    var titleForTable:String {
        let title = value(forKeyPath:Self.propertyNameOfTitle) as? String
        return title != nil && title != "" ? title! : "（名称未設定）"
    }
    var displayNum:Int? {
        return value(forKeyPath:Self.propertyNameOfDisplayNum) as? Int
    }
    func setNewDisplayNum() {
        let key = Self.propertyNameOfDisplayNum
        let lastNum = RealmServices.shared.realm.objects(Self.self)
            .sorted(byKeyPath:key, ascending:false).first?[key] as? Int ?? 0
        setValue(lastNum + 1, forKeyPath:key)
    }
    var isActive:Bool {
        get {
            return (value(forKeyPath:"status") as? Int ?? 0) == 10
        }
        set {
            RealmServices.shared.update(self, with:["status":newValue ? 10 : 0])
        }
    }
}

//MARK: - To let function know that this object's updated field should be updated.
protocol DateShouldBeUpdated {
    static var propertyNameOfUpdated:String { get }
    func updateUpdated()
}
extension DateShouldBeUpdated where Self:Object {
    static var propertyNameOfUpdated:String {
        return "updated_at"
    }
    func updateUpdated() {
        // Because it might be used in the RealmServices.update method, it is using setValue without using the update method.
//        do {
//            try RealmServices.shared.realm.write {
//                self.setValue(Date(), forKey:Self.propertyNameOfUpdated)
//            }
//        } catch {
//            print(error)
//        }
    }
}

//MARK: - Adds property to CourseCategoryData, ProductCategoryData and CompanyData.
protocol IsCategory:Object, CanMakeNewPrimaryKeyInt, HasPropertiesForTable, DateShouldBeUpdated {
    var categoryID:Int { get }
    func getSubItems<T:IsSubItem>(_ type:T.Type) -> Results<T>
}
extension IsCategory where Self:Object & CanMakeNewPrimaryKeyInt & HasPropertiesForTable {
    var categoryID:Int {
        return value(forKeyPath:"id") as? Int ?? 0
    }
    func getSubItems<T:IsSubItem>(_ type:T.Type) -> Results<T> {
        return RealmServices.shared.realm.objects(T.self)
            .filter("\(T.propertyNameOfCategoryID) == \(categoryID)")
            .sorted(byKeyPath:T.propertyNameOfDisplayNum, ascending:true)
    }
}
//MARK: - Adds property to CourseData, ProductData and StaffData.
protocol IsSubItem:Object, CanMakeNewPrimaryKeyInt, HasPropertiesForTable, DateShouldBeUpdated {
    static var propertyNameOfCategoryID:String { get }
    func findCategory<T:IsCategory>(_ type:T.Type) -> T?
}
extension IsSubItem where Self:Object & HasPropertiesForTable {
    static var propertyNameOfCategoryID:String {
        return ["category_id","company_id","account_id"]
        .filter{instancesRespond(to:Selector($0))}.first ?? ""
    }
    func findCategory<T:IsCategory>(_ type:T.Type) -> T? {
        return RealmServices.shared.realm.objects(T.self)
            .filter("id == \(value(forKey:Self.propertyNameOfCategoryID) ?? 0)").first
    }
}



//MARK: - protocols for DatabaseVC

//TableView for listing database objects must comform to this protocol.
protocol CanHandleDatabaseObjectsList:NSObject, UITableViewDataSource, UITableViewDelegate {
    var onSelectionChanged:((Object?)->())? { get set }
    var onMoveRowComplete:(()->())? { get set }
    var onMoveRowNotAllowed:(()->())? { get set }
    func indexPath(for object:Object) -> IndexPath?
    func createNew(_ objectType:Object.Type, nextTo:IndexPath?) -> Object
}

// ViewControllers for editing database category or item must comform to this protocol.
protocol CanEditDatabaseObject:UIViewController {
    var onReloadData:(()->())? { get set }
    var onEditingBegan:(()->())? { get set }
    var onEditingEnded:((Object?)->())? { get set }
    var currentObject:Object? { get set }
    var isNewObject:Bool { get set }
}

// ViewController
protocol CanAdjustToKeyboardAppearing:NSObjectProtocol {
    func attachKeyboardObserver(additionalFuncForShowing:((_ notification:Notification?)->())?, additionalFuncForHiding:((_ notification:Notification?)->())?)
//    func detachKeyboardObserver() // Not required for iOS9 or later.
    func adjustContainerViewForKeyboard(_ notification:Notification?)
}
extension CanAdjustToKeyboardAppearing where Self:UIViewController {
    func attachKeyboardObserver(additionalFuncForShowing:((_ notification:Notification?)->())?, additionalFuncForHiding:((_ notification:Notification?)->())?) {
        let notification = NotificationCenter.default
        notification.addObserver(forName:UIResponder.keyboardWillChangeFrameNotification, object:nil, queue:.main, using:adjustContainerViewForKeyboard(_:))
        if let additionalFuncForShowing = additionalFuncForShowing {
            notification.addObserver(forName:UIResponder.keyboardWillChangeFrameNotification, object:nil, queue:.main, using:additionalFuncForShowing)
        }
    }
    func adjustContainerViewForKeyboard(_ notification:Notification?) {
        guard let superview = view.superview else { return }
        let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        let height:CGFloat
        if
            let rect = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            rect.origin.y + rect.size.height >= superview.bounds.size.height
        {
            height = rect.origin.y
        }
        else {
            height = superview.bounds.size.height
        }
        UIView.animate(withDuration:duration) {
            self.view.bounds.size.height = height
            self.view.frame.origin.y = 0
        }
    }
}
