//
//  GlobalVariables.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation

class GlobalVariables {

    //pagination load
    public var pageTotal: Int?
    public var pageCurr: Int?
    public var totalCus: Int?
    
    public var pageCurrTemp: Int?
    public var currentIndex: Int?
    
    //DD Contract
    public var courseIndex: Int?
    public var goodsIndex: Int?
    public var settlementIndex: Int?

    //account Chat
    public var account_chat: String?
    
    //limit storage
    public var limitSize: Int64?
    public var currentSize: Int64?
    
    //cell selection
    public var selectedImageIds: [String] = []
    
    //checkbox
    public var onMultiSelect: Bool?
    
    //app limition
    public var appLimitation: [Int] = []
    
    //favorite colors
    public var accFavoriteColors: [String] = []
    
    //company name
    public var comName: String?
    
    //id shop hierarchy
    public var hierarchyList: [Int] = []
    
    //customer switch
    public var customerSwitch: Bool?
    
    class var sharedManager: GlobalVariables {
        struct Static{
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
    
    func clearData() {
        GlobalVariables.sharedManager.pageTotal = nil
        GlobalVariables.sharedManager.pageCurr = nil
        GlobalVariables.sharedManager.totalCus = nil
        GlobalVariables.sharedManager.pageCurrTemp = nil
        GlobalVariables.sharedManager.currentIndex = nil
        GlobalVariables.sharedManager.courseIndex = nil
        GlobalVariables.sharedManager.goodsIndex = nil
        GlobalVariables.sharedManager.settlementIndex = nil
        GlobalVariables.sharedManager.pageCurrTemp = nil
        GlobalVariables.sharedManager.currentIndex = nil
        GlobalVariables.sharedManager.account_chat = nil
        GlobalVariables.sharedManager.limitSize = nil
        GlobalVariables.sharedManager.currentSize = nil
        GlobalVariables.sharedManager.selectedImageIds = []
        GlobalVariables.sharedManager.onMultiSelect = nil
        GlobalVariables.sharedManager.appLimitation = []
        GlobalVariables.sharedManager.accFavoriteColors = []
        GlobalVariables.sharedManager.comName = nil
        GlobalVariables.sharedManager.hierarchyList = []
        GlobalVariables.sharedManager.customerSwitch = nil
    }
}
