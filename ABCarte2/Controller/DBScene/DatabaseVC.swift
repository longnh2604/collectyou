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

//MARK: - properties & outlets
enum DataType {
    case course
    case product
    case company
    case equipment
    case payment
    case job
}

class DatabaseVC:UIViewController, CanAdjustToKeyboardAppearing, UIPopoverPresentationControllerDelegate {

    var dataType:DataType?
    var isCategoryMode:Bool = false
 
    var editVC:CanEditDatabaseObject?
    var tableController:(NSObject & CanHandleDatabaseObjectsList)?
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editCategoryButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var btnCourse: UIButton!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var btnCompany: UIButton!
    @IBOutlet weak var btnEquipment: UIButton!
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var btnStaffPermission: UIButton!
    @IBOutlet weak var btnJob: UIButton!
    
    //MARK: - computed properties
    func labelString(categoryMode:Bool?=nil) -> String {
        let categoryMode = categoryMode ?? isCategoryMode
        switch dataType {
        case .course : return categoryMode ? "カテゴリー" : "コース"
        case .product: return categoryMode ? "カテゴリー" : "商品"
        case .company  : return categoryMode ? "会社"    : "スタッフ"
        case .equipment : return categoryMode ? ""      : "設備"
        case .payment : return categoryMode ? "支払カテゴリー" : "お支払い"
        case .job : return categoryMode ? ""      : "職種"
        case .none: return categoryMode ? "" : ""
        }
    }
    var addButtonTitle:String {
        return labelString() + "追加"
    }
    var objectType:Object.Type {
        switch (dataType, isCategoryMode) {
        case (.course, false): return CourseData.self
        case (.course, true) : return CourseCategoryData.self
        case (.product,false): return ProductData.self
        case (.product,true) : return ProductCategoryData.self
        case (.company,  false): return StaffData.self
        case (.company,  true) : return CompanyData.self
        case (.equipment, false) : return BedData.self
        case (.equipment, true) : return RoomData.self
        case (.payment, false) : return PaymentData.self
        case (.payment, true) : return PaymentCategoryData.self
        case (.job, false) : return JobData.self
        case (.job, true) : return JobCategoryData.self
        case (.none, _): return CourseData.self
        }
    }
    //MARK: - lifecycle & actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.setEditing(true, animated:true)
        loadData()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.alpha = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Opening Category-edit popup when there are no category.
//        if tableController?.numberOfSections?(in:listTableView) ?? 0 <= 1 {
//            if !isCategoryMode {
//                openCategoryEditPopup()
//            }
//        }
    }
    
    private func loadData() {
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        if accountID == 0 { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        switch dataType {
        case .course:
            APIRequest.onGetAllCourseCategoriesAndCourses(accID: accountID) { (success) in
                if success {
                    self.editVC = self.makeEditVC(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.tableController = self.makeTableController(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.setEditingViews()
                    self.setButtonStatus()
                    self.reloadList(select:nil)
                    SVProgressHUD.dismiss()
                }
            }
        case .product:
            let realm = RealmServices.shared.realm
            try! realm.write {
                realm.delete(realm.objects(ProductCategoryData.self))
                realm.delete(realm.objects(ProductData.self))
            }
            
            APIRequest.onGetAllProductCategoriesAndProducts(accID: accountID) { (success) in
                if success {
                    self.editVC = self.makeEditVC(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.tableController = self.makeTableController(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.setEditingViews()
                    self.setButtonStatus()
                    self.reloadList(select:nil)
                    SVProgressHUD.dismiss()
                }
            }
        case .company:
            APIRequest.onGetCompanyInfo(accID: accountID) { (success) in
                if success {
                    APIRequest.onGetAllStaff { (success) in
                        if success {
                            self.editVC = self.makeEditVC(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                            self.tableController = self.makeTableController(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                            self.setEditingViews()
                            self.setButtonStatus()
                            self.reloadList(select:nil)
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        case .equipment:
            APIRequest.onGetAllBed { (success) in
                if success {
                    self.editVC = self.makeEditVC(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.tableController = self.makeTableController(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.setEditingViews()
                    self.setButtonStatus()
                    self.reloadList(select:nil)
                    SVProgressHUD.dismiss()
                }
            }
        case .payment:
            APIRequest.onGetAllPaymentMethod(accountID: accountID) { (success) in
                if success {
                    self.editVC = self.makeEditVC(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.tableController = self.makeTableController(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.setEditingViews()
                    self.setButtonStatus()
                    self.reloadList(select:nil)
                    SVProgressHUD.dismiss()
                }
            }
        case .job:
            APIRequest.onGetJobInfo { (success) in
                if success {
                    self.editVC = self.makeEditVC(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.tableController = self.makeTableController(dataType:self.dataType!, isCategoryMode:self.isCategoryMode)
                    self.setEditingViews()
                    self.setButtonStatus()
                    self.reloadList(select:nil)
                    SVProgressHUD.dismiss()
                }
            }
        default:
            break
        }
    }
    
    private func setupLayout() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "マスター登録", comment: "")
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kContract.rawValue) {
            btnCourse.isHidden = false
            btnProduct.isHidden = false
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kBedManagement.rawValue) {
            btnEquipment.isHidden = false
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPaymentManagement.rawValue) {
            btnPayment.isHidden = false
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kJobManagement.rawValue) {
            btnJob.isHidden = false
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editCategoryButtonTapped(_ sender:UIButton) {
        openCategoryEditPopup()
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.reloadList(select:nil)
    }
    
    @IBAction func addButtonTapped() {
        if let indexPath = listTableView.indexPathForSelectedRow {
            listTableView.deselectRow(at:indexPath, animated:false)
        }
        editVC?.currentObject = tableController?.createNew(objectType, nextTo:listTableView.indexPathForSelectedRow)
        editVC?.isNewObject = true
        deactivateViews()
    }
    @IBAction func targetSelectButton_course(_ sender: UIButton) {
        dataType = .course
        editCategoryButton.setTitle("カテゴリー編集", for: .normal)
        editCategoryButton.isEnabled = true
        loadData()
        addButton.setTitle(addButtonTitle, for: .normal)
        btnStaffPermission.isHidden = true
    }
    @IBAction func targetSelectButton_product(_ sender: UIButton) {
        dataType = .product
        editCategoryButton.setTitle("カテゴリー編集", for: .normal)
        editCategoryButton.isEnabled = true
        loadData()
        addButton.setTitle(addButtonTitle, for: .normal)
        btnStaffPermission.isHidden = true
    }
    @IBAction func targetSelectButton_staff(_ sender: UIButton) {
        dataType = .company
        editCategoryButton.setTitle("会社編集", for: .normal)
        editCategoryButton.isEnabled = true
        loadData()
        addButton.setTitle(addButtonTitle, for: .normal)
        btnStaffPermission.isHidden = false
    }
    @IBAction func targetSelectButton_equipment(_ sender: UIButton) {
        dataType = .equipment
        editCategoryButton.setTitle("", for: .normal)
        editCategoryButton.isEnabled = false
        loadData()
        addButton.setTitle(addButtonTitle, for: .normal)
        btnStaffPermission.isHidden = true
    }
    @IBAction func targetSelectButton_card(_ sender: UIButton) {
        dataType = .payment
        editCategoryButton.setTitle("", for: .normal)
        editCategoryButton.isEnabled = false
        loadData()
        addButton.setTitle(addButtonTitle, for: .normal)
        btnStaffPermission.isHidden = true
    }
    @IBAction func targetSelectButton_job(_ sender: UIButton) {
        dataType = .job
        editCategoryButton.setTitle("", for: .normal)
        editCategoryButton.isEnabled = false
        loadData()
        addButton.setTitle(addButtonTitle, for: .normal)
        btnStaffPermission.isHidden = true
    }
    @IBAction func onStaffPermissionSelect(_ sender: UIButton) {
        guard let newPopup = StaffPermissionPopupVC(nibName: "StaffPermissionPopupVC", bundle: nil) as StaffPermissionPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 500, height: 500)
        newPopup.delegate = self
        if #available(iOS 13.0, *) {
            newPopup.isModalInPresentation = true
        }
        self.present(newPopup, animated: true, completion: nil)
    }
    private func setButtonStatus() {
        if !isCategoryMode {
            switch dataType {
            case .course:
                btnCourse.isEnabled = false
                btnProduct.isEnabled = true
                btnCompany.isEnabled = true
                btnEquipment.isEnabled = true
                btnPayment.isEnabled = true
                btnJob.isEnabled = true
            case .product:
                btnCourse.isEnabled = true
                btnProduct.isEnabled = false
                btnCompany.isEnabled = true
                btnEquipment.isEnabled = true
                btnPayment.isEnabled = true
                btnJob.isEnabled = true
            case .company:
                btnCourse.isEnabled = true
                btnProduct.isEnabled = true
                btnCompany.isEnabled = false
                btnEquipment.isEnabled = true
                btnPayment.isEnabled = true
                btnJob.isEnabled = true
            case .equipment:
                btnCourse.isEnabled = true
                btnProduct.isEnabled = true
                btnCompany.isEnabled = true
                btnEquipment.isEnabled = false
                btnPayment.isEnabled = true
                btnJob.isEnabled = true
            case .payment:
                btnCourse.isEnabled = true
                btnProduct.isEnabled = true
                btnCompany.isEnabled = true
                btnEquipment.isEnabled = true
                btnPayment.isEnabled = false
                btnJob.isEnabled = true
            case .job:
                btnCourse.isEnabled = true
                btnProduct.isEnabled = true
                btnCompany.isEnabled = true
                btnEquipment.isEnabled = true
                btnPayment.isEnabled = true
                btnJob.isEnabled = false
            case .none:
                break
            }
        }
    }
    
    //MARK: - functions
    private func openCategoryEditPopup() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"CategoryEditVC") as? CategoryEditVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.dataType = dataType
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    private func makeEditVC(dataType:DataType, isCategoryMode:Bool) -> CanEditDatabaseObject {
        let identifier = "Edit_\(dataType)\(isCategoryMode ? "_category" : "")"
        let editVC = (storyboard?.instantiateViewController(withIdentifier:identifier) as! CanEditDatabaseObject)
        editVC.onEditingBegan = deactivateViews
        editVC.onEditingEnded = { (object) in
            self.reloadList(select: object)
            self.activateViews()
        }
        editVC.onReloadData = loadData
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
        case (.equipment,  false) : tableController = DatabaseItemTableManager<RoomData, BedData>()
        case (.equipment,  true) : tableController = DatabaseCategoryTableManager<RoomData, BedData>()
        case (.payment,  false) : tableController = DatabaseItemTableManager<PaymentCategoryData, PaymentData>()
        case (.payment,  true) : tableController = DatabaseCategoryTableManager<PaymentCategoryData, PaymentData>()
        case (.job,  false) : tableController = DatabaseItemTableManager<JobCategoryData, JobData>()
        case (.job,  true) : tableController = DatabaseCategoryTableManager<JobCategoryData, JobData>()
        }
        tableController.onSelectionChanged = { (object) in
            self.editVC?.currentObject = object
            self.editVC?.isNewObject = false
        }
        tableController.onMoveRowComplete = { () in
//            self.reloadList(select: nil)
            self.loadData()
        }
        tableController.onMoveRowNotAllowed = { () in
            Utils.showAlert(message: "他のカテゴリーに移動出来ません。", view: self)
        }
        return tableController
    }
    private func setEditingViews() {
        // removing old editVC.view
        self.children.filter{$0 is CanEditDatabaseObject}.forEach { (oldEditVC) in
            oldEditVC.view.removeFromSuperview()
            oldEditVC.removeFromParent()
        }
        // set editVC.view
        addChild(editVC!)
        editVC!.view.frame = CGRect(origin:.zero, size:containerView.bounds.size)
        containerView.addSubview(editVC!.view)
        // set tableView
        listTableView.dataSource = tableController
        listTableView.delegate = tableController
        listTableView.reloadData()
        listTableView.tableFooterView = UIView()
    }
    func deactivateViews() {
        buttonsView?.isUserInteractionEnabled = false
        listView.isUserInteractionEnabled = false
        UIView.animate(withDuration:0.5) {
            self.buttonsView?.alpha = 0.5
            self.listView.alpha = 0.5
        }
    }
    func activateViews() {
        buttonsView?.isUserInteractionEnabled = true
        buttonsView?.alpha = 1
        listView.isUserInteractionEnabled = true
        listView.alpha = 1
    }
    func reloadList(select:Object?) {
        // deselect current selection
        if let indexPath = listTableView.indexPathForSelectedRow {
            listTableView.deselectRow(at:indexPath, animated:false)
        }

        self.listTableView.reloadData()

        // select specified object
        guard
            let object = select,
            let indexPath = tableController?.indexPath(for:object) else {
                editVC?.currentObject = nil
                return
        }
        listTableView.selectRow(at:indexPath, animated:true, scrollPosition:.middle)
        tableController?.tableView?(listTableView, didSelectRowAt:indexPath)
    }
    func showNotWorkingAlert() {
        let alert = UIAlertController(title:"Still not working", message:"現在、機能していません", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"Close", style:.cancel, handler:nil))
        self.show(alert, sender:nil)
    }
}

//*****************************************************************
// MARK: - StaffPermissionPopup Delegate
//*****************************************************************

extension DatabaseVC: StaffPermissionPopupVCDelegate {
    func onUpdatePermissionSuccess() {
        self.loadData()
    }
}

//*****************************************************************
// MARK: - CategoryEditVC Delegate
//*****************************************************************

extension DatabaseVC: CategoryEditVCDelegate {
    func didClose() {
        self.loadData()
    }
}
