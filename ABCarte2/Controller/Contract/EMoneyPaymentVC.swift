//
//  EMoneyPaymentVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/17.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

class EMoneyPaymentVC: BasePaymentVC {

    //IBOutlet
    @IBOutlet weak var btnEMoney: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    private func setupLayout() {
        if settlementData.institution_name != "" {
            btnEMoney.setTitle(settlementData.institution_name, for: .normal)
        } else {
            btnEMoney.setTitle("リスト選択", for: .normal)
        }
    }
    
    @IBAction func onEMoneySelect(_ sender: UIButton) {
        let emoneys = realm.objects(PaymentData.self).filter("category_id == 3").sorted(byKeyPath: "display_num")
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        for i in 0 ..< emoneys.count {
            let action = UIAlertAction(title: emoneys[i].credit_company, style: .default) { (UIAlertAction) in
                self.btnEMoney.setTitle(emoneys[i].credit_company, for: .normal)
                self.settlementData.institution_name = emoneys[i].credit_company
            }
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.btnEMoney
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnEMoney.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
