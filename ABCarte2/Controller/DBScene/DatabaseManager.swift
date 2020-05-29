//
//  DatabaseManager.swift
//  ABCDB
//
//  Created by 福嶋伸之 on 2020/01/02.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

/// Handles database objects such as categories and their sub-items. Mainly used by DatabaseTableViewManager.1
class DatabaseManager<CategoryType:IsCategory, SubItemType:IsSubItem> {

    init(addsUnspecified:Bool, includesInactives:Bool) {
        self.addsUnspecified = addsUnspecified
        self.includesInactives = includesInactives
        allCategories = RealmServices.shared.realm.objects(CategoryType.self)
            .sorted(byKeyPath:CategoryType.propertyNameOfDisplayNum, ascending:true)
        items = RealmServices.shared.realm.objects(SubItemType.self)
            .sorted(byKeyPath:SubItemType.propertyNameOfDisplayNum, ascending:true)
        categories = CategoriesIncludingUnspecified(owner:self)

        // Clears category_id to 0 if lost items are.
        items.filter("\(SubItemType.propertyNameOfCategoryID) != 0").forEach { (item) in
            if item.findCategory(CategoryType.self) == nil {
                RealmServices.shared.update(item, with:[SubItemType.propertyNameOfCategoryID:0])
            }
        }
    }

    //MARK: - public properties
    var addsUnspecified:Bool
    var includesInactives:Bool
    var categoryToExcept:CategoryType? = nil
    var categories:CategoriesIncludingUnspecified!
    typealias CategoryInfo = (object:CategoryType?, title:String, subItems:Results<SubItemType>)
    struct CategoriesIncludingUnspecified {
        weak var owner:DatabaseManager!
        subscript(index:Int) -> CategoryInfo {
            if owner.addsUnspecified && index == 0 {
                return (
                    object   : nil,
                    title    : "指定なし",
                    subItems : owner.items.filter("\(SubItemType.propertyNameOfCategoryID) == 0") // 0 means category not specified
                )
            }
            else {
                let category = owner.filteredCategories[index - (owner.addsUnspecified ? 1 : 0)]
                return (
                    object   : category,
                    title    : category.titleForTable,
                    subItems : category.getSubItems(SubItemType.self)
                )
            }
        }
        var count:Int {
            return owner.filteredCategories.count + (owner.addsUnspecified ? 1 : 0)
        }
    }

    //MARK: - private properties
    private let allCategories:Results<CategoryType>
    private var filteredCategories:Results<CategoryType> {
        let categories:Results<CategoryType>
        if let categoryToExcept = categoryToExcept {
            categories = allCategories.filter("id != \(categoryToExcept.categoryID)")
        }
        else {
            categories = allCategories
        }
        if includesInactives {
            return categories
        }
        else {
            return categories.filter("status == 10")
        }
    }
    private let items:Results<SubItemType>

