//
//  ContractCategoryPopup.swift
//  ABCarte2
//
//  Created by Long on 2019/10/09.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

protocol ContractCategoryPopupDelegate: class {
    func onSelectContractServices(index:Int,course:CourseData)
    func onSelectProductRelated(index:Int,course:ProductData)
}

class ContractCategoryPopup: UIViewController {

    //IBOutlet
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var lblCourseTitle: UILabel!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnProduct: UIButton!
    
    //Variable
    weak var delegate:ContractCategoryPopupDelegate?
    var type: Int?
    var account = AccountData()
    let category = DropDown()
    let product = DropDown()
    var courseCategory: Results<CourseCategoryData>!
    var courses: Results<CourseData>!
    var productsCategory: Results<ProductCategoryData>!
    var products: Results<ProductData>!
    var categoryIndex: Int?
    var productIndex: Int?
    var cellIndex: Int?
    
    deinit {
        print("Release Memory")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    fileprivate func setupLayout() {
        switch type {
        case 1:
            lblCategoryTitle.text = "カテゴリを選択して下さい"
            lblCourseTitle.text = "コースを選択して下さい"
        case 2:
            lblCategoryTitle.text = "カテゴリを選択して下さい"
            lblCourseTitle.text = "商品を選択して下さい"
        default:
            break
        }
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        
        switch type {
        case 1:
            let realm = RealmServices.shared.realm
            try! realm.write {
                realm.delete(realm.objects(CourseCategoryData.self))
            }
            
            APIRequest.onGetAllCourseCategory(accID: account.id) { (success) in
                if success {
                    
                    var categoryArr = [String]()
                    self.courseCategory = realm.objects(CourseCategoryData.self).sorted(byKeyPath: "display_num")
                    for i in 0 ..< self.courseCategory.count {
                        categoryArr.append(self.courseCategory[i].category_name)
                    }
                    
                    self.category.anchorView = self.btnCategory
                    self.category.bottomOffset = CGPoint(x: 0, y: self.btnCategory.bounds.height)
                    self.category.dataSource = categoryArr
                    
                    self.category.selectionAction = { [weak self] (index, item) in
                        SVProgressHUD.show(withStatus: "読み込み中")
                        if let categoryID = self?.courseCategory[index].id {
                            try! realm.write {
                                realm.delete(realm.objects(CourseData.self))
                            }
                            
                            APIRequest.onGetAllCourse(category_id: categoryID){ (success) in
                                if success {
                                    self!.btnCategory.setTitle(item, for: .normal)
                                    self?.btnProduct.setTitle("選択してください", for: .normal)
                                    self?.productIndex = nil
                                    self?.categoryIndex = index
                                    
                                    var productArr = [String]()
                                    self?.courses = realm.objects(CourseData.self).sorted(byKeyPath: "display_num")
                                    for i in 0 ..< self!.courses.count {
                                        productArr.append((self?.courses[i].course_name)!)
                                    }
                                    
                                    self?.product.anchorView = self?.btnProduct
                                    self?.product.bottomOffset = CGPoint(x: 0, y: (self?.btnProduct.bounds.height)!)
                                    self?.product.dataSource = productArr
                                    
                                    self?.product.selectionAction = { [weak self] (index, item) in
                                        self?.btnProduct.setTitle(item, for: .normal)
                                        self?.productIndex = index
                                    }
                                } else {
                                    Utils.showAlert(message: "Can not get course", view: self!)
                                }
                                SVProgressHUD.dismiss()
                            }
                        }
                        
                    }
                } else {
                    Utils.showAlert(message: "Can not get course category", view: self)
                }
                SVProgressHUD.dismiss()
            }
        case 2:
            let realm = RealmServices.shared.realm
            try! realm.write {
                realm.delete(realm.objects(ProductCategoryData.self))
            }
            
            APIRequest.onGetAllProductCategory(accID: account.id) { (success) in
                if success {
                    
                    var categoryArr = [String]()
                    self.productsCategory = realm.objects(ProductCategoryData.self).sorted(byKeyPath: "display_num")
                    for i in 0 ..< self.productsCategory.count {
                        categoryArr.append(self.productsCategory[i].category_name)
                    }
                    
                    self.category.anchorView = self.btnCategory
                    self.category.bottomOffset = CGPoint(x: 0, y: self.btnCategory.bounds.height)
                    self.category.dataSource = categoryArr
                    
                    self.category.selectionAction = { [weak self] (index, item) in
                        SVProgressHUD.show(withStatus: "読み込み中")
                        if let categoryID = self?.productsCategory[index].id {
                            try! realm.write {
                                realm.delete(realm.objects(ProductData.self))
                            }
                            
                            APIRequest.onGetAllProduct(courseID: categoryID){ (success) in
                                if success {
                                    self!.btnCategory.setTitle(item, for: .normal)
                                    self?.btnProduct.setTitle("選択してください", for: .normal)
                                    self?.productIndex = nil
                                    self?.categoryIndex = index
                                    
                                    var productArr = [String]()
                                    self?.products = realm.objects(ProductData.self).sorted(byKeyPath: "display_num")
                                    for i in 0 ..< self!.products.count {
                                        productArr.append((self?.products[i].item_name)!)
                                    }
                                    
                                    self?.product.anchorView = self?.btnProduct
                                    self?.product.bottomOffset = CGPoint(x: 0, y: (self?.btnProduct.bounds.height)!)
                                    self?.product.dataSource = productArr
                                    
                                    self?.product.selectionAction = { [weak self] (index, item) in
                                        self?.btnProduct.setTitle(item, for: .normal)
                                        self?.productIndex = index
                                    }
                                } else {
                                    Utils.showAlert(message: "Can not get goods", view: self!)
                                }
                                SVProgressHUD.dismiss()
                            }
                        }
                        
                    }
                } else {
                    Utils.showAlert(message: "Can not get goods category", view: self)
                }
                SVProgressHUD.dismiss()
            }
        default:
            break
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSelectCourseCategory(_ sender: UIButton) {
        category.show()
    }
    
    @IBAction func onSelectCourse(_ sender: UIButton) {
        product.show()
    }
    
    @IBAction func onSelect(_ sender: UIButton) {
        if self.type == 1 {
            if let cellindex = self.cellIndex,let proIndex = self.productIndex {
                dismiss(animated: true) {
                    self.delegate?.onSelectContractServices(index: cellindex, course: self.courses[proIndex])
                }
            } else {
                Utils.showAlert(message: "コースを選択してください", view: self)
            }
        } else {
            if let cellindex = self.cellIndex,let proIndex = self.productIndex {
                dismiss(animated: true) {
                    self.delegate?.onSelectProductRelated(index: cellindex, course: self.products[proIndex])
                }
            } else {
                Utils.showAlert(message: "商品を選択してください", view: self)
            }
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
