//
//  Constants.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import UIKit

class Constants: NSObject {

    static let PHOTO_STORE_URL = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/"
    static let CONTACT_SUPPORT_PHONE = "0120357339"
    
    enum VC_ID {
        static let SPLASH = "SplashVC"
        static let LOGIN = "LoginVC"
        static let APP_SELECT_AIMB = "AppSelectAIMBVC"
        static let APP_SELECT = "AppSelectVC"
        static let MAIN = "MainVC"
        static let CALENDAR = "CalendarVC"
        static let CARTE_LIST = "CarteListVC"
        static let CARTE_IMAGE_LIST = "CarteImageListVC"
    }
    
    enum AIMB {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "AimB/aimb_splash.png"
        static let SPLASH_BACKGROUND_NAME = "aimb_splash"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "AimB/aimb_login.png"
        static let LOGIN_BACKGROUND_NAME = "aimb_login"
        static let DOC1_URL = PHOTO_STORE_URL + "AimB/AIMB_catalogue1.pdf"
        static let DOC1_NAME = "AIMB_catalogue1"
        static let DOC2_URL = PHOTO_STORE_URL + "AimB/AIMB_catalogue2.pdf"
        static let DOC2_NAME = "AIMB_catalogue2"
        static let MENU_SELECT_BACKGROUND_URL = PHOTO_STORE_URL + "AimB/aimb_menu_select.png"
        static let MENU_SELECT_BACKGROUND_NAME = "aimb_menu_select"
        static let KARTE_ACCESS_URL = PHOTO_STORE_URL + "AimB/aimb_karte_access.png"
        static let KARTE_ACCESS_NAME = "aimb_karte_access"
        static let CATALOGUE1_ACCESS_URL = PHOTO_STORE_URL + "AimB/aimb_catalogue1_access.png"
        static let CATALOGUE1_ACCESS_NAME = "aimb_catalogue1_access"
        static let CATALOGUE2_ACCESS_URL = PHOTO_STORE_URL + "AimB/aimb_catalogue2_access.png"
        static let CATALOGUE2_ACCESS_NAME = "aimb_catalogue2_access"
        static let WEBSITE_URL = "https://aim-b.co.jp"
        static let FACEBOOK_APP_URL = ""
        static let FACEBOOK_WEB_URL = ""
    }
    
    enum JBS {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "JBS/JBS_splash.png"
        static let SPLASH_BACKGROUND_NAME = "JBS_splash"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "JBS/JBS_splash.png"
        static let LOGIN_BACKGROUND_NAME = "JBS_splash"
        static let DOC_URL = PHOTO_STORE_URL + "JBS/JBS_designbook.pdf"
        static let DOC_NAME = "JBS_designbook"
        static let WEBSITE_URL = "http://eyebrow.co.jp/index.html"
        static let FACEBOOK_APP_URL = "fb://profile/eyebrow.willbrow.ista"
        static let FACEBOOK_WEB_URL = "https://www.facebook.com/eyebrow.willbrow.ista/"
        static let FACE_TEMP_A_NO = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectA_no.png"
        static let FACE_TEMP_A_NO_NAME = "JBS_selectA_no"
        static let FACE_TEMP_A = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectA.png"
        static let FACE_TEMP_A_NAME = "JBS_selectA"
        static let FACE_TEMP_A_STYLE_1 = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectA1.png"
        static let FACE_TEMP_A_STYLE_1_NAME = "JBS_selectA1"
        static let FACE_TEMP_A_STYLE_2 = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectA2.png"
        static let FACE_TEMP_A_STYLE_2_NAME = "JBS_selectA2"
        static let FACE_TEMP_B = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectB.png"
        static let FACE_TEMP_B_NAME = "JBS_selectB"
        static let FACE_TEMP_B_STYLE_1 = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectB2.png"
        static let FACE_TEMP_B_STYLE_1_NAME = "JBS_selectB2"
        static let FACE_TEMP_C = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectC.png"
        static let FACE_TEMP_C_NAME = "JBS_selectC"
        static let FACE_TEMP_C_STYLE_1 = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectC2.png"
        static let FACE_TEMP_C_STYLE_1_NAME = "JBS_selectC2"
        static let FACE_TEMP_D = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectD.png"
        static let FACE_TEMP_D_NAME = "JBS_selectD"
        static let FACE_TEMP_D_STYLE_1 = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectD2.png"
        static let FACE_TEMP_D_STYLE_1_NAME = "JBS_selectD2"
        static let FACE_TEMP_E = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectE.png"
        static let FACE_TEMP_E_NAME = "JBS_selectE"
        static let FACE_TEMP_E_STYLE_1 = "https://abcarte-photostore.s3-ap-northeast-1.amazonaws.com/JBS/Face/JBS_selectE2.png"
        static let FACE_TEMP_E_STYLE_1_NAME = "JBS_selectE2"
    }
    
