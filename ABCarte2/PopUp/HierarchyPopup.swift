//
//  HierarchyPopup.swift
//  ABCarte2
//
//  Created by Long on 2019/05/07.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import CITreeView
import RealmSwift

protocol HierarchyPopupDelegate: class {
    func onUpdateHierarchyData(arrIDs:[Int])
}

class HierarchyPopup: UIViewController, UITableViewDelegate {

    //IBOutlet
    @IBOutlet weak var tblHierarchy: CITreeView!
    
    //Variable
    var data : [CITreeViewData] = []
    var accountsData = AccountData()
    var treeData : [AccTreeData] = []
    var arrIDs = [Int]()
    weak var delegate:HierarchyPopupDelegate?
    let treeViewCellIdentifier = "TreeViewCellIdentifier"
    let treeViewCellNibName = "CITreeViewCell"
    var type : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    func setupLayout() {
        //set up value if first time open hierarchy
        if let status = UserPreferences.appHierarchy {
            if status == AppHierarchy.open.rawValue {
                //do nothing
            } else {
                UserPreferences.appHierarchy = AppHierarchy.open.rawValue
            }
        } else {
            UserPreferences.appHierarchy = AppHierarchy.open.rawValue
        }
        
        var status = true
        if !GlobalVariables.sharedManager.hierarchyList.contains(accountsData.id) {
            status = false
        }
        
        if type == 2 {
            data = CITreeViewData.getCITreeViewDataNew(head: accountsData.acc_name, headID: accountsData.id, status: false, branch: treeData)
        } else {
            data = CITreeViewData.getCITreeViewData(head: accountsData.acc_name,headID: accountsData.id,status:status,branch:treeData)
        }

        tblHierarchy.collapseNoneSelectedRows = false
        tblHierarchy.register(UINib(nibName: treeViewCellNibName, bundle: nil), forCellReuseIdentifier: treeViewCellIdentifier)
        tblHierarchy.tableFooterView = UIView()
    }
    
    deinit {
        data.removeAll()
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        
        for i in 0 ..< data.count {
            onGetID(data: data[i])
        }
        dismiss(animated: true) {
            self.delegate?.onUpdateHierarchyData(arrIDs: self.arrIDs)
        }
    }
    
    func onGetID(data:CITreeViewData) {
        if data.selected == true {
            arrIDs.append(data.id)
        }
        
        for i in 0 ..< data.children.count {
            if data.children[i].selected == true {
                arrIDs.append(data.children[i].id)
            }
            for j in 0 ..< data.children[i].children.count {
                onGetID(data: data.children[i].children[j])
            }
        }
    }
}

//*****************************************************************
// MARK: - CITreeView
//*****************************************************************

extension HierarchyPopup: CITreeViewDelegate, CITreeViewDataSource {
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        print("will expand")
    }
    
    func didExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        print("did expand")
    }
    
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        print("will collapse")
    }
    
    func didCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        print("did collapse")
    }
    
    func treeViewSelectedNodeChildren(for treeViewNodeItem: AnyObject) -> [AnyObject] {
        if let dataObj = treeViewNodeItem as? CITreeViewData {
            return dataObj.children
        }
        return []
    }
    
    func treeViewDataArray() -> [AnyObject] {
        return data
    }
    
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> CGFloat {
        return 60
    }
    
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath) {
        if let parentNode = treeViewNode.parentNode{
            print(parentNode.item)
        }
    }
    
    func treeView(_ treeView: CITreeView, didDeselectRowAt treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath) {
        
    }
    
    func treeView(_ treeView: CITreeView, atIndexPath indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: treeViewCellIdentifier) as! CITreeViewCell
        let dataObj = treeViewNode.item as! CITreeViewData
        if dataObj.children.count > 0 {
            cell.viewContains.image = UIImage(named: "icon_hierarchy_contain.png")
        } else {
            cell.viewContains.image = UIImage(color: UIColor.white)
        }
        cell.nameLabel.text = dataObj.name
        cell.btnCheckBox.tag = dataObj.id
        cell.selectedCell = dataObj.selected
        cell.delegate = self
        cell.setupCell(level: treeViewNode.level)
        return cell
    }
}

extension HierarchyPopup: CITreeViewCellDelegate {
    func onCheckBoxSelect(id: Int) {
        for i in 0 ..< data.count {
            onCheckID(data: data[i], id: id)
        }
        tblHierarchy.reloadDataWithoutChangingRowStates()
    }
    
    func onCheckID(data:CITreeViewData,id:Int) {
        if data.id == id {
            data.selected = !data.selected
        } else {
            if type == 2 {
                data.selected = false
            }
        }
        
        for i in 0 ..< data.children.count {
            if data.children[i].id == id {
                data.children[i].selected = !data.children[i].selected
            } else {
                if type == 2 {
                    data.children[i].selected = false
                }
            }
            
            for j in 0 ..< data.children[i].children.count {
                onCheckID(data: data.children[i].children[j], id: id)
            }
        }
    }
}
