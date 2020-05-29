//
//  StartingVC.swift
//  JBSDemo
//
//  Created by Long on 2018/05/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class StartingVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var btnStart: UIButton!
    
    //Variable
    var emptyDict = Dictionary<String,String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyDict = [Constants.JBS.FACE_TEMP_A: Constants.JBS.FACE_TEMP_A_NAME,
        Constants.JBS.FACE_TEMP_B: Constants.JBS.FACE_TEMP_B_NAME,
        Constants.JBS.FACE_TEMP_C: Constants.JBS.FACE_TEMP_C_NAME,
        Constants.JBS.FACE_TEMP_D: Constants.JBS.FACE_TEMP_D_NAME,
        Constants.JBS.FACE_TEMP_A_NO: Constants.JBS.FACE_TEMP_A_NO_NAME,
        Constants.JBS.FACE_TEMP_E: Constants.JBS.FACE_TEMP_E_NAME
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        //set gradient navigation bar
        guard let navi = navigationController else { return }
        if let set = UserPreferences.appColorSet {
            addNavigationBarColor(navigation: navi,type: set)
        } else {
            addNavigationBarColor(navigation: navi,type: 0)
        }
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func goToMainView() {
        let queue = OperationQueue()
        for (key, value) in emptyDict {
            queue.addOperation {
                Utils.saveImage(urlString: key, fileName: value) { (success) in
                    print("\(key) success")
                }
            }
        }
        queue.waitUntilAllOperationsAreFinished()
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ImageSelectVC") as? ImageSelectVC {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) { 
        guard let story: UIStoryboard = UIStoryboard(name: "Login", bundle: nil) as UIStoryboard?,
              let vc =  story.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else { return }
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onStart(_ sender: UIButton) {
        goToMainView()
    }

}
