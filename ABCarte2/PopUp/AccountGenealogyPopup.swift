//
//  AccountGenealogyPopup.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/12/17.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class ShopData: NSObject {
    var shop_id: Int = 0
    var shop_name: String = ""
}

@objc protocol AccountGenealogyPopupDelegate: class {
    @objc optional func onSwitchCustomerOwner(newAccount:Int)
}

class AccountGenealogyPopup: UIViewController {

    //IBOutlet
    @IBOutlet weak var tblShop: UITableView!
    
    //Variable
    var shopData = [ShopData]()
    var selectedIndex: Int?
    weak var delegate:AccountGenealogyPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    fileprivate func setupLayout() {
        let nib = UINib(nibName: "CarteListCell", bundle: nil)
        tblShop.register(nib, forCellReuseIdentifier: "CarteListCell")
        tblShop.delegate = self
        tblShop.dataSource = self
        tblShop.tableFooterView = UIView()
        
        tblShop.layer.borderColor = UIColor.lightGray.cgColor
        tblShop.layer.borderWidth = 2
    }

    fileprivate func loadData() {
        let realm = RealmServices.shared.realm
        let accounts = realm.objects(AccountData.self)
        
        if accounts.count > 0 {
            APIRequest.onGetGenealogy(accountID: accounts[0].id) { (json) in
                for i in 0 ..< json.count {
                    let shop = ShopData()
                    shop.shop_id = json[i][0].intValue
                    shop.shop_name = json[i][1].stringValue
                    self.shopData.append(shop)
                }
                self.tblShop.reloadData()
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onConfirm(_ sender: UIButton) {
        if let selectedIndex = selectedIndex {
            dismiss(animated: true) {
                self.delegate?.onSwitchCustomerOwner?(newAccount: self.shopData[selectedIndex].shop_id)
            }
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

//*****************************************************************
// MARK: - UITableView Delegate,Datasource
//*****************************************************************

extension AccountGenealogyPopup: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarteListCell") as? CarteListCell else
        { return UITableViewCell() }
        cell.configureShopData(name: shopData[indexPath.row].shop_name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
}