    //MARK: - functions
    /// Creates new Category or new SubItem.
    ///
    /// - Parameters:
    ///   - objectType: Determines the type what kind of object is created.
    ///   - nextTo: Specifies the place of new object to be placed. If it is nil, category is placed to the tail, sub-item is placed to the tail of category-not-specified section.
    /// - Returns: Created Object.
    func createNewObject(_ objectType:Object.Type, nextTo:IndexPath?=nil) -> Object {
        var newObject = objectType.init() as! (Object & CanMakeNewPrimaryKeyInt & HasPropertiesForTable)
        newObject.setNewPrimaryKeyInt()
        newObject.setNewDisplayNum()
        newObject.isActive = true
        return newObject
    }
    func insertCategory(_ object:CategoryType, at destIndex:Int) {
        if addsUnspecified == true || includesInactives == false || categoryToExcept != nil {
            fatalError("func insertCategory only can use when includesEmpty=false and includesInactives=true and categoryToExcept=nil")
        }
        filteredCategories.filter{$0 != object}.enumerated().forEach { (index, element) in
            let newIndex = index < destIndex ? index : index + 1
            RealmServices.shared.update(element, with:[CategoryType.propertyNameOfDisplayNum:newIndex])
        }
        RealmServices.shared.update(object, with:[CategoryType.propertyNameOfDisplayNum:destIndex])
        
        //API handler
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
                
        var ids = [Int]()
        var display_num = [Int]()
        for i in 0 ..< filteredCategories.count {
            ids.append(filteredCategories[i].categoryID)
            display_num.append(filteredCategories[i].displayNum! + 1)
        }
        
        if object.objectSchema.className == "ProductCategoryData" {
            APIRequest.onSwapProductCategory(ids: ids, display_num: display_num) { (success) in
                if success {
                    //success
                } else {
                    fatalError("swap error")
                }
                SVProgressHUD.dismiss()
            }
        } else if object.objectSchema.className == "CourseCategoryData" {
            APIRequest.onSwapCourseCategory(ids: ids, display_num: display_num) { (success) in
                if success {
                    //success
                } else {
                    fatalError("swap error")
                }
                SVProgressHUD.dismiss()
            }
        } else if object.objectSchema.className == "CompanyData" {
            APIRequest.onSwapCompanyCategory(ids: ids, display_num: display_num) { (success) in
                if success {
                    //success
                } else {
                    fatalError("swap error")
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    func insertSubItem(object:SubItemType, at destIndexPath:IndexPath, from sourceIndexPath:IndexPath,completion:@escaping(Bool) -> ()) {
        categories[destIndexPath.section].subItems.filter{$0 != object}.enumerated().forEach { (index, element) in
            let newIndex = index < destIndexPath.row ? index : index + 1
            RealmServices.shared.update(element, with:[SubItemType.propertyNameOfDisplayNum:newIndex])
        }
        let id = categories[destIndexPath.section].object?.categoryID ?? 0 // 0 means category not specified
        RealmServices.shared.update(object, with:[SubItemType.propertyNameOfDisplayNum:destIndexPath.row, SubItemType.propertyNameOfCategoryID:id])
        
        //API handler
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
                
        var idsNew = [Int]()
        var idsOld = [Int]()
        var display_num = [Int]()
        if object.objectSchema.className == "ProductData" {
            for i in 0 ..< categories[destIndexPath.section].subItems.count {
                let sub = categories[destIndexPath.section].subItems[i] as! ProductData
                idsNew.append(sub.id)
                display_num.append(i + 1)
            }
            
            for i in 0 ..< categories[sourceIndexPath.section].subItems.count {
                let sub = categories[sourceIndexPath.section].subItems[i] as! ProductData
                    idsOld.append(sub.id)
            }
            
            //check swap inside one category or not
            if destIndexPath.section == sourceIndexPath.section {
                APIRequest.onSwapProduct(type: 1, categoryID: id, ids: idsNew, oldids: idsOld, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                APIRequest.onSwapProduct(type: 2, categoryID: id, ids: idsNew, oldids: idsOld, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else if object.objectSchema.className == "CourseData" {
            for i in 0 ..< categories[destIndexPath.section].subItems.count {
                let sub = categories[destIndexPath.section].subItems[i] as! CourseData
                idsNew.append(sub.id)
                display_num.append(i + 1)
            }
            
            for i in 0 ..< categories[sourceIndexPath.section].subItems.count {
                let sub = categories[sourceIndexPath.section].subItems[i] as! CourseData
                idsOld.append(sub.id)
            }
            
            //check swap inside one category or not
            if destIndexPath.section == sourceIndexPath.section {
                APIRequest.onSwapCourse(type: 1, categoryID: id, ids: idsNew, oldids: idsOld, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                APIRequest.onSwapCourse(type: 2, categoryID: id, ids: idsNew, oldids: idsOld, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else if object.objectSchema.className == "StaffData" {
            for i in 0 ..< categories[destIndexPath.section].subItems.count {
                let sub = categories[destIndexPath.section].subItems[i] as! StaffData
                idsNew.append(sub.id)
                display_num.append(i + 1)
            }
            
            for i in 0 ..< categories[sourceIndexPath.section].subItems.count {
                let sub = categories[sourceIndexPath.section].subItems[i] as! StaffData
                    idsOld.append(sub.id)
            }
            
            //check swap inside one category or not
            if destIndexPath.section == sourceIndexPath.section {
                APIRequest.onSwapStaff(ids: idsNew, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                APIRequest.onSwapStaffBetweenCompany(companyCategoryID: id, ids: idsNew, oldids: idsOld, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else if object.objectSchema.className == "BedData" {
            for i in 0 ..< categories[destIndexPath.section].subItems.count {
                let sub = categories[destIndexPath.section].subItems[i] as! BedData
                idsNew.append(sub.id)
                display_num.append(i + 1)
            }
            
            for i in 0 ..< categories[sourceIndexPath.section].subItems.count {
                let sub = categories[sourceIndexPath.section].subItems[i] as! BedData
                    idsOld.append(sub.id)
            }
            
            //check swap inside one category or not
            if destIndexPath.section == sourceIndexPath.section {
                APIRequest.onSwapBed(ids: idsNew, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else if object.objectSchema.className == "PaymentData" {
            for i in 0 ..< categories[destIndexPath.section].subItems.count {
                let sub = categories[destIndexPath.section].subItems[i] as! PaymentData
                idsNew.append(sub.dbID)
                display_num.append(i + 1)
            }
            
            for i in 0 ..< categories[sourceIndexPath.section].subItems.count {
                let sub = categories[sourceIndexPath.section].subItems[i] as! PaymentData
                    idsOld.append(sub.dbID)
            }
            
            var link = ""
            if sourceIndexPath.section == 1 {
                link = kAPI_CREDIT
            } else if sourceIndexPath.section == 2 {
                link = kAPI_SHOPPINGCREDIT
            } else if sourceIndexPath.section == 3 {
                link = kAPI_EMONEY
            }
            
            //check swap inside one category or not
            if destIndexPath.section == sourceIndexPath.section {
                APIRequest.onSwapPayment(ids: idsNew, display_num: display_num, link: link) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else if object.objectSchema.className == "JobData" {
            for i in 0 ..< categories[destIndexPath.section].subItems.count {
                let sub = categories[destIndexPath.section].subItems[i] as! JobData
                idsNew.append(sub.id)
                display_num.append(i + 1)
            }
            
            for i in 0 ..< categories[sourceIndexPath.section].subItems.count {
                let sub = categories[sourceIndexPath.section].subItems[i] as! JobData
                    idsOld.append(sub.id)
            }
            
            //check swap inside one category or not
            if destIndexPath.section == sourceIndexPath.section {
                APIRequest.onSwapJob(ids: idsNew, display_num: display_num) { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    func appendSubItems(_ items:Results<SubItemType>, at destIndex:Int) {
        let category = categories[destIndex]
        let lastNum = category.subItems.last?.displayNum ?? 0
        items.enumerated().forEach{ (index, item) in
            if category.object?.objectSchema.className == "ProductCategoryData" {
                let values = [
                    ProductData.propertyNameOfCategoryID   : category.object?.categoryID ?? 0,
                    ProductData.propertyNameOfDisplayNum : lastNum + 1 + index
                ]
                RealmServices.shared.update(item, with:values)
            } else if category.object?.objectSchema.className == "CourseCategoryData" {
                let values = [
                    CourseData.propertyNameOfCategoryID   : category.object?.categoryID ?? 0,
                    CourseData.propertyNameOfDisplayNum : lastNum + 1 + index
                ]
                RealmServices.shared.update(item, with:values)
            } else if category.object?.objectSchema.className == "CompanyData" {
                let values = [
                    StaffData.propertyNameOfCategoryID   : category.object?.categoryID ?? 0,
                    StaffData.propertyNameOfDisplayNum : lastNum + 1 + index
                ]
                RealmServices.shared.update(item, with:values)
            } else if category.object?.objectSchema.className == "RoomData" {
                let values = [
                    BedData.propertyNameOfCategoryID   : category.object?.categoryID ?? 0,
                    BedData.propertyNameOfDisplayNum : lastNum + 1 + index
                ]
                RealmServices.shared.update(item, with:values)
            } else if category.object?.objectSchema.className == "PaymentCategoryData" {
                let values = [
                    PaymentData.propertyNameOfCategoryID   : category.object?.categoryID ?? 0,
                    PaymentData.propertyNameOfDisplayNum : lastNum + 1 + index
                ]
                RealmServices.shared.update(item, with:values)
            }
        }
    }
    func subItem(for indexPath:IndexPath?) -> SubItemType? {
        guard let indexPath = indexPath else { return nil }
        return categories[indexPath.section].subItems[indexPath.row]
    }
    func index(category:CategoryType) -> Int? {
        if let categoryIndex = filteredCategories.index(of:category) {
            return categoryIndex + (addsUnspecified ? 1 : 0)
        }
        else {
            return 0
        }
    }
    func indexPath(subItem:SubItemType) -> IndexPath? {
        let section:Int
        if let category = subItem.findCategory(CategoryType.self), let categoryIndex = filteredCategories.index(of:category) {
            section = categoryIndex + (addsUnspecified ? 1 : 0)
        }
        else { // category not specified
            section = 0
        }
        guard let row = categories[section].subItems.index(of:subItem) else { return nil }
        return IndexPath(row:row, section:section)
    }
}
