//
//  LocalizationSystem.swift
//  ABCarte2
//
//  Created by Long on 2019/05/14.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation
import UIKit

class LocalizationSystem:NSObject {
    
    var bundle: Bundle!
    
    class var sharedInstance: LocalizationSystem {
        struct Singleton {
            static let instance: LocalizationSystem = LocalizationSystem()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        bundle = Bundle.main
    }
    
    func localizedStringForKey(key:String, comment:String) -> String {
        return bundle.localizedString(forKey: key, value: comment, table: nil)
    }
    
    func localizedImagePathForImg(imagename:String, type:String) -> String {
        guard let imagePath =  bundle.path(forResource: imagename, ofType: type) else {
            return ""
        }
        return imagePath
    }
    
    //MARK:- setLanguage
    func setLanguage(languageCode:String) {
        UserDefaults.standard.set(languageCode, forKey: "CY-Lang")
        
        if let languageDirectoryPath = Bundle.main.path(forResource: languageCode, ofType: "lproj")  {
            bundle = Bundle.init(path: languageDirectoryPath)
        } else {
            resetLocalization()
        }
    }
    
    //MARK:- resetLocalization
    //Resets the localization system, so it uses the OS default language.
    func resetLocalization() {
        bundle = Bundle.main
    }
    
    //MARK:- getLanguage
    // Just gets the current setted up language.
    func getLanguage() -> String {
        guard let appleLanguages = UserDefaults.standard.string(forKey: "CY-Lang") else {
            return "ja"
        }
        return appleLanguages
    }
    
}
