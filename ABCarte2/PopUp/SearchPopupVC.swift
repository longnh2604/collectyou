//
//  SearchPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol SearchPopupVCDelegate: class {
    func selectSearchType(title:String)
}

class SearchPopupVC: UIViewController {

    //Variable
    weak var delegate:SearchPopupVCDelegate?
    
    var latestExpandedSection: Int?
    var searchTitleArr: [String] = []
    //IBOutlet
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tblSearch: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
 
    func setupUI() {
        
        searchTitleArr = ["五 十 音( 頭 文 字 )検 索","お客様の姓・名で検索","電話番号検索","性別検索","お客様番号検索","担当者名検索","住所検索","誕生日検索","備考検索","来店日検索"]
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            searchTitleArr.append("シークレットメモ検索")
        }
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kFreeMemoSearch.rawValue) {
            searchTitleArr.append("フリーメモ検索")
        }
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kStampMemoSearch.rawValue) {
            searchTitleArr.append("スタンプメモ検索")
        }

        //create triangle in top of view
        let triangle = TriangleView(frame: CGRect(x: 220, y: -15, width: 20 , height: 15))
        triangle.clipsToBounds = true
        triangle.backgroundColor = .clear
        viewSearch.addSubview(triangle)
        
        //setup tableview
        tblSearch.dataSource = self
        tblSearch.delegate = self
        
        tblSearch.rowHeight = UITableView.automaticDimension
        tblSearch.estimatedRowHeight = 40
        tblSearch.tableFooterView = UIView()
        
        if let set = UserPreferences.appColorSet {
            switch set {
            case AppColorSet.standard.rawValue:
                viewSearch.backgroundColor = COLOR_SET000.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET000.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.jbsattender.rawValue:
                viewSearch.backgroundColor = COLOR_SET001.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET001.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.romanpink.rawValue:
                viewSearch.backgroundColor = COLOR_SET002.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET002.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.hisul.rawValue:
                viewSearch.backgroundColor = COLOR_SET003.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET003.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.lavender.rawValue:
                viewSearch.backgroundColor = COLOR_SET004.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET004.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.pinkgold.rawValue:
                viewSearch.backgroundColor = COLOR_SET005.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET005.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.mysteriousnight.rawValue:
                viewSearch.backgroundColor = COLOR_SET006.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET006.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.gardenparty.rawValue:
                viewSearch.backgroundColor = COLOR_SET007.kEDIT_SCREEN_BACKGROUND_COLOR
                tblSearch.backgroundColor = COLOR_SET007.kEDIT_SCREEN_BACKGROUND_COLOR
            default:
                break
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            
            if hitView == viewSearch {
            
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}

//*****************************************************************
// MARK: - TableView Delegate
//*****************************************************************

extension SearchPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTitleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchCell.self)) as! SearchCell
        cell.layoutMargins = UIEdgeInsets.zero
        cell.lblTitle.text = searchTitleArr[indexPath.row]
//        cell.showSeparator()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.delegate?.selectSearchType(title: self.searchTitleArr[indexPath.row])
        }
    }
    
}