    enum SERMENT {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "Serment/serment_splash.png"
        static let SPLASH_BACKGROUND_NAME = "serment_splash.png"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "Serment/serment_login.png"
        static let LOGIN_BACKGROUND_NAME = "serment_login.png"
        static let DOC_URL = PHOTO_STORE_URL + "Serment/SERMENT_theory.pdf"
        static let DOC_NAME = "SERMENT_theory"
        static let WEBSITE_URL = "https://www.sermentjapan.com/"
        static let FACEBOOK_APP_URL = ""
        static let FACEBOOK_WEB_URL = ""
    }
    
    //Splash
    enum MIRAIKARTE {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "MiraiKarte/mirai_splash.png"
        static let SPLASH_BACKGROUND_NAME = "mirai_splash.png"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "MiraiKarte/mirai_splash.png"
        static let LOGIN_BACKGROUND_NAME = "mirai_splash.png"
        static let SPLASH_URL = PHOTO_STORE_URL + "MiraiKarte/mirai_splash.png"
        static let WEBSITE_URL = ""
        static let FACEBOOK_APP_URL = ""
        static let FACEBOOK_WEB_URL = ""
    }
    
    enum ESCOS {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "Escos/escos_splash.png"
        static let SPLASH_BACKGROUND_NAME = "escos_splash.png"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "Escos/escos_login.png"
        static let LOGIN_BACKGROUND_NAME = "escos_login.png"
        static let WEBSITE_URL = "http://www.escos.co.jp/"
        static let FACEBOOK_APP_URL = ""
        static let FACEBOOK_WEB_URL = ""
    }
    
    enum SHISEI {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "Shisei/shisei_splash.png"
        static let SPLASH_BACKGROUND_NAME = "shisei_splash.png"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "Shisei/shisei_splash.png"
        static let LOGIN_BACKGROUND_NAME = "shisei_splash.png"
        static let WEBSITE_URL = "https://jppm.or.jp/index.html"
        static let FACEBOOK_URL = "https://aim-b.co.jp"
        static let FACEBOOK_APP_URL = "fb://profile/nakada.tomoko.96"
        static let FACEBOOK_WEB_URL = "https://www.facebook.com/nakada.tomoko.96/"
    }
    
    enum COLLECTU {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "CollectU/collectU_splash.png"
        static let SPLASH_BACKGROUND_NAME = "collectU_splash.png"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "CollectU/collectU_splash.png"
        static let LOGIN_BACKGROUND_NAME = "collectU_splash.png"
        static let WEBSITE_URL = ""
        static let FACEBOOK_APP_URL = ""
        static let FACEBOOK_WEB_URL = ""
    }
    
    enum COVISION {
        static let SPLASH_BACKGROUND_URL = PHOTO_STORE_URL + "92pro/92pro_splash.png"
        static let SPLASH_BACKGROUND_NAME = "92pro_splash.png"
        static let LOGIN_BACKGROUND_URL = PHOTO_STORE_URL + "92pro/92pro_login.png"
        static let LOGIN_BACKGROUND_NAME = "92pro_login.png"
        static let WEBSITE_URL = ""
        static let FACEBOOK_APP_URL = ""
        static let FACEBOOK_WEB_URL = ""
    }
}

//Device rotation
enum DeviceOrientation {
    static let kLandscape = UIDevice.current.orientation.isLandscape
    static let kPortrait = UIDevice.current.orientation.isPortrait
}

enum Strokes_SET {
    
