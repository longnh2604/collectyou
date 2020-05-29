//
//  BedManagementVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/01/15.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import LGButton
import RealmSwift

class BedManagementVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var btnAddNew: LGButton!
    @IBOutlet weak var tblBed: UITableView!
    
    //Variable
    lazy var realm = try! Realm()
    var beds: Results<BedData>!
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

        let nib = UINib(nibName: "BedCell", bundle: nil)
        tblBed.register(nib, forCellReuseIdentifier: "BedCell")
        tblBed.delegate = self
        tblBed.dataSource = self
        tblBed.tableFooterView = UIView()
        tblBed.isEditing = true
        tblBed.allowsSelectionDuringEditing = true
        
        localizeLanguage()
    }
    
    private func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onGetAllBed { (success) in
            if success {
                self.beds = self.realm.objects(BedData.self).sorted(byKeyPath: "display_num")
                
                self.tblBed.reloadData()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    private func localizeLanguage() {
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Bed Management", comment: "")
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onAddNew(_ sender: LGButton) {
        guard let newPopup = BedPopupVC(nibName: "BedPopupVC", bundle: nil) as BedPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 350, height: 280)
        newPopup.totalBed = beds.count
        newPopup.accountID = accountID
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - UITableView Delegate, Datasource
//*****************************************************************

extension BedManagementVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (beds != nil) {
            return beds.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BedCell.self)) as! BedCell
        cell.configure(bed: beds[indexPath.row])
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
            let sourceObject = beds[sourceIndexPath.row]
            let destinationObject = beds[destinationIndexPath.row]

            let destinationObjectOrder = destinationObject.display_num

            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = beds[index]
                    object.display_num -= 1
                }
            } else {
                for index in (destinationIndexPath.row ..< sourceIndexPath.row).reversed() {
                    let object = beds[index]
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
        for i in 0 ..< beds.count {
            ids.append(beds[i].id)
            display_num.append(beds[i].display_num)
        }
        APIRequest.onSwapBed(ids: ids, display_num: display_num) { (success) in
            if success {
                self.tblBed.reloadData {
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
            guard let newPopup = BedPopupVC(nibName: "BedPopupVC", bundle: nil) as BedPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 300)
            newPopup.delegate = self
            newPopup.index = indexPath.row
            newPopup.bed = self.beds[indexPath.row]
            self.present(newPopup, animated: true, completion: nil)
        } else {
            currentIndex = indexPath.row
        }
    }
}

//*****************************************************************
// MARK: - BedPopupVC Delegate
//*****************************************************************

extension BedManagementVC: BedPopupVCDelegate {
    func onRefreshData() {
        self.loadData()
    }
    
    func onDeleteIndex(index: Int) {
        try! realm.write {
            //delete index first
            realm.delete(beds[index])
            //rearrange order
            for i in index ..< self.beds.count {
                let object = beds[i]
                object.display_num -= 1
            }
        }
        onSwapData()
    }
}
