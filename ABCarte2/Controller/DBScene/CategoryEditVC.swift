//
//  DatabaseVC.swift
//  ABCarte2
//
//  Created by 福嶋伸之 on 2019/12/20.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

// Main ViewController For database managenment. which includes 1 table, and 1 containver view which has 1 embeded view to edit specifications.
// Connects each handlers between table and embedded-view, for refreshing showing.

@objc protocol CategoryEditVCDelegate: class {
    @objc optional func didClose()
}

class CategoryEditVC:UIViewController {

    @IBOutlet weak var btnAddCategory: UIButton!
    @IBOutlet weak var tblCategory: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    //Variable
    weak var delegate:CategoryEditVCDelegate?
    var dataType : DataType?
    var editVC:CanEditDatabaseObject?
    var tableController:(NSObject & CanHandleDatabaseObjectsList)?
    var company: Results<CompanyData>!
    var course: Results<CourseCategoryData>!
    var product: Results<ProductCategoryData>!
    var room: Results<RoomData>!
    var job: Results<JobCategoryData>!
    var payment: Results<PaymentCategoryData>!
    var objectType:Object.Type {
        switch (dataType) {
        case (.course) : return CourseCategoryData.self
        case (.product) : return ProductCategoryData.self
        case (.company) : return CompanyData.self
        case (.equipment) : return RoomData.self
        case (.payment) : return PaymentCategoryData.self
        case (.job) : return JobCategoryData.self
        case (.none): return CourseData.self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        loadData()
        setupLayout()
    }
    
    private func loadData() {
        let realm = RealmServices.shared.realm
        if dataType == .course {
            self.course = realm.objects(CourseCategoryData.self).sorted(byKeyPath: "display_num")
        } else if dataType == .product {
            self.product = realm.objects(ProductCategoryData.self).sorted(byKeyPath: "display_num")
        } else if dataType == .company {
            self.company = realm.objects(CompanyData.self).sorted(byKeyPath: "display_num")
        } else if dataType == .equipment {
            self.room = realm.objects(RoomData.self).sorted(byKeyPath: "display_num")
        } else if dataType == .payment {
             self.payment = realm.objects(PaymentCategoryData.self).sorted(byKeyPath: "display_num")
        } else if dataType == .job {
            self.job = realm.objects(JobCategoryData.self).sorted(byKeyPath: "display_num")
        }
    }
    
    private func setupLayout() {
        self.tableController = self.makeTableController(dataType: dataType!, isCategoryMode: true)
        tblCategory.delegate = tableController
        tblCategory.dataSource = tableController
        tblCategory.tableFooterView = UIView()
        tblCategory.isEditing = true
        tblCategory.allowsSelectionDuringEditing = true
        
        self.children.filter{$0 is CanEditDatabaseObject}.forEach { (oldEditVC) in
            oldEditVC.view.removeFromSuperview()
            oldEditVC.removeFromParent()
        }
        
        editVC = makeEditVC(dataType: dataType!)
        // set editVC.view
        addChild(editVC!)
        editVC!.view.frame = CGRect(origin:.zero, size:containerView.bounds.size)
        containerView.addSubview(editVC!.view)
        
        switch dataType {
        case .company:
            lblTitle.text = "会社編集"
            btnAddCategory.setTitle("会社追加", for: .normal)
        case .course:
            lblTitle.text = "カテゴリー編集"
            btnAddCategory.setTitle("カテゴリー追加", for: .normal)
        case .product:
            lblTitle.text = "カテゴリー編集"
            btnAddCategory.setTitle("カテゴリー追加", for: .normal)
        case .equipment:
            lblTitle.text = "カテゴリー編集"
            btnAddCategory.setTitle("カテゴリー追加", for: .normal)
        default:
            break
        }
    }
    
    private func makeEditVC(dataType:DataType) -> CanEditDatabaseObject {
        let identifier = "Edit_\(dataType)_category"
        let editVC = (storyboard?.instantiateViewController(withIdentifier:identifier) as! CanEditDatabaseObject)
        editVC.onEditingBegan = deactivateViews
        editVC.onEditingEnded = { (object) in
            self.tblCategory.reloadData()
            editVC.currentObject = nil
            self.activateViews()
        }
        return editVC
    }
    
    private func makeTableController(dataType:DataType, isCategoryMode:Bool) -> (NSObject & CanHandleDatabaseObjectsList) {
        let tableController:(NSObject & CanHandleDatabaseObjectsList)
        switch (dataType, isCategoryMode) {
        case (.course, false): tableController = DatabaseItemTableManager<CourseCategoryData, CourseData>()
        case (.course, true) : tableController = DatabaseCategoryTableManager<CourseCategoryData, CourseData>()
        case (.product,false): tableController = DatabaseItemTableManager<ProductCategoryData, ProductData>()
        case (.product,true) : tableController = DatabaseCategoryTableManager<ProductCategoryData, ProductData>()
        case (.company,  false): tableController = DatabaseItemTableManager<CompanyData, StaffData>()
        case (.company,  true) : tableController = DatabaseCategoryTableManager<CompanyData, StaffData>()
        case (.equipment,  false): tableController = DatabaseItemTableManager<RoomData, BedData>()
        case (.equipment,  true) : tableController = DatabaseCategoryTableManager<RoomData, BedData>()
        case (.payment,  false): tableController = DatabaseItemTableManager<PaymentCategoryData, PaymentData>()
        case (.payment,  true) : tableController = DatabaseCategoryTableManager<PaymentCategoryData, PaymentData>()
        case (.job,  false): tableController = DatabaseItemTableManager<JobCategoryData, JobData>()
        case (.job,  true) : tableController = DatabaseCategoryTableManager<JobCategoryData, JobData>()
        }
        tableController.onSelectionChanged = { (object) in
            self.editVC?.currentObject = object
            self.editVC?.isNewObject = false
        }
        tableController.onMoveRowComplete = { () in
            //do nothing
        }
        return tableController
    }
    
    private func deactivateViews() {
        btnAddCategory.isUserInteractionEnabled = false
        tblCategory.isUserInteractionEnabled = false
        UIView.animate(withDuration:0.5) {
            self.btnAddCategory?.alpha = 0.5
            self.tblCategory.alpha = 0.5
        }
    }
    
    private func activateViews() {
        btnAddCategory.isUserInteractionEnabled = true
        btnAddCategory.alpha = 1
        tblCategory.isUserInteractionEnabled = true
        tblCategory.alpha = 1
    }
    
    @IBAction func onAddCategory(_ sender: UIButton) {
        editVC?.currentObject = tableController?.createNew(objectType, nextTo: tblCategory.indexPathForSelectedRow)
        editVC?.isNewObject = true
        deactivateViews()
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.didClose?()
        }
    }
}
