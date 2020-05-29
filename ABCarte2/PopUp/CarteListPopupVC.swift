//
//  CarteListPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/12/12.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class CarteListPopupVC: UIViewController {

    //Variable
    var cartesData : [CarteData] = []
    var cellIndex: Int?
    var mediaData: Data?
    
    //IBOutlet
    @IBOutlet weak var tblCarte: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        let nib = UINib(nibName: "CarteListCell", bundle: nil)
        tblCarte.register(nib, forCellReuseIdentifier: "CarteListCell")
        tblCarte.delegate = self
        tblCarte.dataSource = self
        tblCarte.tableFooterView = UIView()
        
        tblCarte.layer.borderColor = UIColor.lightGray.cgColor
        tblCarte.layer.borderWidth = 2
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onRegister(_ sender: UIButton) {
        if let cellIndex = cellIndex,let mediaData = mediaData {
            APIRequest.onAddMultiMediasIntoCarte(carteID: cartesData[cellIndex].id, mediaData: [mediaData], progressHandler: { (progress) in
                SVProgressHUD.showProgress(Float(progress), status: "読み込み中 : \(Int(progress)*100)%")
            }) { (success) in
                if success {
                    Utils.showAlert(message: MSG_ALERT.kALERT_ADD_KARTE_SUCCESS, view: self)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
                SVProgressHUD.dismiss()
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

extension CarteListPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarteListCell") as? CarteListCell else
        { return UITableViewCell() }
        cell.configure(carteData:cartesData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellIndex = indexPath.row
    }
}