    static let vipS: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor : UIColor.yellow,
        NSAttributedString.Key.foregroundColor : UIColor.lightGray,
        NSAttributedString.Key.strokeWidth : -2.0,
    ]
    
    static let repeatS: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor : UIColor.orange,
        NSAttributedString.Key.foregroundColor : UIColor.lightGray,
        NSAttributedString.Key.strokeWidth : -2.0,
    ]
    
    static let trialS: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor : UIColor.green,
        NSAttributedString.Key.foregroundColor : UIColor.lightGray,
        NSAttributedString.Key.strokeWidth : -2.0,
    ]
    
    static let troubleS: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor : UIColor.red,
        NSAttributedString.Key.foregroundColor : UIColor.lightGray,
        NSAttributedString.Key.strokeWidth : -2.0,
    ]
    
    static let hiddenS: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor : UIColor.darkGray,
        NSAttributedString.Key.foregroundColor : UIColor.lightGray,
        NSAttributedString.Key.strokeWidth : -2.0,
    ]
    
    static let noreg: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor : UIColor.blue,
        NSAttributedString.Key.foregroundColor : UIColor.lightGray,
        NSAttributedString.Key.strokeWidth : -2.0,
    ]
}

//Color Set
enum COLOR_SET {
    static let kNAVIGATION_BAR_COLOR = UIColor(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1)
    static let kFEMALE_COLOR = UIColor(red: 241/255.0, green: 153/255.0, blue: 144/255.0, alpha: 1)
    static let kMALE_COLOR = UIColor(red: 94/255.0, green: 136/255.0, blue: 198/255.0, alpha: 1)
    static let kBROWN = UIColor(red: 246/255.0, green: 240/255.0, blue: 230/255.0, alpha: 1)
    static let kBLUE = UIColor(red: 120/255.0, green: 197/255.0, blue: 195/255.0, alpha: 1)
    static let kBLUENAVY = UIColor(red: 17/255.0, green: 76/255.0, blue: 108/255.0, alpha: 1)
    static let kPENSELECT = UIColor(red: 255/255.0, green: 182/255.0, blue: 172/255.0, alpha: 1)
    static let kPENUNSELECT = UIColor(red: 255/255.0, green: 219/255.0, blue: 213/255.0, alpha: 1)
    static let kCountDown_COLOR = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1)
    static let kLINE_CORRECT_COLOR = UIColor(red: 10/255, green: 175/255, blue: 200/255, alpha: 1)
    static let kGREEN = UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1)
    static let kDARKGREEN = UIColor(red: 50/255, green: 200/255, blue: 220/255, alpha: 1)
    static let kOCEANGREEN = UIColor(red: 189/255.0, green: 217/255.0, blue: 203/255.0, alpha: 1)
    static let kMEMO_SELECT_COLOR = UIColor(red: 255/255, green: 182/255, blue: 172/255, alpha: 1)
    static let kMEMO_HAS_CONTENT_COLOR = UIColor(red: 10/255, green: 175/255, blue: 200/255, alpha: 1)
    static let kYELLOW = UIColor(red: 255/255, green: 205/255, blue: 100/255, alpha: 0.85)
    static let kRED = UIColor(red: 255/255, green: 32/255, blue: 5/255, alpha: 0.85)
    static let kPINK = UIColor(red: 255/255, green: 153/255, blue: 147/255, alpha: 1)
    static let kLIGHTGRAY = UIColor(red: 211/255, green: 212/255, blue: 212/255, alpha: 1)
    static let kORANGE = UIColor(red: 255/255, green: 123/255, blue: 63/255, alpha: 0.85)
    static let kBORDER = UIColor(red: 255/255, green: 148/255, blue: 142/255, alpha: 1)
    static let kBACKGROUND_LIGHT_GRAY = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
    static let kCOMPARE_TOOL_UNSELECT = UIColor(red: 255/255, green: 229/255, blue: 225/255, alpha: 1)
    static let kCOMPARE_TOOL_SELECT = UIColor(red: 255/255, green: 205/255, blue: 200/255, alpha: 1)
}

