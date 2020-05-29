//
//  CustomerStampMemoPopup.swift
//  ABCarte2
//
//  Created by Long on 2019/10/11.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

protocol CustomerStampMemoPopupDelegate: class {
    func onStampMemoSearch(content:String)
}

class CustomerStampMemoPopup: UIViewController {

    //IBOutlet
    @IBOutlet weak var tblCategory: UITableView!
    @IBOutlet weak var tblKeyword: UITableView!
    @IBOutlet weak var tblContentSearch: UITableView!
    
    //Variable
    weak var delegate:CustomerStampMemoPopupDelegate?
    var categories: Results<StampCategoryData>!
    var categoriesData : [StampCategoryData] = []
    var keywords: Results<StampKeywordData>!
    var keywordsData : [StampKeywordData] = []
    var keywordsSelected : [StampKeywordData] = []
    var categoryIndex: Int = 0
    var keywordIndex: Int = 0
    var idKeywords: [Int] = []
    var indexSelect1: [Int] = []
    var indexSelect2: [Int] = []
    var indexSelect3: [Int] = []
    var indexSelect4: [Int] = []
    lazy var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    deinit {
        print("Release Memory")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        categoriesData.removeAll()
        keywordsData.removeAll()
        keywordsSelected.removeAll()
    }
    
    fileprivate func setupLayout() {
        let nib1 = UINib(nibName: "SecretCell", bundle: nil)
        tblCategory.register(nib1, forCellReuseIdentifier: "SecretCell")
        tblCategory.dataSource = self
        tblCategory.delegate = self
        tblCategory.tag = 1
        tblCategory.tableFooterView = UIView()
        tblCategory.layer.borderWidth = 2
        tblCategory.layer.borderColor = UIColor.white.cgColor
        tblCategory.layer.cornerRadius = 5
        
        let nib2 = UINib(nibName: "StampCell", bundle: nil)
        tblKeyword.register(nib2, forCellReuseIdentifier: "StampCell")
        tblKeyword.dataSource = self
        tblKeyword.delegate = self
        tblKeyword.tag = 2
        tblKeyword.tableFooterView = UIView()
        tblKeyword.layer.borderWidth = 2
        tblKeyword.layer.borderColor = UIColor.white.cgColor
        tblKeyword.layer.cornerRadius = 5
   
        let nib3 = UINib(nibName: "MessageTemplateCell", bundle: nil)
        tblContentSearch.register(nib3, forCellReuseIdentifier: "MessageTemplateCell")
        tblContentSearch.dataSource = self
        tblContentSearch.delegate = self
        tblContentSearch.tag = 3
        tblContentSearch.tableFooterView = UIView()
        tblContentSearch.layer.borderWidth = 2
        tblContentSearch.layer.borderColor = UIColor.white.cgColor
        tblContentSearch.layer.cornerRadius = 5
    }
    
