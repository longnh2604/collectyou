//
//  ProductListPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/02.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

protocol ProductListPopupVCDelegate: class {
    func onAddProduct(products: [ProductData])
}

class ProductListPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tblProduct: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    
    //Variable
    var dbm = DatabaseManager<ProductCategoryData, ProductData>(addsUnspecified:false, includesInactives:true)
    var isEdited: Bool = false
    weak var delegate:ProductListPopupVCDelegate?
    var selectedProduct = [ProductData]()
    var productIDs = [Int]()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        productIDs.removeAll()
    }
    
    private func setupLayout() {
        let nib = UINib(nibName: "NormalCell", bundle: nil)
        tblProduct.register(nib, forCellReuseIdentifier: "NormalCell")
        tblProduct.delegate = self
        tblProduct.dataSource = self
        tblProduct.tableFooterView = UIView()
        tblProduct.allowsMultipleSelection = true
        tblProduct.layer.borderColor = UIColor.black.cgColor
        tblProduct.layer.borderWidth = 1.0
        
        btnSave.isEnabled = false
        btnSave.alpha = 0.2
    }
    
    private func startEditing() {
        if isEdited {
            return
        } else {
            isEdited = true
            btnSave.isEnabled = true
            btnSave.alpha = 1
        }
    }
    
    private func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)

        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        APIRequest.onGetAllProductCategoriesAndProducts(accID: accountID) { (success) in
            if success {
                self.setupLayout()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSave(_ sender: UIButton) {
        for indexPath in tblProduct.indexPathsForSelectedRows! {
            let object = dbm.categories[indexPath.section].subItems[indexPath.row]
            let product = ProductData()
            product.id = object.id
            product.item_name = object.item_name
            product.item_category = object.item_category
            product.unit_price = object.unit_price
            selectedProduct.append(product)
        }
        
        dismiss(animated: true) {
            self.delegate?.onAddProduct(products: self.selectedProduct)
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - UITableView Delegate
//*****************************************************************

extension ProductListPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dbm.categories[section].title
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dbm.categories.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbm.categories[section].subItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
        let object = dbm.categories[indexPath.section].subItems[indexPath.row]
        cell.textLabel?.text = object.titleForTable
        
        if productIDs.contains(object.id) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        func shouldSelect() -> Bool {
            let object = dbm.categories[indexPath.section].subItems[indexPath.row]
            if productIDs.contains(object.id) {
                return true
            }
            return false
        }
        if shouldSelect() {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startEditing()
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.isSelected {
                cell.accessoryType = .checkmark
            }
        }
        
        let object = dbm.categories[indexPath.section].subItems[indexPath.row]
        if productIDs.contains(object.id) {
            productIDs.remove(object: object.id)
        } else {
            productIDs.append(object.id)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        startEditing()
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        
        let object = dbm.categories[indexPath.section].subItems[indexPath.row]
        if productIDs.contains(object.id) {
            productIDs.remove(object: object.id)
        } else {
            productIDs.append(object.id)
        }
    }
}