enum COLOR_SET000 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 0/255.0, green: 65/255.0, blue: 106/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 0/255.0, green: 152/255.0, blue: 163/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 180/255.0, green: 220/255.0, blue: 224/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 248/255.0, green: 243/255.0, blue: 221/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 17/255.0, green: 43/255.0, blue: 62/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 236/255.0, green: 120/255.0, blue: 124/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET001 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 68/255.0, green: 15/255.0, blue: 8/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 161/255.0, green: 121/255.0, blue: 88/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 255/255.0, green: 204/255.0, blue: 194/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 245/255.0, green: 240/255.0, blue: 230/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 26/255.0, green: 185/255.0, blue: 181/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET002 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 148/255.0, green: 0/255.0, blue: 117/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 212/255.0, green: 84/255.0, blue: 150/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 252/255.0, green: 197/255.0, blue: 210/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 255/255.0, green: 242/255.0, blue: 236/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 60/255.0, green: 5/255.0, blue: 0/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 199/255.0, green: 0/255.0, blue: 96/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET003 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 0/255.0, green: 109/255.0, blue: 134/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 77/255.0, green: 139/255.0, blue: 155/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 189/255.0, green: 217/255.0, blue: 203/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 248/255.0, green: 242/255.0, blue: 226/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 20/255.0, green: 46/255.0, blue: 64/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 226/255.0, green: 137/255.0, blue: 212/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET004 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 59/255.0, green: 23/255.0, blue: 144/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 130/255.0, green: 124/255.0, blue: 174/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 219/255.0, green: 182/255.0, blue: 242/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 224/255.0, green: 229/255.0, blue: 250/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 33/255.0, green: 13/255.0, blue: 75/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 125/255.0, green: 195/255.0, blue: 164/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET005 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 234/255.0, green: 0/255.0, blue: 85/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 255/255.0, green: 92/255.0, blue: 85/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 226/255.0, green: 196/255.0, blue: 141/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 241/255.0, green: 245/255.0, blue: 244/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 60/255.0, green: 27/255.0, blue: 0/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 255/255.0, green: 90/255.0, blue: 66/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET006 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 104/255.0, green: 68/255.0, blue: 33/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 173/255.0, green: 151/255.0, blue: 122/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 255/255.0, green: 190/255.0, blue: 188/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 245/255.0, green: 240/255.0, blue: 230/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 125/255.0, green: 202/255.0, blue: 182/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET007 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 0/255.0, green: 128/255.0, blue: 127/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 105/255.0, green: 174/255.0, blue: 151/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 196/255.0, green: 226/255.0, blue: 184/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 251/255.0, green: 239/255.0, blue: 215/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 70/255.0, green: 35/255.0, blue: 0/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 242/255.0, green: 131/255.0, blue: 142/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET008 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 19/255.0, green: 0/255.0, blue: 100/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 133/255.0, green: 110/255.0, blue: 255/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 233/255.0, green: 157/255.0, blue: 218/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 255/255.0, green: 236/255.0, blue: 237/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 104/255.0, green: 206/255.0, blue: 189/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

//*****************************************************************
// MARK: - Message
//*****************************************************************

//general
enum MSG_ALERT {
    static let kALERT_FUNCTION_UNDER_CONSTRUCTION = "この機能は作成中です。"
    static let kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN = "ネットワークに接続できませんでした。 再度ネットワークの状態を確認してください。"
    static let kALERT_WRONG_PASSWORD = "パスワードが間違っています。正しいパスワードを入力してください。"
    static let kALERT_INPUT_PASSWORD = "パスワードを入力してください。"
    static let kALERT_INPUT_ACCOUNT_PASSWORD = "ログインパスワードを入力してください。"
    static let kALERT_INPUT_EMAIL = "メールアドレスを入力してください。"
    static let kALERT_INPUT_PHONE = "電話番号を入力してください。"
    static let kALERT_INPUT_DATE = "日付を入力してください"
    static let kALERT_AT_LEAST_INPUT_DATE_IN_A_ROW = "少なくとも1行に日付を入力してください"
    static let kALERT_INPUT_DATA = "データを入力してください"
    static let kALERT_SAVE_PHOTO_NOTIFICATION = "編集した画像を破棄しますよろしいですか?"
    static let kALERT_SAVE_MEMO_NOTIFICATION = "編集したメモを破棄しますよろしいですか?"
    static let kALERT_SAVE_DOCUMENT_NOTIFICATION = "編集したドキュメントを破棄しますよろしいですか?"
    static let kALERT_CANT_GET_DEVICE_STORAGE_LIMIT = "お客様アカウントスートレジの制限の読み込みに失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_CANCEL_WITHOUT_SAVE = "保存せずに取り消しますか？"
    
