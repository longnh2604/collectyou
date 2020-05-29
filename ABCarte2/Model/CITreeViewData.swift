//
//  CITreeViewData.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit
import RealmSwift

class CITreeViewData {
    
    let name : String
    let id : Int
    var selected: Bool
    var children : [CITreeViewData]
    
    init(name : String, id: Int, selected: Bool, children: [CITreeViewData]) {
        self.name = name
        self.id = id
        self.selected = selected
        self.children = children
    }
    
    convenience init(name : String, id: Int,selected: Bool) {
        self.init(name: name, id: id, selected: selected, children: [CITreeViewData]())
    }
    
    func addChild(_ child : CITreeViewData) {
        self.children.append(child)
    }
    
    func removeChild(_ child : CITreeViewData) {
        self.children = self.children.filter( {$0 !== child})
    }
    
    deinit {
        print("Deinit ...")
    }
}

extension CITreeViewData {
    
    static func getCITreeViewData(head:String,headID:Int,status:Bool,branch:[AccTreeData]) -> [CITreeViewData] {
        
        var parentChild = [CITreeViewData]()
        
        for i in 0 ..< branch.count {
            var subChild = [CITreeViewData]()
            for j in 0 ..< branch[i].children.count {
                subChild.append(getData(list: branch[i].children[j]))
            }
            
            var statusChild = true
            if !GlobalVariables.sharedManager.hierarchyList.contains(branch[i].id) {
                statusChild = false
            }
            
            let child = CITreeViewData(name: branch[i].acc_name,id: branch[i].id,selected: statusChild, children: subChild)
            
            parentChild.append(child)
        }
        return parentChild
    }
    
    static func getData(list:AccTreeData)->CITreeViewData {
        var child = [CITreeViewData]()
        
        for i in 0 ..< list.children.count {
            let newchild = getData(list: list.children[i])
            child.append(newchild)
        }
        
        var status = true
        if !GlobalVariables.sharedManager.hierarchyList.contains(list.id) {
            status = false
        }
        
        let parent = CITreeViewData(name: list.acc_name,id: list.id,selected: status, children: child)
        return parent
    }
    
    static func getCITreeViewDataNew(head:String,headID:Int,status:Bool,branch:[AccTreeData]) -> [CITreeViewData] {
        
        var parentChild = [CITreeViewData]()
        
        for i in 0 ..< branch.count {
            var subChild = [CITreeViewData]()
            for j in 0 ..< branch[i].children.count {
                subChild.append(getDataNew(list: branch[i].children[j]))
            }
            
//            var statusChild = true
//            if !GlobalVariables.sharedManager.hierarchyList.contains(branch[i].id) {
//                statusChild = false
//            }
            
            let child = CITreeViewData(name: branch[i].acc_name,id: branch[i].id,selected: status, children: subChild)
            
            parentChild.append(child)
        }
        return parentChild
    }
    
    static func getDataNew(list:AccTreeData)->CITreeViewData {
        var child = [CITreeViewData]()
        
        for i in 0 ..< list.children.count {
            let newchild = getDataNew(list: list.children[i])
            child.append(newchild)
        }
        
//        var status = true
//        if !GlobalVariables.sharedManager.hierarchyList.contains(list.id) {
//            status = false
//        }
        
        let parent = CITreeViewData(name: list.acc_name,id: list.id,selected: false, children: child)
        return parent
    }
    
}
