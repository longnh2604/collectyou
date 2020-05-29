//
//  StaffManagementVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/01/07.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import LGButton

class StaffManagementVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tblStaff: UITableView!
    
    //Variable
    lazy var realm = try! Realm()
    var staffs: Results<StaffData>!
    var accountID : Int?
    var currentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    private func setupLayout() {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        let nib = UINib(nibName: "StaffCell", bundle: nil)
        tblStaff.register(nib, forCellReuseIdentifier: "StaffCell")
        tblStaff.delegate = self
        tblStaff.dataSource = self
        tblStaff.tableFooterView = UIView()
        tblStaff.isEditing = true
        tblStaff.allowsSelectionDuringEditing = true
        
        localizeLanguage()
    }
    
    private func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onGetAllStaff { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.staffs = realm.objects(StaffData.self).sorted(byKeyPath: "display_num")
                
                self.tblStaff.reloadData()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    private func localizeLanguage() {
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Staff Management", comment: "")
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onAddNewStaff(_ sender: LGButton) {
        guard let newPopup = StaffPopupVC(nibName: "StaffPopupVC", bundle: nil) as StaffPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 600, height: 320)
        newPopup.totalStaff = staffs.count
        newPopup.accountID = accountID
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    @IBAction func onAddPermission(_ sender: UIView) {
        guard let newPopup = StaffPermissionPopupVC(nibName: "StaffPermissionPopupVC", bundle: nil) as StaffPermissionPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 500, height: 500)
        newPopup.delegate = self
        if #available(iOS 13.0, *) {
            newPopup.isModalInPresentation = true
        }
        self.present(newPopup, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - UITableView Delegate, Datasource
//*****************************************************************

extension StaffManagementVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (staffs != nil) {
            return staffs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StaffCell.self)) as! StaffCell
        cell.configure(staff: staffs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let sourceObject = staffs[sourceIndexPath.row]
            let destinationObject = staffs[destinationIndexPath.row]

            let destinationObjectOrder = destinationObject.display_num

            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = staffs[index]
                    object.display_num -= 1
                }
            } else {
                for index in (destinationIndexPath.row ..< sourceIndexPath.row).reversed() {
                    let object = staffs[index]
                    object.display_num += 1
                }
            }
            sourceObject.display_num = destinationObjectOrder
        }
        onSwapData()
    }
    
    fileprivate func onSwapData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        var ids = [Int]()
        var display_num = [Int]()
        for i in 0 ..< staffs.count {
            ids.append(staffs[i].id)
            display_num.append(staffs[i].display_num)
        }
        APIRequest.onSwapStaff(ids: ids, display_num: display_num) { (success) in
            if success {
                self.tblStaff.reloadData {
                    SVProgressHUD.dismiss()
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentIndex == indexPath.row {
            guard let newPopup = StaffPopupVC(nibName: "StaffPopupVC", bundle: nil) as StaffPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 600, height: 320)
            newPopup.delegate = self
            newPopup.staff = self.staffs[indexPath.row]
            newPopup.index = indexPath.row
            newPopup.accountID = accountID
            self.present(newPopup, animated: true, completion: nil)
        } else {
            currentIndex = indexPath.row
        }
    }
}

//*****************************************************************
// MARK: - StaffPopupVC Delegate
//*****************************************************************

extension StaffManagementVC: StaffPopupVCDelegate {

    func onRefreshData() {
        self.loadData()
    }
    
    func onDeleteIndex(index: Int) {
        try! realm.write {
            //delete index first
            realm.delete(staffs[index])
            //rearrange order
            for i in index ..< self.staffs.count {
                let object = staffs[i]
                object.display_num -= 1
            }
        }
        onSwapData()
    }
}

//*****************************************************************
// MARK: - StaffPermissionPopup Delegate
//*****************************************************************

extension StaffManagementVC: StaffPermissionPopupVCDelegate {
    func onUpdatePermissionSuccess() {
        self.loadData()
    }
}