    //limit character
    static let kALERT_SECRET_MEMO_RESTRICT = "シークレットメモは250文字以内で登録してください。"
    static let kALERT_FREE_MEMO_RESTRICT = "フリーメモは1000文字以内で登録してください。"
    static let kALERT_REMARKS_RESTRICT = "備考は250文字以内で登録してください。"
    static let kALERT_KEYWORD_RESTRICT = "キーワードは50文字以内で登録してください。"
    static let kALERT_LAST_NAME_RESTRICT = "苗字は25文字以内で登録してください。"
    static let kALERT_FIRST_NAME_RESTRICT = "名前は25文字以内で登録してください。"
    static let kALERT_LAST_NAME_KANA_RESTRICT = "苗字のよみがなは40文字以内で登録してください。"
    static let kALERT_FIRST_NAME_KANA_RESTRICT = "名前のよみがなは40文字以内で登録してください。"
    static let kALERT_CUSTOMER_NO_RESTRICT = "お客様に割り当てる任意の番号は25文字以内で登録してください。"
    static let kALERT_CUSTOMER_URGENT_CONTACT_RESTRICT = "緊急時に連絡が取れる電話番号は25文字以内で登録してください。"
    static let kALERT_RESPONSIBLE_RESTRICT = "施術を行うメインスタッフは25文字以内で登録してください。"
    static let kALERT_POSTAL_CODE_RESTRICT = "郵便番号は10文字以内で登録してください。"
    static let kALERT_PREFECTURE_RESTRICT = "都道府県は8文字以内で登録してください。"
    static let kALERT_CITY_RESTRICT = "市区町村は20文字以内で登録してください。"
    static let kALERT_ADDRESS_RESTRICT = "住所は40文字以内で登録してください。"
    static let kALERT_EMAIL_RESTRICT = "メールアドレスは50文字以内で登録してください。"
    static let kALERT_HOBBY_RESTRICT = "趣味は200文字以内で登録してください。"
    static let kALERT_STAMP_TITLE_RESTRICT = "スタンプメモタイトルは10文字以内で登録してください。"
    
    //secret
    static let kALERT_UPDATE_SECRET_PASSWORD_SUCCESS = "シークレットメモのパスワードを更新しました。"
    
    //account
    static let kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER = "お客様情報を取得できませんでした。 サポートダイヤルへご連絡ください。"
    static let kALERT_ACCOUNT_CANT_ACCESS = "この機能はご利用いただけません。"
    static let kALERT_SERMENT_CANT_ACCESS = "選択された写真の枚数では、この動作を行う事は出来ません。"
    static let kALERT_ACCOUNT_DONT_HAVE_BRANCH = "このアカウントは子アカウントを管理していません。"
    
    //customer
    static let kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK = "お客様の情報の読み込みに失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_SEARCH_RESULTS_NOTHING = "検索結果がありませんでした。"
    static let kALERT_SELECT_CUSTOMER_2_DELETE = "削除するお客様を選択してください。"
    static let kALERT_CREATE_CUSTOMER_FIRST_ADD_SECRET_LATER = "シークレットメモを登録するには、先にお客様の登録を完了してください。"
    static let kALERT_INPUT_LAST_FIRST_NAME = "姓・名を入力してください。"
    static let kALERT_INPUT_LAST_FIRST_NAME_KANA = "姓 (かな) ・ 名 (かな) を入力してください。"
    static let kALERT_UPDATE_CUSTOMER_INFO_SUCCESS = "顧客情報を更新しました。"
    static let kALERT_UPDATE_CUSTOMER_INFO_FAIL = "顧客情報の読み込みに失敗しました。"
    static let kALERT_CREATE_CUSTOMER_INFO_SUCCESS = "顧客情報を登録しました。"
    
    //carte
    static let kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK = "カルテの読み込みに失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_CARTE_EXISTS_ALREADY = "既に当日のカルテが作成されています。"
    static let kALERT_SELECT_CARTE_2_DELETE = "削除するカルテを選択してください。"
    static let kALERT_REGISTER_CARTE_REPRESENTATIVE_SUCCESS = "カルテの代表画像を登録しました。"
    static let kALERT_CANT_DELETE_CARTE = "カルテを削除に失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_ADD_KARTE_SUCCESS = "カルテの作成が完了しました。"
    
    //memo
    static let kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK = "メモの読込に失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_CONFIRM_DELETE_MEMO_SELECTED = "選択されているメモを削除してよろしいですか?"
    static let kALERT_SELECT_MEMO_HAS_CONTENT_TO_DELETE = "内容があるメモを選択して下さい。"
    static let kALERT_MEMO_HAS_NOT_REGISTERED = "このメモが登録されていません。"
    static let kALERT_PLEASE_INPUT_CONTENT = "内容を入力してください。"
    
