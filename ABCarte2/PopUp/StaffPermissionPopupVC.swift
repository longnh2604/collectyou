//
//  StaffPermissionPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/02/07.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objc protocol StaffPermissionPopupVCDelegate: class {
    @objc optional func onUpdatePermissionSuccess()
}

class StaffPermissionPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tblStaff: UITableView!
    @IBOutlet weak var lblCarte: UILabel!
    @IBOutlet weak var lblBrochure: UILabel!
    @IBOutlet weak var lblContract: UILabel!
    
    //Variable
    var staffs: Results<StaffData>!
    var permission = [[Int]]()
    weak var delegate:StaffPermissionPopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupLayout()
    }
    
    deinit {
        permission.removeAll()
    }

    private func setupLayout() {
        let nib = UINib(nibName: "StaffPermissionCell", bundle: nil)
        tblStaff.register(nib, forCellReuseIdentifier: "StaffPermissionCell")
        tblStaff.delegate = self
        tblStaff.dataSource = self
        tblStaff.tableFooterView = UIView()
        tblStaff.layer.borderColor = UIColor.black.cgColor
        tblStaff.layer.borderWidth = 1
        
        checkCondition()
    }
    
    private func loadData() {
        let realm = try! Realm()
        staffs = realm.objects(StaffData.self)
        
        for i in 0 ..< staffs.count {
            if staffs[i].permission != "" {
                let arr = staffs[i].permission.components(separatedBy: ",")
                let per = arr.map { Int($0)!}
                permission.append(per)
            } else {
                permission.append([0])
            }
        }
    }
    
    private func checkCondition() {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kStaffManagement.rawValue) {
            lblCarte.isHidden = false
        }
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kContract.rawValue) {
            lblBrochure.isHidden = false
            lblContract.isHidden = false
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSave(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        //get all ids
        var ids = [Int]()
        for i in 0 ..< staffs.count {
            ids.append(staffs[i].id)
        }
        
        var per = [String]()
        for j in 0 ..< permission.count {
            let arr = permission[j].map { String($0) }
            let combine = arr.joined(separator: ",")
            per.append(combine)
        }
     
        APIRequest.onUpdatePermissionMultiStaff(ids: ids, permissions: per) { (success) in
            if success {
                self.dismiss(animated: true) {
                    self.delegate?.onUpdatePermissionSuccess?()
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - UITableView Delegate, Datasource
//*****************************************************************

extension StaffPermissionPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffPermissionCell") as? StaffPermissionCell else
        { return UITableViewCell() }
        cell.configure(staff: staffs[indexPath.row],permission:permission[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//*****************************************************************
// MARK: - StaffPermissionCell Delegate
//*****************************************************************

extension StaffPermissionPopupVC: StaffPermissionCellDelegate {
    func onSelectCheckbox(index: Int, position: Int) {
        if permission[index].contains(position) {
            permission[index].remove(object: position)
        } else {
            permission[index].append(position)
        }
    }
}

extension UITableViewCell {
    var tableView:UITableView? {
        return superview as? UITableView
    }
    var indexPath:IndexPath? {
        return tableView?.indexPath(for: self)
    }
}
