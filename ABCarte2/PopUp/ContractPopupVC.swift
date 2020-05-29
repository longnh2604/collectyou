//
//  ContractPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/17.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

protocol ContractPopupVCDelegate: class {
    func onAddContract(time:Int,id:Int)
    func onGoToContractConfirm(time:Int,id:Int,brochureData:BrochureData)
    func onPreviewBrochure(id:Int,url:String)
    func onPreviewContract(id:Int,url:String)
    func onAddCustomerSign(brochureData:BrochureData)
}

class ContractPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tblContract: UITableView!
    
    //Variable
    weak var delegate:ContractPopupVCDelegate?
    var brochureData : [BrochureData] = []
    var brochures: Results<BrochureData>!
    var customer = CustomerData()
    var account = AccountData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    deinit {
        print("Release memory")
    }
    
    fileprivate func setupLayout() {
        //setup tableview
        let nib = UINib(nibName: "ContractCell", bundle: nil)
        tblContract.register(nib, forCellReuseIdentifier: "ContractCell")
        
        tblContract.dataSource = self
        tblContract.delegate = self
        tblContract.tableFooterView = UIView()
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = RealmServices.shared.realm
        try! realm.write {
            realm.delete(realm.objects(BrochureData.self))
        }
        
        //Get category title first
        APIRequest.onGetAllBrochure(cusID: customer.id) { (success) in
            if success {
                self.brochures = realm.objects(BrochureData.self)
                self.brochureData.removeAll()
                
                for i in 0 ..< self.brochures.count {
                    self.brochureData.append(self.brochures[i])
                }
                self.tblContract.reloadData()
            }
            SVProgressHUD.dismiss()
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onAddContract(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Carte", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier:"AddContractPopupVC") as? AddContractPopupVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - TableView Delegate
//*****************************************************************

extension ContractPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brochureData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContractCell") as? ContractCell else
        { return UITableViewCell() }
        cell.configure(brochure: brochureData[indexPath.row],index: indexPath.row)
        cell.delegate = self
        return cell
    }
}

//*****************************************************************
// MARK: - ContractCell Delegate
//*****************************************************************

extension ContractPopupVC: ContractCellDelegate {

    func onAddContract(type: Int, time: Int,id: Int,index:Int) {
        switch type {
        case 1:
            dismiss(animated: true) {
                self.delegate?.onAddContract(time: time,id:id)
            }
        case 2:
            dismiss(animated: true) {
                self.delegate?.onGoToContractConfirm(time:time,id: id,brochureData:self.brochureData[index])
            }
        case 3:
            Utils.showAlert(message: "先に概要書を記入して下さい", view: self)
        default:
            break
        }
    }
    
    func onPreviewContract(type: Int, id: Int, url: String,index: Int) {
        switch type {
        case 1:
            dismiss(animated: true) {
                self.delegate?.onPreviewBrochure(id: id, url: url)
            }
        case 2:
            dismiss(animated: true) {
                self.delegate?.onPreviewContract(id: id, url: url)
            }
        default:
            break
        }
    }
    
    func onAddCustomerFinalSign(id: Int, index: Int, type: Int) {
        switch type {
        case 1:
            dismiss(animated: true) {
                self.delegate?.onAddCustomerSign(brochureData: self.brochureData[index])
            }
        case 2:
            Utils.showAlert(message: "先に概要書面と契約書を記入して下さい", view: self)
        default:
            break
        }
        
    }
}

//*****************************************************************
// MARK: - ContractCell Delegate
//*****************************************************************

extension ContractPopupVC: AddContractPopupVCDelegate {
    func didAddContract(time: Int) {
        APIRequest.onAddBrochure(accountID: account.id, cusID: customer.id, date: time) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(BrochureData.self))
                }
                
                APIRequest.onGetAllBrochure(cusID: self.customer.id) { (success) in
                    if success {
                        self.brochures = realm.objects(BrochureData.self)
                        self.brochureData.removeAll()
                        
                        for i in 0 ..< self.brochures.count {
                            self.brochureData.append(self.brochures[i])
                        }
                        self.tblContract.reloadData()
                    }
                    SVProgressHUD.dismiss()
                }
            } else {
                Utils.showAlert(message: "Can not add brochure", view: self)
            }
        }
    }
}