    //stamp
    static let kALERT_CANT_GET_STAMP_INFO_PLEASE_CHECK_NETWORK = "スタンプを取得できませんでした。 サポートダイヤルへご連絡ください。"
    static let kALERT_INPUT_TITLE = "タイトルを入力してください。"
    static let kALERT_INPUT_CONTENT = "内容を入力してください。"
    static let kALERT_SELECT_TITLE_EDIT = "編集するタイトルを選択してください。"
    static let kALERT_CANT_SAVE_TITLE = "タイトルの保存に失敗しました。再度登録をしてください。"
    static let kALERT_UPDATE_TITLE_SUCCESS = "タイトルの保存が完了しました。"
    
    //keyword
    static let kALERT_SELECT_KEYWORD = "キーワードを追加する前にスタンプを選択してください。"
    static let kALERT_SELECT_KEYWORD_DELETE = "削除するキーワードを選択してください。"
    static let kALERT_SELECT_KEYWORD_EDIT = "編集するキーワードを選択してください。"
    static let kALERT_CANT_DELETE_KEYWORD = "削除するキーワードを選択してください。"
    static let kALERT_ADD_KEYWORD_SUCCESS = "キーワードの保存が完了しました。"
    static let kALERT_CANT_SAVE_KEYWORD = "キーワードの保存に失敗しました。再度登録をしてください。"
    static let kALERT_UPDATE_KEYWORD = "キーワードの編集が完了しました。"
    
    //shooting
    static let kALERT_CHECK_CAMERA_CONNECTION = "カメラに接続出来ませんでした。"
    static let kALERT_SHOOTING_TRANMISSION_NOT_SATISFY = "透過撮影をする場合は、画像を1枚だけ選択してください。"
    static let kALERT_SHOOTING_TRANMISSION_NOT_ALLOW = "このアカウントでは透過撮影できません。"
    
    //photo
    static let kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK = "画像の保存に失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_PLEASE_SELECT_PHOTO = "写真を選択してください。"
    static let kALERT_CANT_SAVE_PHOTO = "画像の保存に失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_REACH_LIMIT_PHOTO = "このアカウントは写真の限界に達しました。"
    static let kALERT_CONFIRM_DELETE_PHOTO_SELECTED = "選択されている画像を削除してよろしいですか?"
    
    //drawing
    static let kALERT_DRAWING_ACCESS_NOT_SATISFY = "描画する画像を1枚選択してください。"
    static let kALERT_CHOOSE_2_TO_12_PHOTOS = "画像を2～12枚まで選択してください。"
    static let kALERT_UNLOCK_BEFORE_DRAWING = "描画する前にロックを解除してください。"
    static let kALERT_CHOOSE_FIGURE_TO_DRAW = "図を選択してください。"
    static let kALERT_SELECT_FAVORITE_COLOR = "好きな色を保存する番号を選択してください。"
    
    //documents
    static let kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK = "ドキュメントの読み込みに失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_SAME_TYPE_DOCUMENT = "同じデータが既に作成されています。"
    static let kALERT_CHECK_ALL_DOCUMENT_PAGE = "すべてのページを確認してください。"
    static let kALERT_DOCUMENT_EXISTS_ALREADY = "他の端末からドキュメントが登録されています。"
    
    //comparison
    static let kALERT_SERMENT_2_PHOTOS_LIMITED = "比較画像の選択は2枚までです"
    static let kALERT_CHOOSE_ONLY_2_PHOTOS = "画像を2枚だけ選択してください。"
    
    //chat
    static let kALERT_SHOP_CHAT_ACCOUNT_NOT_EXISTED = "ネットワークの接続に失敗しているか店舗アカウントが見つかりません。販売元に連絡してください。"
    static let kALERT_CUSTOMER_CHAT_ACCOUNT_NOT_EXISTED = "履歴がありません。お客様のメッセージアカウントを作成しますか？"
    static let kALERT_CANT_CREATE_CUSTOMER_CHAT_ACCOUNT = "お客様のメッセージアカウント作成に失敗しました。同期完了後、もう一度お試しください。"
    static let kALERT_CANT_CONNECT_CHAT = "メッセージ機能の起動に失敗しました。"
    static let kALERT_CANT_CONNECT_FACE2FACE_CHAT = "メッセージ表示に失敗しました。ネットワークを確認し、もう一度お試しください。"
    static let kALERT_CANT_GET_CHAT_HISTORY = "メッセージ履歴の読み込みに失敗しました。時間をおいてもう一度お試しください。"
    static let kALERT_CANT_DISCONNECT_CHAT = "メッセージ機能の終了に失敗しました。もう一度お試しください。"
    static let kALERT_CANT_GENERATE_QRCODE = "QRコードの作成に失敗しました。同期完了後、もう一度お試しください。"
}
