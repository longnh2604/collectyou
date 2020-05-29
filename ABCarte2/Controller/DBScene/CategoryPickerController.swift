//
//  CategoryPickerController.swift
//  ABCDB
//
//  Created by 福嶋伸之 on 2020/01/02.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

// Picker's datasource and delegate. Specially for Course Category.

class CategoryPickerController:UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate {

    var dbmCourse = DatabaseManager<CourseCategoryData, CourseData>(addsUnspecified:false, includesInactives:true)
    var dbmProduct = DatabaseManager<ProductCategoryData, ProductData>(addsUnspecified:false, includesInactives:true)
    var dbmStaff = DatabaseManager<CompanyData, StaffData>(addsUnspecified:false, includesInactives:true)
    var dbmPayment = DatabaseManager<PaymentCategoryData, PaymentData>(addsUnspecified:false, includesInactives:true)
    var initialSelectedCourseCategory:CourseCategoryData?
    var initialSelectedProductCategory:ProductCategoryData?
    var initialSelectedCompanyCategory:CompanyData?
    var initialSelectedPaymentCategory:PaymentCategoryData?

    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.dataSource = self
            pickerView.delegate = self
            if let initialSelectedCourseCategory = initialSelectedCourseCategory {
                if let row = dbmCourse.index(category:initialSelectedCourseCategory) {
                    pickerView.selectRow(row, inComponent:0, animated:false)
                }
            }
            if let initialSelectedProductCategory = initialSelectedProductCategory {
                if let row = dbmProduct.index(category:initialSelectedProductCategory) {
                    pickerView.selectRow(row, inComponent:0, animated:false)
                }
            }
            if let initialSelectedCompanyCategory = initialSelectedCompanyCategory {
                if let row = dbmStaff.index(category:initialSelectedCompanyCategory) {
                    pickerView.selectRow(row, inComponent:0, animated:false)
                }
            }
            if let initialSelectedPaymentCategory = initialSelectedPaymentCategory {
                if let row = dbmPayment.index(category:initialSelectedPaymentCategory) {
                    pickerView.selectRow(row, inComponent:0, animated:false)
                }
            }
        }
    }
    var categoryToExcept:IsCategory? = nil
    var type: Int?
    var onSelectionCourseChanged:((DatabaseManager<CourseCategoryData, CourseData>.CategoryInfo?)->())?
    var onSelectionProductChanged:((DatabaseManager<ProductCategoryData, ProductData>.CategoryInfo?)->())?
    var onSelectionCompanyChanged:((DatabaseManager<CompanyData, StaffData>.CategoryInfo?)->())?
    var onSelectionPaymentChanged:((DatabaseManager<PaymentCategoryData, PaymentData>.CategoryInfo?)->())?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if type == 1 {
            return dbmCourse.categories.count
        } else if type == 2 {
            return dbmProduct.categories.count
        } else if type == 3 {
            return dbmStaff.categories.count
        } else {
            return dbmPayment.categories.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if type == 1 {
            return dbmCourse.categories[row].title
        } else if type == 2 {
            return dbmProduct.categories[row].title
        } else if type == 3 {
            return dbmStaff.categories[row].title
        } else {
            return dbmPayment.categories[row].title
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if type == 1 {
            onSelectionCourseChanged?(dbmCourse.categories[row])
        } else if type == 2 {
            onSelectionProductChanged?(dbmProduct.categories[row])
        } else if type == 3 {
            onSelectionCompanyChanged?(dbmStaff.categories[row])
        } else {
            onSelectionPaymentChanged?(dbmPayment.categories[row])
        }
    }
}
