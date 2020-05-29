//
//  SplashVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import Lottie
import SnapKit

class SplashVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var wallpaper: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    func setupLayout() {
        //load splash image
        let animationString = "floral_loading_animation"
        #if SERMENT
        loadImageData(url: Constants.SERMENT.SPLASH_BACKGROUND_URL, name: Constants.SERMENT.SPLASH_BACKGROUND_NAME)
        #elseif SHISEI
        loadImageData(url: Constants.SHISEI.SPLASH_BACKGROUND_URL, name: Constants.SHISEI.SPLASH_BACKGROUND_NAME)
        #elseif AIMB
        loadImageData(url: Constants.AIMB.SPLASH_BACKGROUND_URL, name: Constants.AIMB.SPLASH_BACKGROUND_NAME)
        #elseif ESCOS
        loadImageData(url: Constants.ESCOS.SPLASH_BACKGROUND_URL, name: Constants.ESCOS.SPLASH_BACKGROUND_NAME)
        #elseif COLLECTU
        loadImageData(url: Constants.COLLECTU.SPLASH_BACKGROUND_URL, name: Constants.COLLECTU.SPLASH_BACKGROUND_NAME)
        #elseif MIRAIKARTE
        loadImageData(url: Constants.MIRAIKARTE.SPLASH_BACKGROUND_URL, name: Constants.MIRAIKARTE.SPLASH_BACKGROUND_NAME)
        #elseif ATTENDER
        loadImageData(url: Constants.JBS.SPLASH_BACKGROUND_URL, name: Constants.JBS.SPLASH_BACKGROUND_NAME)
        #elseif COVISION
        loadImageData(url: Constants.COVISION.SPLASH_BACKGROUND_URL, name: Constants.COVISION.SPLASH_BACKGROUND_NAME)
        #endif
        
        #if AIMB
        Utils.delay(2, closure: {
            self.goToLoginView()
        })
        #else
        // Create Loading Animation
        let loadAnimation = AnimationView(name: animationString)
        
        // Set view to full screen, aspectFill
        loadAnimation.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadAnimation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        loadAnimation.contentMode = .scaleAspectFill
        loadAnimation.play(fromFrame: 1, toFrame: 60) { (success) in
            self.goToLoginView()
        }
        view.addSubview(loadAnimation)
        loadAnimation.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(200)
            make.centerX.equalTo(self.view)
            #if COLLECTU
            make.bottom.equalTo(self.view).inset(20)
            #else
            make.bottom.equalTo(self.view).inset(200)
            #endif
        }
        #endif
    }
    
    private func loadImageData(url:String,name:String) {
        Utils.saveImage(urlString: url, fileName: name) { (success) in
            if success {
                Utils.showSavedImage(url: url, fileName: name) { (url) in
                    self.wallpaper.image = UIImage(contentsOfFile: url)
                }
            }
        }
    }
    
    private func goToLoginView() {
        guard let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: Constants.VC_ID.LOGIN) as? LoginVC else { return }
        loginPageView.modalPresentationStyle = .fullScreen
        self.present(loginPageView, animated: true, completion: nil)
    }

}