    fileprivate func loadData() {
        //Get category title first
        SVProgressHUD.show(withStatus: "読み込み中")
      
        APIRequest.onGetStampCategoryDynamicOrStatic { (success) in
            if success {
                self.categories = self.realm.objects(StampCategoryData.self)
                self.categoriesData.removeAll()
              
                for i in 0 ..< self.categories.count {
                    self.categoriesData.append(self.categories[i])
                }
                
                self.tblCategory.reloadData()
                self.tblCategory.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
                self.onSelectCategory(index: 0)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func onSelectCategory(index:Int) {
        keywordsData.removeAll()
        for i in 0 ..< categoriesData[index].keywords.count {
            keywordsData.append(categoriesData[index].keywords[i])
        }
        self.tblKeyword.reloadData()
        self.categoryIndex = index
    }
    
//    fileprivate func onSelectCategory(index:Int) {
//        SVProgressHUD.show(withStatus: "読み込み中")
//        let realm = RealmServices.shared.realm
//        try! realm.write {
//            realm.delete(realm.objects(StampKeywordData.self))
//        }
//
//        APIRequest.onGetKeyFromCategory(categoryID: categoriesData[index].id,page: nil, completion: { (success) in
//            if success {
//                self.keywords = realm.objects(StampKeywordData.self)
//                self.keywordsData.removeAll()
//
//                for i in 0 ..< self.keywords.count {
//                    self.keywordsData.append(self.keywords[i])
//                }
//
//                self.tblKeyword.reloadData()
//                self.categoryIndex = index
//            } else {
//                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_STAMP_INFO_PLEASE_CHECK_NETWORK, view: self)
//            }
//            SVProgressHUD.dismiss()
//        })
//    }
    
    fileprivate func addToIndex(categoryIndex:Int,index:Int) {
        switch categoryIndex {
        case 0:
            if indexSelect1.contains(where: { $0 == index }) {
                indexSelect1.remove(object: index)
            } else {
                indexSelect1.append(index)
            }
        case 1:
            if indexSelect2.contains(where: { $0 == index }) {
                indexSelect2.remove(object: index)
            } else {
                indexSelect2.append(index)
            }
        case 2:
            if indexSelect3.contains(where: { $0 == index }) {
                indexSelect3.remove(object: index)
            } else {
                indexSelect3.append(index)
            }
        case 3:
            if indexSelect4.contains(where: { $0 == index }) {
                indexSelect4.remove(object: index)
            } else {
                indexSelect4.append(index)
            }
        default:
            break
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSearch(_ sender: UIButton) {
        var content : [String] = []
        for i in 0 ..< keywordsSelected.count {
            content.append("\(keywordsSelected[i].id)")
        }
        
        dismiss(animated: true) {
            self.delegate?.onStampMemoSearch(content: content.joined(separator: ","))
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - UITableView Delegate
//*****************************************************************

extension CustomerStampMemoPopup: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return categoriesData.count
        } else if tableView.tag == 2 {
            return keywordsData.count
        } else if tableView.tag == 3 {
            return keywordsSelected.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SecretCell") as? SecretCell {
                cell.configure(content:categoriesData[indexPath.row].title)
                cell.selectionStyle = .none
                return cell
            }
        } else if tableView.tag == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StampCell") as? StampCell {
                if categoryIndex == 0 {
                    if indexSelect1.contains(where: { $0 == indexPath.row }) {
                        cell.selectedCell = true
                    } else {
                        cell.selectedCell = false
                    }
                } else if categoryIndex == 1 {
                    if indexSelect2.contains(where: { $0 == indexPath.row }) {
                        cell.selectedCell = true
                    } else {
                        cell.selectedCell = false
                    }
                } else if categoryIndex == 2 {
                    if indexSelect3.contains(where: { $0 == indexPath.row }) {
                        cell.selectedCell = true
                    } else {
                        cell.selectedCell = false
                    }
                } else if categoryIndex == 3 {
                    if indexSelect4.contains(where: { $0 == indexPath.row }) {
                        cell.selectedCell = true
                    } else {
                        cell.selectedCell = false
                    }
                } else {
                    cell.selectedCell = false
                }
                cell.configure(title: keywordsData[indexPath.row].content)
                return cell
            }
        } else if tableView.tag == 3 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTemplateCell") as? MessageTemplateCell {
                cell.configure(content:keywordsSelected[indexPath.row].content)
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            onSelectCategory(index: indexPath.row)
        } else if tableView.tag == 2 {
            if let cell = tableView.cellForRow(at: indexPath) as? StampCell {
                if keywordsSelected.contains(where: { $0.id == self.keywordsData[indexPath.row].id }) {
                    keywordsSelected.removeAll(where: { $0.id == self.keywordsData[indexPath.row].id })
                    addToIndex(categoryIndex: categoryIndex, index: indexPath.row)
                    cell.selectedCell = false
                } else {
                    let stamp = StampKeywordData()
                    stamp.id = self.keywordsData[indexPath.row].id
                    stamp.content = self.keywordsData[indexPath.row].content
                    keywordsSelected.append(stamp)
                    addToIndex(categoryIndex: categoryIndex, index: indexPath.row)
                    cell.selectedCell = true
                }
                cell.update()
                tblContentSearch.reloadData()
            }
        }
    }
}
