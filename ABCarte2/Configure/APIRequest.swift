//
//  APIRequest.swift
//  ABCarte2
//
//  Created by Long on 2018/08/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

//alias
typealias IntCompletion = (_ success: Bool, _ no: Int) -> Void
typealias StringCompletion = (_ success: Bool, _ string: String) -> Void
typealias ArrayCompletion = (_ success: Bool, _ arrData: JSON) -> Void
typealias URLCompletion = (_ success: Bool, _ url: URL) -> Void
typealias CusDataCompletion = (_ success: Bool, _ cus: CustomerData) -> Void
typealias StampMemoDataCompletion = (_ success: Bool, _ stamp: StampMemoData) -> Void
typealias TreeDataCompletion = (_ success: Bool, _ tree: [AccTreeData]) -> Void

class APIRequest: NSObject {
    
    //*****************************************************************
    // MARK: - Authentication
    //*****************************************************************
    
    //Device Info Tracking
    static func onCustomerDeviceInfoTracking(completion: @escaping StringCompletion) {
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let idToken: Int = UserDefaults.standard.integer(forKey: "idtoken")
        let dateToken: Int = UserDefaults.standard.integer(forKey: "token_date")
        let mac_add: String = UserDefaults.standard.string(forKey: "mac_address")!
        let app_ver = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        let os_ver = UIDevice.current.systemVersion
        let deviceType = UIDevice().type
        let ipad_model = deviceType.rawValue
        
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let url = kAPI_URL + kAPI_ACC_TRACKING
        
        let parameters = [
            "fc_account_token_id": idToken,
            "fc_account_token_mac_address": mac_add,
            "date": dateToken,
            "app_ver":  app_ver ?? "",
            "ipad_model": ipad_model,
            "os_ver": os_ver
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters as Parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(_):
                completion(true,"")
            case.failure(let error):
                print(error)
                completion(false,MSG_ALERT.kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER)
            }
        }
    }
    
    //Get Latest App Version
    static func onGetLatestAppVersion(appID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_LATEST_VERSION + "/\(appID)"
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                let latestAppVersion = json["app_ver"].stringValue
                let linkUpdate = json["url_link"].stringValue
                let appVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
                
                let realm = try! Realm()
                let accounts = realm.objects(AccountData.self)
                if accounts.count > 0 {
                    if latestAppVersion == appVersion {
                        let dict : [String : Any?] = ["needUpdate" : ""]
                        RealmServices.shared.update(accounts[0], with: dict)
                    } else {
                        let dict : [String : Any?] = ["needUpdate" : latestAppVersion,
                                                      "linkUpdate" : linkUpdate]
                        RealmServices.shared.update(accounts[0], with: dict)
                    }
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Authentication by QR Code (get Acc Name)
    static func QRauthenticateServer(accID:String,completion: @escaping StringCompletion) {
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters = [
            "account_id": accID
        ]
        
        let url = kAPI_URL + kAPI_TOKEN + "?qr=true"
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                let msg = json["message"]
                
                if msg.stringValue == "account_id not found" {
                    completion(false,"ユーザー名またはパスワードが違います。")
                    return
                }
                
                let accN = json["acc_name"].stringValue
                GlobalVariables.sharedManager.comName = accN
                
                completion(true,accN)
                
            case.failure(let error):
                print(error)
                completion(false,"ログインに失敗しました。ネットワークの状態を確認してください。")
            }
        }
    }
    
    //Normally Authentication
    static func authenticateServer(accID:String,accPassword:String,appVer:String,iOSVer:String,ipadModel:String,completion: @escaping StringCompletion) {
        //get uuid
        guard let uuid = Utils.getUUID() else { return }
        print("UUID: \(uuid)")
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters = [
            "account_id": accID,
            "acc_password": accPassword,
            "mac_address": uuid,
            "app_ver":appVer,
            "os_ver":iOSVer,
            "ipad_model":ipadModel
        ]
        let url = kAPI_URL + kAPI_TOKEN
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(AccountData.self))
                }
                
                let json = JSON(data)
                
                if json["code"] == 0 {
                    completion(false,"ログインに失敗しました。ネットワークの状態を確認してください。")
                    return
                }
                
                let msg = json["message"]
                
                if msg.stringValue == "No license for this device" {
                    completion(false,"使用できるライセンスがいっぱいです。これ以上の端末ではログインできません。")
                    return
                } else if msg.stringValue == "Your account has been locked" {
                    completion(false,"このデバイスがログイン許可されていません")
                    return
                }
                
                let msgAccID = json["account_id"]
                
                for i in 0 ..< msgAccID.count {
                    if msgAccID[i].stringValue == "Account Id cannot be blank." {
                        completion(false,"ユーザー名またはパスワードが空白です")
                        return
                    }
                }
                
                let msgAccPass = json["acc_password"]
                
                for i in 0 ..< msgAccPass.count {
                    if msgAccPass[i].stringValue == "Acc Password cannot be blank." {
                        completion(false,"ユーザー名またはパスワードが空白です")
                        return
                    }
                    
                    if msgAccPass[i].stringValue == "Incorrect username or password." {
                        completion(false,"ユーザー名またはパスワードが違います")
                        return
                    }
                }
                
                //Save to UserDefaults
                UserDefaults.standard.set(json["id"].intValue, forKey: "idtoken")
                UserDefaults.standard.set(json["access_token"].stringValue, forKey: "token")
                UserDefaults.standard.set(json["mac_address"].stringValue, forKey: "mac_address")
                UserDefaults.standard.set(accID, forKey: "collectu-usr")
                UserDefaults.standard.set(accPassword, forKey: "collectu-pwd")
                UserDefaults.standard.set(json["last_login_at"].intValue, forKey: "token_date")
                UserDefaults.standard.set(json["fc_account_id"].intValue,forKey: "collectu-accid")
                
                UserPreferences.accStatus = AccStatus.login.rawValue
 
                getAccountInfo(completion: { (success) in
                    if success {
                        completion(true,"")
                    } else {
                        completion(false,"ログインに失敗しました。ネットワークの状態を確認してください。")
                    }
                })
            case.failure(let error):
                print(error)
                completion(false,"ログインに失敗しました。ネットワークの状態を確認してください。")
            }
        }
    }
    
    //delete device
    static func onEraseDeviceToken(userName:String,userPass:String,deviceID:String,token:String,completion: @escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_ACC + "/token-set-expired"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "account_id": userName,
            "acc_password": userPass,
            "mac_address": deviceID,
            "token": token
        ]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if json.intValue == 1 {
                    completion(true,"Complete")
                } else {
                    completion(false,MSG_ALERT.kALERT_WRONG_PASSWORD)
                }
                
            case.failure(let error):
                print(error)
                completion(false,MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Account
    //*****************************************************************
    
    //Send Email
    static func onSendEmailStorageExtend(account:AccountData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STORAGE_EXTEND
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["account_id": account.account_id,
                          "account_name": account.acc_name] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Genealogy
    static func onGetGenealogy(accountID:Int,completion:@escaping(JSON) -> ()) {
        
        let url = kAPI_URL + kAPI_ACC_GENEALOGY + "/\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                completion(json)
            case.failure(let error):
                print(error)
                completion(JSON())
            }
        }
    }
    
    //Get Account Hierarchy
    static func onGetRootAccount(accountID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_ACC_ROOT + "/\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                if response.result.description == "SUCCESS" {
                    GlobalVariables.sharedManager.account_chat = data as? String
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Account Hierarchy
    static func getAccountHierarchy(accountID:Int,completion: @escaping TreeDataCompletion) {
        
        let url = kAPI_URL + kAPI_ACC_HIERARCHY + "/\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            var accTree = [AccTreeData]()
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        accTree.append(DBManager.getAccountTreeData(data: json[i]))
                    }
                }
                completion(true,accTree)
            case.failure(let error):
                print(error)
                completion(false,accTree)
            }
        }
    }
    
    //Get Account Hierarchy wAlliance
    static func getAccountHierarchyWithAllianceWithoutSelf(accountID:Int,completion: @escaping TreeDataCompletion) {
        
        let url = kAPI_URL + kAPI_ACC_HIERARCHY_PLUS_ALLIANCE + "/\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            var accTree = [AccTreeData]()
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    for i in 0 ..< json.count {
                        accTree.append(DBManager.getAccountTreeDataWithoutSelf(data: json[i]))
                    }
                }
                completion(true,accTree)
            case.failure(let error):
                print(error)
                completion(false,accTree)
            }
        }
    }
    
    //Get Account Hierarchy wAlliance
    static func getAccountHierarchyWithAlliance(accountID:Int,completion: @escaping TreeDataCompletion) {
        
        let url = kAPI_URL + kAPI_ACC_HIERARCHY_PLUS_ALLIANCE + "/\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            var accTree = [AccTreeData]()
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    for i in 0 ..< json.count {
                        accTree.append(DBManager.getAccountTreeData(data: json[i]))
                    }
                }
                completion(true,accTree)
            case.failure(let error):
                print(error)
                completion(false,accTree)
            }
        }
    }
    
    //Update Account Secret Memo Pass
    static func getAccountInfo(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_ACC
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    DBManager.getAccountData(data: json[0])
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Update Account Memo Pass
    static func updateAccountPass(currentP:String,newP:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_ACC + "/reset-password"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "old_password": currentP,
            "new_password": newP,
            "confirm_new_password": newP
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if json.count > 0 {
                    completion(false)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Update Account Favorite Colors
    static func updateAccountFavoriteColors(accountID:Int,favColors:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_ACC + "/\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "favorite_colors": favColors
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    DBManager.getAccountData(data: json)
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Update Account Secret Memo Pass
    static func updateAccountSecretMemoPass(password:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_ACC + "/update-secret-memo-password"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "password": password
        ]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Customers
    //*****************************************************************
    
    //Check Customer Record
    static func onSwitchCustomerOwner(newAccount:Int,customer_id:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CUS + "/change-account"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
        "new_account": newAccount,
        "customer_id": customer_id
        ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(_ ):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Check Customer Record
    static func onCheckCustomerData(cusID:Int,update:Int,completion:@escaping(_ status: Int,CustomerData)->()) {
        
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    //same update date as server
                    if json["updated_at"].intValue == update {
                        completion(1,DBManager.getACustomerData(data: json))
                    } else {
                        completion(2,DBManager.getACustomerData(data: json))
                    }
                } else {
                    completion(0,CustomerData())
                }
            case.failure(let error):
                print(error)
                completion(0,CustomerData())
            }
        }
    }
    
    //View Customer
    static func onViewCustomer(cusID:Int,completion: @escaping CusDataCompletion) {
        
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=fcSecretMemos"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    completion(true,DBManager.getACustomerData(data: json))
                } else {
                    completion(false,CustomerData())
                }
            case.failure(let error):
                print(error)
                completion(false,CustomerData())
            }
        }
    }
    
    //Get Customers
    //--All
    static func onGetAllCustomers(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CUS + "/get-all?expand=fcAccount"

        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getCustomerData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //--onGet all customer with pagination
    static func onGetAllCustomersPagination(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CUS + "/get-with-pagination?expand=fcAccount"

        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getCustomerData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //--All (Included Customer Status)
    static func onGetAllCustomersWithStatus(cusStatus:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = ""
        if let status = cusStatus {
            url = kAPI_URL + kAPI_CUS + "/get-by-status?customer_status=\(status)&expand=fcAccount,fcSecretMemos"
        } else {
            url = kAPI_URL + kAPI_CUS + "/get-by-status?expand=fcAccount,fcSecretMemos"
        }
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getCustomerData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //--By Pagination
    static func getCustomers(page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "?expand=fcSecretMemos"
        
        if page != nil {
            url.append("&page=\(page!)")
        } else {
            url.append("&page=1")
        }
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    //for pagination
                    if let currTemp = GlobalVariables.sharedManager.pageCurrTemp {
                        if GlobalVariables.sharedManager.pageCurr! < currTemp {
                            getCustomers(page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                        } else {
                            completion(true)
                        }
                    } else {
                        completion(true)
                    }
                    
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Customer
    static func addCustomer(first_name:String,last_name:String,first_name_kana:String,last_name_kana:String,gender:Int,bloodtype:Int,avatar_image:Data?,birthday:Int,hobby:String,email:String,postal_code:String,address1:String,address2:String,address3:String,responsible:String,mail_block:Int,urgent_no:String,memo1:String,memo2:String,cusNo:String,cusStatus:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        var res = ""
        if responsible != "未登録" {
            res = responsible
        }
        let parameters = [
            "first_name": first_name,
            "last_name": last_name,
            "first_name_kana": first_name_kana,
            "last_name_kana": last_name_kana,
            "gender": gender,
            "bloodtype": bloodtype,
            "birthday": birthday,
            "hobby": hobby,
            "email": email,
            "postal_code": postal_code,
            "address1": address1,
            "address2": address2,
            "address3": address3,
            "responsible": res,
            "mail_block": mail_block,
            "urgent_no": urgent_no,
            "memo1": memo1,
            "memo2": memo2,
            "customer_no":cusNo,
            "customer_status":cusStatus
            ] as [String : Any]
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let avatar = avatar_image {
                multipartFormData.append(avatar, withName: "avatar_image", fileName: "avatar.jpg", mimeType: "image/jpg")
            }
            
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success( _):
                        completion(true)
                    case.failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //Edit Customer Info
    static func editCustomerInfo(cusID:Int,first_name:String,last_name:String,first_name_kana:String,last_name_kana:String,gender:Int,bloodtype:Int,birthday:Int,hobby:String,email:String,postal_code:String,address1:String,address2:String,address3:String,responsible:String,mail_block:Int,urgent_no:String,memo1:String,memo2:String,cusNo:String,cusStatus:Int,completion: @escaping CusDataCompletion) {
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=fcSecretMemos"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        var res = ""
        if responsible != "未登録" {
            res = responsible
        }
        
        let parameters = [
            "first_name": first_name,
            "last_name": last_name,
            "first_name_kana": first_name_kana,
            "last_name_kana": last_name_kana,
            "gender": gender,
            "bloodtype": bloodtype,
            "birthday": birthday,
            "hobby": hobby,
            "email": email,
            "postal_code": postal_code,
            "address1": address1,
            "address2": address2,
            "address3": address3,
            "responsible": res,
            "mail_block": mail_block,
            "urgent_no": urgent_no,
            "memo1": memo1,
            "memo2": memo2,
            "customer_no":cusNo,
            "customer_status":cusStatus
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    completion(true,DBManager.getACustomerData(data: json))
                } else {
                    completion(false,CustomerData())
                }
            case.failure(let error):
                print(error)
                completion(false,CustomerData())
            }
        }
    }
    
    //Edit customer info with Avatar
    static func editCustomerInfowAvatar(cusID:Int,first_name:String,last_name:String,first_name_kana:String,last_name_kana:String,gender:Int,bloodtype:Int,avatar_image:Data,birthday:Int,hobby:String,email:String,postal_code:String,address1:String,address2:String,address3:String,responsible:String,mail_block:Int,urgent_no:String,memo1:String,memo2:String,cusNo:String,cusStatus:Int,completion: @escaping CusDataCompletion) {
        let url = kAPI_URL + kAPI_CUS + "/update-with-avatar?id=\(cusID)?expand=fcSecretMemos"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        var res = ""
        if responsible != "未登録" {
            res = responsible
        }
        let parameters = [
            "first_name": first_name,
            "last_name": last_name,
            "first_name_kana": first_name_kana,
            "last_name_kana": last_name_kana,
            "gender": gender,
            "bloodtype": bloodtype,
            "birthday": birthday,
            "hobby": hobby,
            "email": email,
            "postal_code": postal_code,
            "address1": address1,
            "address2": address2,
            "address3": address3,
            "responsible": res,
            "mail_block": mail_block,
            "urgent_no": urgent_no,
            "memo1": memo1,
            "memo2": memo2,
            "customer_no":cusNo,
            "customer_status":cusStatus
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            multipartFormData.append(avatar_image, withName: "avatar_image", fileName: "avatar.jpg", mimeType: "image/jpg")
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case.success(let data):
                        let json = JSON(data)
                        if (json.count > 0) {
                            completion(true,DBManager.getACustomerData(data: json))
                        } else {
                            completion(false,CustomerData())
                        }
                    case.failure(let error):
                        print(error)
                        completion(false,CustomerData())
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false,CustomerData())
            }
        }
    }
    
    static func onUpdateCustomer(customer:CustomerData,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS + "/\(customer.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "first_name": customer.first_name,
            "last_name": customer.last_name,
            "first_name_kana": customer.first_name_kana,
            "last_name_kana": customer.last_name_kana,
            "gender": customer.gender,
            "bloodtype": customer.bloodtype,
            "birthday": customer.birthday,
            "hobby": customer.hobby,
            "email": customer.email,
            "postal_code": customer.postal_code,
            "address1": customer.address1,
            "address2": customer.address2,
            "address3": customer.address3,
            "responsible": customer.responsible,
            "mail_block": customer.mail_block,
            "urgent_no": customer.urgent_no,
            "memo1": customer.memo1,
            "memo2": customer.memo2,
            "customer_no":customer.customer_no,
            "cus_dialogID":customer.cus_dialogID,
            "cus_msg_inbox":customer.cus_msg_inbox
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onUpdateNewMessageCustomer(customer:CustomerData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CUS + "/\(customer.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = ["cus_msg_inbox":customer.cus_msg_inbox] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Customer
    static func deleteCustomer(ids:[Int],completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS + "/bulk-delete"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = ["ids":ids]
        
        AFManager.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(_ ):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Cartes
    //*****************************************************************
    
    //Get All Cartes
    static func getAllCartesWithCustomerInfo(page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CARTE + "?expand=fcCustomer"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
            
            // Now filter the array, searching for your header-key, also lowercased
            if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
                GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
            } else {
                GlobalVariables.sharedManager.pageTotal = 1
            }
            
            //get total customer
            if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
                GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
            } else {
                GlobalVariables.sharedManager.totalCus = 0
            }
            
            //get current page
            if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
                GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
            } else {
                GlobalVariables.sharedManager.pageCurr = 1
            }
            
            switch(response.result) {
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCartesDataWithCustomer(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        getAllCartesWithCustomerInfo(page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Cartes
    static func getCustomerCartesByMonth(accID:Int?,month:String,completion:@escaping(Bool) -> ()) {
        
        var url = ""
        if (accID != nil) {
            url = kAPI_URL + kAPI_CARTE + "/filter-by-month?expand=fcCustomer,fcAccount&month=\(month)&account_id=\(accID!)"
        } else {
            url = kAPI_URL + kAPI_CARTE + "/filter-by-month?expand=fcCustomer,fcAccount&month=\(month)"
        }
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(CarteData.self))
                }
                
                let json = JSON(data)
                if (json.count > 0) {
                    for i in 0 ..< json.count {
                        DBManager.getCartesDataWithCustomer(data: json[i])
                    }
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Cartes
    static func getCustomerCartesWithDocument(carteID:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcDocuments"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    let doc = json["fcDocuments"]
                    for i in 0 ..< doc.count {
                        DBManager.getDocumentsData(data: doc[i])
                    }
                }
                
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Cartes with Memo
    static func getCustomerCartesWithMemos(cusID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=customerCartesWithMemos"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(CarteData.self))
                }
                
                let json = JSON(data)
                if (json.count > 0) {
                    let cart = json["customerCartesWithMemos"]
                    for i in 0 ..< cart.count {
                        DBManager.getCartesDataWithMemo(data: cart[i])
                    }
                    completion(true)
                } else {
                    
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Cartes with Media
    static func getCustomerCartesWithMedias(cusID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=customerCartesWithMemos,fcUserMedias"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    let cart = json["customerCartesWithMemos"]
                    for i in 0 ..< cart.count {
                        DBManager.getCartesDataWithMedias(data: cart[i])
                    }
                    completion(true)
                } else {
                    
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Cartes
    static func addCarte(cusID:Int,date:Int,staff_name:String,bed_name:String,mediaData:Data?,completion:@escaping(_ status: Int) -> ()) {
        
        let url = kAPI_URL + kAPI_CARTE
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
        "fc_customer_id": cusID,
        "FcCustomerCarte[select_date]": date,
        "FcCustomerCarte[bed_name]":bed_name,
        "FcCustomerCarte[staff_name]":staff_name] as [String: Any]
        
        if let mediaData = mediaData {
            AFManager.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(mediaData, withName: "media_files",fileName: "media.jpg", mimeType: "image/jpg")
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                } //Optional for extra parameters
            }, to:url,method: .post, headers: headers) { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        switch(response.result) {
                        case .success( _):
                            if let httpStatusCode = response.response?.statusCode {
                                switch(httpStatusCode) {
                                case 200:
                                    //ok
                                    completion(1)
                                case 406:
                                    //not found
                                    completion(2)
                                default:
                                    completion(0)
                                    break
                                }
                            }
                        case.failure( _):
                            completion(0)
                        }
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    completion(0)
                }
            }
        } else {
            AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
                switch(response.result) {
                case.success( _):
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 200:
                            //ok
                            completion(1)
                        case 406:
                            //not found
                            completion(2)
                        default:
                            completion(0)
                            break
                        }
                    } else {
                        completion(0)
                    }
                case.failure(let error):
                    print(error)
                    completion(0)
                }
            }
        }
    }
    
    //Add Cartes
    static func addCarteWithIDReturn(cusID:Int,date:Int,completion:@escaping(_ carteID: Int) -> ()) {
        let url = kAPI_URL + kAPI_CARTE
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "fc_customer_id": cusID,
            "FcCustomerCarte[select_date]": date,
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            var id = 0
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    id = json["id"].intValue
                    completion(id)
                } else {
                    completion(id)
                }
            case.failure(let error):
                print(error)
                completion(id)
            }
        }
    }
    
    //Add Carte with Media Data
    static func onAddCarteWithMedias(cusID:Int,date:Int,mediaData:Data,completion:@escaping(_ status: Int,CarteData)->()) {
        
        let url = kAPI_URL + kAPI_CARTE
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "fc_customer_id": cusID,
            "FcCustomerCarte[select_date]": date,
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(mediaData, withName: "media_files",fileName: "media.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    switch(response.result) {
                    case .success(let data):
                        if let httpStatusCode = response.response?.statusCode {
                            switch(httpStatusCode) {
                            case 200:
                                let json = JSON(data)
                                if (json.count > 0) {
                                    completion(1,DBManager.getCartesData(data: json))
                                }
                            case 406:
                                completion(2,CarteData())
                            default:
                                completion(0,CarteData())
                                break
                            }
                        }
                    case.failure( _):
                        completion(0,CarteData())
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(0,CarteData())
            }
        }
    }
    
    //Edit Carte Photo Representative
    static func onEditCarte(carteID:Int,date:Int,staff_name:String,bed_name:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CARTE + "/\(carteID)"
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "FcCustomerCarte[select_date]": date,
            "FcCustomerCarte[bed_name]":bed_name,
            "FcCustomerCarte[staff_name]":staff_name
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                _ = JSON(data)
                completion(true)
                
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Edit Carte Photo Representative
    static func onEditCartePhotoRepresentative(carteID:Int,mediaURL:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CARTE + "/\(carteID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "FcCustomerCarte[carte_photo]": mediaURL
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                _ = JSON(data)
                completion(true)
                
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Carte Photo Representative
    static func onDeleteCartePhotoRepresentative(carteID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CARTE_CLEAR_AVATAR + "/\(carteID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.request(url, method: .put, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Cartes
    static func deleteCarte(ids:[Int],completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CARTE + "/bulk-delete"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = ["ids":ids]
        
        AFManager.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //get stamp from carte
    static func onGetStampFromCarte(carteID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcFreeMemos,fcStampMemos"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
                
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(StampMemoData.self))
                }
                
                let json = JSON(data)
                if (json.count > 0) {
                    
                    let sm = json["fcStampMemos"]
                    for i in 0 ..< sm.count {
                        DBManager.getStampMemosData(data: sm[i])
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Media
    //*****************************************************************
    
    //Get Medias by Account
    static func onGetAllMedias(completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_MEDIA
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Media by Customer
    static func getCustomerMedias(cusID:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=mediaInCartes"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for (key, subJson) in json["mediaInCartes"] {
                        DBManager.getMediasDataCus(data: subJson ,date: key)
                    }
                    completion(true)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Medias by Carte
    static func getCarteMedias(carteID:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcUserMedias"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    let media = json["fcUserMedias"]
                    for i in 0 ..< media.count {
                        DBManager.getMediasData(data: media[i])
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //get carte with thumb data
    static func onGetCarteMedias(carteID:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcUserMedias"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    let media = json["fcUserMedias"]
                    for i in 0 ..< media.count {
                        DBManager.getMediasData(data: media[i])
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Media
    static func addMedias(cusID:Int,carteID:Int,mediaData:Data,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CARTE + "/media"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "fc_customer_id": cusID
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(mediaData, withName: "media_files",fileName: "media.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        
                        if (json.count > 0) {
                            let data = json[0]
                            let id = data["id"].intValue
                            
                            SVProgressHUD.showProgress(0.6, status: "サーバーにアップロード中:60%")
                            
                            addMediaIntoCarte(carteID: carteID, mediaID: id, completion: { (success) in
                                
                                SVProgressHUD.showProgress(0.8, status: "サーバーにアップロード中:80%")
                                
                                if success {
                                    completion(true)
                                } else {
                                    completion(false)
                                }
                            })
                        } else {
                            completion(false)
                        }
                    case.failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //updateMediaIntoCarte
    static func addMediaIntoCarte(carteID:Int,mediaID:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_MEDIA + "/\(mediaID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "fc_customer_carte_id": carteID
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Cartes
    static func deleteMedias(ids:[Int],completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_MEDIA + "/bulk-delete"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = ["ids":ids]
        
        AFManager.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Media New
    static func onAddMediaIntoCarte(carteID:Int,mediaData:Data,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CARTE + "/media-to-carte"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "fc_customer_carte_id": carteID
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            multipartFormData.append(mediaData, withName: "media_files", fileName: "doc.jpg", mimeType: "image/jpg")
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        
                        if (json.count > 0) {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    case.failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //Add MultiMedia Into Carte
    static func onAddMultiMediasIntoCarte(carteID:Int,mediaData:[Data],progressHandler:@escaping(Double) -> (),completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CARTE + "/media-to-carte"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "fc_customer_carte_id": carteID
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            for (index,image) in mediaData.enumerated() {
                multipartFormData.append(image, withName: "media_files[\(index)]", fileName: "picture\(index).jpg", mimeType: "image/jpg")
            }
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    progressHandler(progress.fractionCompleted)
                })
                upload.responseJSON { response in
                    
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        
                        if (json.count > 0) {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    case.failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Memos
    //*****************************************************************
    
    //View Carte Free Memo
    static func onCheckCarteFreeMemoData(memoID:Int,update:Int,completion:@escaping(Int) -> ()) {
        let url = kAPI_URL + kAPI_FREE_MEMO + "/\(memoID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    //same update date as server
                    if json["updated_at"].intValue == update {
                        completion(1)
                    } else {
                        completion(2)
                    }
                } else {
                    completion(0)
                }
            case.failure(let error):
                print(error)
                completion(0)
            }
        }
    }
    
    //Edit Carte Memo
    static func onEditCarteFreeMemo(memoID:Int,title:String,content:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_FREE_MEMO + "/\(memoID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "title":title,
            "content":content
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //delete carte free memo
    static func deleteCarteFreeMemo(memoID:Int,completion:@escaping(Int) -> ()) {
        
        let url = kAPI_URL + kAPI_FREE_MEMO + "/\(memoID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(1)
                    case 204:
                        //ok
                        completion(1)
                    case 404:
                        //not found
                        completion(2)
                    default:
                        completion(0)
                        break
                    }
                }
            case.failure(let error):
                print(error)
                completion(0)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Search
    //*****************************************************************
    
    //Get Syllabary
    static func onSearchSyllabary(characters:[String],page:Int?,completion:@escaping(Bool) -> ()) {
        var searchParams = ""
        for i in 0 ..< characters.count {
            var stringS = ""
            if i == 0 {
                stringS = "last_name_kana[]=" + characters[i]
            } else {
                stringS = "&last_name_kana[]=" + characters[i]
            }
            searchParams.append(stringS)
        }
        
        var url = kAPI_URL + kAPI_CUS_SEARCH + "?" + searchParams
        if page != nil {
            url.append("&page=\(page!)")
        }
        url.append("&expand=fcAccount")
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(CustomerData.self))
                }
                
                let json = JSON(data)
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchSyllabary(characters: characters, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Mobile
    static func onSearchName(LName1:String,FName1:String,LNameKana1:String,FNameKana1:String,LName2:String,FName2:String,LNameKana2:String,FNameKana2:String,LName3:String,FName3:String,LNameKana3:String,FNameKana3:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var searchParams = "?search_by_carte=true"
        if LName1 != "" {
            let stringS = "&last_name_1=" + LName1
            searchParams.append(stringS)
        }
        if FName1 != "" {
            let stringS = "&first_name_1=" + FName1
            searchParams.append(stringS)
        }
        if LNameKana1 != "" {
            let stringS = "&last_name_kana_1=" + LNameKana1
            searchParams.append(stringS)
        }
        if FNameKana1 != "" {
            let stringS = "&first_name_kana_1=" + FNameKana1
            searchParams.append(stringS)
        }
        if LName2 != "" {
            let stringS = "&last_name_2=" + LName2
            searchParams.append(stringS)
        }
        if FName2 != "" {
            let stringS = "&first_name_2=" + FName2
            searchParams.append(stringS)
        }
        if LNameKana2 != "" {
            let stringS = "&last_name_kana_2=" + LNameKana2
            searchParams.append(stringS)
        }
        if FNameKana2 != "" {
            let stringS = "&first_name_kana_2=" + FNameKana2
            searchParams.append(stringS)
        }
        if LName3 != "" {
            let stringS = "&last_name_3=" + LName3
            searchParams.append(stringS)
        }
        if FName3 != "" {
            let stringS = "&first_name_3=" + FName3
            searchParams.append(stringS)
        }
        if LNameKana3 != "" {
            let stringS = "&last_name_kana_3=" + LNameKana3
            searchParams.append(stringS)
        }
        if FNameKana3 != "" {
            let stringS = "&first_name_kana_3=" + FNameKana3
            searchParams.append(stringS)
        }
        
        var url = kAPI_URL + kAPI_CUS_SEARCH + searchParams
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }
        
        AFManager.request(encodedURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchName(LName1: LName1, FName1: FName1, LNameKana1: LNameKana1, FNameKana1: FNameKana1, LName2: LName2, FName2: FName2, LNameKana2: LNameKana2, FNameKana2: FNameKana2, LName3: LName3, FName3: FName3, LNameKana3: LNameKana3, FNameKana3: FNameKana3, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Mobile
    static func onSearchMobile(mobileNo:[String], page:Int?, completion:@escaping(Bool) -> ()) {
        
        var searchParams = ""
        for i in 0 ..< mobileNo.count {
            var stringS = ""
            if i == 0 {
                stringS = "urgent_no[]=" + mobileNo[i]
            } else {
                stringS = "&urgent_no[]=" + mobileNo[i]
            }
            
            searchParams.append(stringS)
        }
        
        var url = kAPI_URL + kAPI_CUS_SEARCH + "?" + searchParams
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchMobile(mobileNo: mobileNo, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Date
    static func onSearchDate(params:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS_SEARCH + params
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchDate(params: params, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onSearchSelectedDate(params:String,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS_SELECT_DATE_SEARCH + params
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            Utils.onConvertHeaderResult(res: responseR)
            switch(response.result) {
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(CustomerData.self))
                }
                let json = JSON(data)
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    completion(true)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Frequency
    static func onSearchFrequency(params:String,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/search-by-frequency?" + params
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Interval
    static func onSearchInterval(params:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/search-by-last-back?" + params
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
            
            // Now filter the array, searching for your header-key, also lowercased
            if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
                GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
            } else {
                GlobalVariables.sharedManager.pageTotal = 1
            }
            
            //get total customer
            if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
                GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
            } else {
                GlobalVariables.sharedManager.totalCus = 0
            }
            
            //get current page
            if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
                GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
            } else {
                GlobalVariables.sharedManager.pageCurr = 1
            }
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchInterval(params: params, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Gender
    static func onSearchGender(gender:Int,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?" + "gender=\(gender)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchGender(gender: gender, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Number
    static func onSearchCustomerNumber(customerNo:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?" + "customer_no=\(customerNo)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchCustomerNumber(customerNo: customerNo, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Responsible Number
    static func onSearchResponsiblePerson(name:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?" + "responsible=\(name)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchResponsiblePerson(name: name, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Note
    static func onSearchCustomerNote(memo1:String,memo2:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?memo1=\(memo1)&memo2=\(memo2)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchCustomerNote(memo1: memo1, memo2: memo2, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Birthday
    static func onSearchCustomerBirthday(day:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?" + "birthday=\(day)&birthday_format=d-m-Y"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchCustomerBirthday(day: day, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Birthday Month 2 Month
    static func onSearchCustomerBirthdayM2M(month1:String,month2:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?" + "search_by_birth_month=true&from_month=\(month1)&to_month=\(month2)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchCustomerBirthdayM2M(month1: month1, month2: month2, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Birthday Year 2 Year
    static func onSearchCustomerBirthdayY2Y(year1:String,year2:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?" + "search_by_birth_year=true&from_year=\(year1)&to_year=\(year2)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchCustomerBirthdayY2Y(year1: year1, year2: year2, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Address
    static func onSearchCustomerAddress(address:String,page:Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_CUS + "/new-search?" + "full_address=\(address)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        url.append("&expand=fcAccount")
        
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        
        AFManager.request(encodedURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getCustomerData(data: json[i])
                    }
                    
                    if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                        APIRequest.onSearchCustomerAddress(address: address, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Secret Memo
    static func onSearchCustomerSecretMemo(content:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS + "/search-by-secret-memo?query=\(content)" + "&expand=fcCustomer,fcAccount"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
       
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        
        AFManager.request(encodedURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    let user = json[i]["fcCustomer"]
                    DBManager.getCustomerData(data: user)
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Search Customer Free Memo
    static func onSearchCustomerFreeMemo(content:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS + "/search-by-free-memo?query=\(content)" + "&expand=fcCustomer,fcAccount"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
       
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        
        AFManager.request(encodedURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    let user = json[i]["fcCustomer"]
                    DBManager.getCustomerData(data: user)
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onSearchCustomerStampMemo(content:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS + "/search-by-stamp-memo?query=\(content)" + "&expand=fcCustomer,fcAccount"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
       
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        
        AFManager.request(encodedURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    let user = json[i]["fcCustomer"]
                    DBManager.getCustomerData(data: user)
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Stamp Memo and Keyword
    //*****************************************************************
    
    //Check Carte Stamp Memo
    static func onCheckCarteStampMemoData(memoID:Int,update:Int,completion:@escaping(Int) -> ()) {
        let url = kAPI_URL + kAPI_STAMP_MEMO + "/\(memoID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    //same update date as server
                    if json["updated_at"].intValue == update {
                        completion(1)
                    } else {
                        completion(2)
                    }
                } else {
                    completion(0)
                }
            case.failure(let error):
                print(error)
                completion(0)
            }
        }
    }
    
    //On View Stamp Memo
    static func onViewStampMemo(memoID:Int,completion:@escaping StampMemoDataCompletion) {
        let url = kAPI_URL + kAPI_STAMP_MEMO + "/\(memoID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    completion(true,DBManager.getStampMemoDataAndReturn(data: json))
                } else {
                    completion(false,StampMemoData())
                }
            case.failure(let error):
                print(error)
                completion(false,StampMemoData())
            }
        }
    }
    
    //Edit Carte Stamp Memo
    static func editCarteStampMemo(stampID:Int,content:String,completion:@escaping StampMemoDataCompletion) {
        let url = kAPI_URL + kAPI_STAMP_MEMO + "/\(stampID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "content":content
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    completion(true,DBManager.getStampMemoDataAndReturn(data: json))
                } else {
                    completion(false,StampMemoData())
                }
            case.failure(let error):
                print(error)
                completion(false,StampMemoData())
            }
        }
    }
    
    //add stamp category
    static func onAddNewStampCategory(name:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAMP_CATEGORY
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "name": name
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if ((json.dictionary?.count) != nil) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //get stamp category based on dynamic and static
    static func onGetStampCategoryDynamicOrStatic(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAMP_CATEGORY + "/get-dynamics"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(StampCategoryData.self))
                }
                let json = JSON(data)
                if (json.count > 0) {
                    for i in 0 ..< json.count {
                        DBManager.onGetStampCategoriesAndKeywords(data: json[i])
                    }
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //get stamp category
    static func onGetStampCategory(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAMP_CATEGORY
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    
                    for i in 0 ..< json.count {
                        DBManager.getStampCategoryData(data: json[i])
                    }
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Edit Stamp Category
    static func editStampCategoryTitle(categoryID:Int,title:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_STAMP_CATEGORY + "/\(categoryID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "title":title
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                _ = JSON(data)
                
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //check stamp content is exist or not
    static func checkStampMemoExist(stampID: Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAMP_MEMO + "/\(stampID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if json.count > 0 {
                    if json["content"].stringValue != "" {
                        completion(false)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //get content of stamp
    static func onGetContentFromStamp(stampID: Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAMP_MEMO + "/\(stampID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(StampContentData.self))
                }
                let json = JSON(data)
                for i in 0 ..< json["fcKeyword"].count {
                    DBManager.getStampContent(data: json["fcKeyword"][i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //get key of stamp
    static func onGetKeyFromCategory(categoryID: Int,page: Int?,completion:@escaping(Bool) -> ()) {
        
        var url = kAPI_URL + kAPI_KEYWORD + "?category_id=\(categoryID)"
        
        if page != nil {
            url.append("&page=\(page!)")
        }
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        AFManager.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            guard let responseR = response.response else {
                completion(false)
                return
            }
            
            Utils.onConvertHeaderResult(res: responseR)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                for i in 0 ..< json.count {
                    DBManager.getStampKeyword(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                    onGetKeyFromCategory(categoryID: categoryID, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //add stamp keyword data
    static func onAddKeywords(categoryID:Int,content:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_KEYWORD
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "category_id": categoryID,
            "content": content
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if ((json.dictionary?.count) != nil) {
                    completion(true)
                } else {
                    completion(false)
                }
                
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //edit stamp keyword data
    static func onEditKeyword(keywordID:Int,content:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_KEYWORD + "/\(keywordID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "content": content
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if ((json.dictionary?.count) != nil) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //delete keywords data
    static func onDeleteKeywords(keywordID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_KEYWORD + "/\(keywordID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Edit Stamp
    static func editStamp(stampID:Int,content:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_STAMP + "/\(stampID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "content":content
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //add stamp keywords
    static func onAddNewFreeMemo(carteID:Int,cusID:Int,title:String,content:String,position:Int,completion:@escaping(_ status: Int) -> ()) {
        
        let url = kAPI_URL + kAPI_FREE_MEMO
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "fc_customer_carte_id": carteID,
            "fc_customer_id": cusID,
            "title": title,
            "content": content,
            "position": position
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if json.count == 1 {
                    completion(2)
                } else if json.count > 1 {
                    completion(1)
                } else {
                    completion(0)
                }
            case.failure(let error):
                print(error)
                completion(0)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Secret Memo
    //*****************************************************************
    
    //Access Secret Memo
    static func getAccessSecretMemo(password:String,completion: @escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_ACC + "/secret-memo-auth"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "password": password
        ]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                let code = json["code"]
                if code == 0 {
                    completion(false,MSG_ALERT.kALERT_WRONG_PASSWORD)
                } else {
                    completion(true,MSG_ALERT.kALERT_UPDATE_SECRET_PASSWORD_SUCCESS)
                }
            case.failure(let error):
                print(error)
                completion(false,MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
        }
    }
    
    //Get Memos
    static func getCusSecretMemo(cusID:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=fcSecretMemos"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(SecretMemoData.self))
                }
                let json = JSON(data)
                if (json.count > 0) {
                    let memo = json["fcSecretMemos"]
                    for i in 0 ..< memo.count {
                        DBManager.getSecretMemoData(data: memo[i])
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Memos
    static func addSecretMemo(cusID:Int,content:String,auth:String,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_SECRET_MEMO
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear, "auth_password":auth]
        
        let parameters = [
            "fc_customer_id": cusID,
            "content":content
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                if ((json.dictionary?.count) != nil) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Edit Secret Memo
    static func editSecretMemo(secretID:Int,content:String,auth:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_SECRET_MEMO + "/\(secretID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear,"auth_password":auth]
        
        let parameters = [
            "content":content
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    completion(true)
                } else {
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Secret
    static func deleteSecretMemo(memoID:Int,auth:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_SECRET_MEMO + "/\(memoID)"

        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"auth_password":auth]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Documents
    //*****************************************************************
    
    //get all documents with custom option type
    static func onGetDocuments(accID:Int,type:Int,subtype:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_DOCUMENTS + "/search-by-account?fc_account_id=\(accID)&is_template=0&type=\(type)&sub_type=\(subtype)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                if (json.count > 0) {
                    completion(true)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //get all documents template from account
    static func onGetDocumentsTemplate(accID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_DOCUMENT + "/get-all-template"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(DocumentData.self))
                }
                
                let json = JSON(data)
                if (json.count > 0) {
                    for i in 0 ..< json.count {
                        if accID == json[i]["fc_account_id"].intValue {
                            DBManager.getDocumentsData(data: json[i])
                        }
                    }
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Document into Carte New
    static func onAddDocumentIntoCarte(documentID:Int,carteID:Int,doc:[Data],type:Int,subType:Int,completion:@escaping(Int) -> ()) {
        let url = kAPI_URL + kAPI_DOCUMENT + "/create-and-upload"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "fc_document_template_id": documentID,
            "fc_customer_carte_id": carteID,
            "is_template": 0,
            "type": type,
            "sub_type": subType
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            for (index,image) in doc.enumerated() {
                multipartFormData.append(image, withName: "media_files[\(index)]", fileName: "picture\(index).jpg", mimeType: "image/jpg")
            }
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success( _):
                        if let httpStatusCode = response.response?.statusCode {
                            switch(httpStatusCode) {
                            case 200:
                                //ok
                                completion(1)
                            case 400:
                                //exists
                                completion(2)
                            case 404:
                                //not found
                                completion(0)
                            default:
                                completion(0)
                                break
                            }
                        }
                    case.failure(let error):
                        print(error)
                        completion(0)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(0)
            }
        }
    }
    
    //Edit Documents Page in Carte New
    static func onEditDocumentInCarte(documentID:Int,doc:[Data],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_DOCUMENTS + "/update-document/\(documentID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (index,image) in doc.enumerated() {
                multipartFormData.append(image, withName: "media_files[\(index)]", fileName: "picture\(index).jpg", mimeType: "image/jpg")
            }
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error{
                        print(err)
                        completion(false)
                    }
                    completion(true)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //Add Documents to Carte
    static func addDocumentIntoCarte(documentID:Int,carteID:Int,completion:@escaping ArrayCompletion) {
        
        let url = kAPI_URL + kAPI_DOCUMENT + "/create-with-template"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "fc_document_template_id": documentID,
            "fc_customer_carte_id": carteID,
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if ((json.dictionary?.count) != nil) {
                    
                    let memo = json["fcDocumentPages"]
                    
                    completion(true,memo)
                } else {
                    
                    completion(false,JSON.null)
                }
                
            case.failure(let error):
                print(error)
                completion(false,JSON.null)
            }
        }
    }
    
    
    //Add Documents
    static func addDocument(cusID:Int,documentType:Int,docData:Data,page:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MEDIA
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "id": cusID
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            multipartFormData.append(docData, withName: "media_file", fileName: "doc.jpg", mimeType: "image/jpg")
            
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success(let data):
                        
                        // First make sure you got back a dictionary if that's what you expect
                        guard let json = data as? [String : AnyObject] else {
                            print("Failed to get expected response from webserver.")
                            completion(false)
                            return
                        }
                        
                        // Then make sure you get the actual key/value types you expect
                        guard let urlDoc = json["url"] as? String else {
                            print("Failed to get expected response from webserver.")
                            completion(false)
                            return
                        }
                        
                        APIRequest.addDocumentIntoCustomer(cusID: cusID, documentType: documentType, pageNo: page, urlD: urlDoc, completion: { (success) in
                            if success {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                        
                    case.failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //update Doc into customer
    static func addDocumentIntoCustomer(cusID:Int,documentType:Int,pageNo:Int,urlD:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CUS + "/\(cusID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        var doc = ""
        switch documentType {
        case 1:
            if pageNo == 1 {
                doc = "document_1"
            } else {
                doc = "document_2"
            }
        case 2:
            doc = "document_consent"
        default:
            break
        }
        let parameters = [
            doc : urlD
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    
                    completion(true)
                } else {
                    
                    completion(false)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Edit Documents Page
    static func editDocumentInCarteNew(document:DocumentData,imageData: [Data],page:Int,isEdited:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_DOCUMENT_PAGE + "/update-two/\(document.document_pages[page - 1].id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "page": page,
            "is_edited":isEdited
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            multipartFormData.append(imageData[page - 1], withName: "media_file", fileName: "doc.jpg", mimeType: "image/jpg")
            
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    if let err = response.error{
                        
                        print(err)
                        completion(false)
                    }
                    
                    if page < document.document_pages.count {
                        APIRequest.editDocumentInCarteNew(document: document,imageData: imageData,page: page + 1, isEdited: isEdited, completion: completion)
                    } else {
                        completion(true)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //Edit Documents Page
    static func editDocumentInCarte(documentPageID:Int,page:Int,imageData:Data,isEdited:Int,completion:@escaping(Bool) -> ()) {
        let url = kAPI_URL + kAPI_DOCUMENT_PAGE + "/update-two/\(documentPageID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "page": page,
            "is_edited":isEdited
            ] as [String : Any]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            multipartFormData.append(imageData, withName: "media_file", fileName: "doc.jpg", mimeType: "image/jpg")
            
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    switch(response.result) {
                    case .success( _):
                        completion(true)
                    case.failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - GB Storage
    //*****************************************************************
    
    //Count Storage
    static func countStorage(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MEDIA + "/check-store"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .post, parameters: nil, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                
                if (json.count > 0) {
                    if let maxSize = json["accountMaxSize"] as JSON? {
                        // access nested dictionary values by key
                        for (key, value) in maxSize {
                            // access all key / value pairs in dictionary
                            if key == "bytes" {
                                GlobalVariables.sharedManager.limitSize = value.int64Value
                            }
                        }
                    }
                    
                    if let maxSize = json["curentSize"] as JSON? {
                        // access nested dictionary values by key
                        for (key, value) in maxSize {
                            // access all key / value pairs in dictionary
                            if key == "bytes" {
                                GlobalVariables.sharedManager.currentSize = value.int64Value
                            }
                        }
                    }
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Videos
    //*****************************************************************
    
    static func onGetAllVideos(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_VIDEO
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getVideosData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Contract
    //*****************************************************************
    
    //Get all brochure Category
    static func onGetAllBrochure(cusID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "?customer_id=\(cusID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                if response.response?.statusCode == 404 {
                    completion(true)
                    return
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getBrochureData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Add Brochure
    static func onAddBrochure(accountID:Int,cusID:Int,date:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BROCHURE
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = ["account_id": accountID,
                          "customer_id": cusID,
                          "select_date": date] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Update Brochure
    static func onUpdateBrochure(brochureID:Int,cusName:String,admission:Int,course_total:Int,goods_total:Int,total:Int,confirm:Int,mship_start:Int,mship_end:Int,service_start:Int,service_end:Int,company_profile:Int,sub_company:Int,advance_pay:Int,used_item:String,used_item2:String,conserva:String,cusNote:String,total_tax:Int,contract_staff:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/update-brochure/\(brochureID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "user_name": cusName,
            "brochure_confirm": confirm,
            "admission_fee": admission,
            "cours_total":course_total,
            "goods_total":goods_total,
            "total":total,
            "mship_start_date":mship_start,
            "mship_end_date":mship_end,
            "service_start_date":service_start,
            "service_end_date":service_end,
            "company_profile":company_profile,
            "sub_company":sub_company,
            "advance_pay":advance_pay,
            "used_item":used_item,
            "used_item2":used_item2,
            "conserva":conserva,
            "note1":cusNote,
            "total_tax":total_tax,
            "contract_staff":contract_staff
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onUpdateBrochureData(brochure:BrochureData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/update-brochure/\(brochure.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
        "user_name": brochure.user_name,
        "admission_fee": brochure.admission_fee,
        "cours_total":brochure.cours_total,
        "goods_total":brochure.goods_total,
        "total":brochure.total,
        "mship_start_date":brochure.mship_start_date,
        "mship_end_date":brochure.mship_end_date,
        "service_start_date":brochure.service_start_date,
        "service_end_date":brochure.service_end_date,
        "company_profile":brochure.company_profile,
        "sub_company":brochure.sub_company,
        "advance_pay":brochure.advance_pay,
        "used_item":brochure.used_item,
        "used_item2":brochure.used_item2,
        "conserva":brochure.conserva,
        "note1":brochure.note1,
        "total_tax":brochure.total_tax,
        "contract_staff":brochure.contract_staff,
        "sum_notreat":brochure.sum_notreat,
        "sum_coursetime":brochure.sum_coursetime,
        "sum_nogoods":brochure.sum_nogoods] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Update Brochure Print Date
    static func onUpdateBrochurePrintDate(brochureID:Int,type:Int,date:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/update-brochure/\(brochureID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        var parameters = [String : Any]()
        if type == 1 {
            parameters = ["broch_print_date": date]
        } else {
            parameters = ["cont_print_date": date]
        }
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Course Category and Course
    //*****************************************************************
    
    //Get all course Category and course inside
    static func onGetAllCourseCategoriesAndCourses(accID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_CATEGORY + "?account_id=\(accID)&expand=fcMcourse"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(CourseCategoryData.self))
                    realm.delete(realm.objects(CourseData.self))
                    realm.delete(realm.objects(ProductData.self))
                }

                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getCourseCategoryAndCourseData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get all course Category
    static func onGetAllCourseCategory(accID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_CATEGORY + "?account_id=\(accID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(CourseCategoryData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getCourseCategoryData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Course Category
    static func onAddCourseCategory(courseCategory:CourseCategoryData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_CATEGORY
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["account_id": courseCategory.account_id,
                          "display_num": courseCategory.display_num,
                          "category_name": courseCategory.category_name] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Edit Course Category
    static func onUpdateCourseCategory(courseCategory:CourseCategoryData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_CATEGORY + "/\(courseCategory.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["category_name": courseCategory.category_name] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Course Category
    static func onDeleteCourseCategory(courseCategoryID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_CATEGORY + "/\(courseCategoryID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Swap Course Category
    static func onSwapCourseCategory(ids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_CATEGORY + "/update-display-num"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get all course
    static func onGetAllCourse(category_id:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE + "?category_id=\(category_id)&expand=fcGood"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getCourseData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Course
    static func onAddCourse(course:CourseData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["category_id": course.category_id,
                          "course_name": course.course_name,
                          "treatment_time": course.treatment_time,
                          "unit_price": course.unit_price,
                          "fee_rate": course.fee_rate,
                          "requir_items": course.requir_items,
                          "display_num": course.display_num] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //update course
    static func onUpdateCourse(course:CourseData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE + "/\(course.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["category_id": course.category_id,
                          "course_name": course.course_name,
                          "treatment_time": course.treatment_time,
                          "unit_price": course.unit_price,
                          "fee_rate": course.fee_rate,
                          "requir_items": course.requir_items,
                          "display_num": course.display_num] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Course
    static func onDeleteCourse(courseID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE + "/\(courseID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Swap Course
    static func onSwapCourse(type:Int,categoryID:Int,ids:[Int],oldids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        var url = ""
        var parameters = [String:Any]()
        
        if type == 1 {
            url = kAPI_URL + kAPI_COURSE + "/update-display-num"
            parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]
        } else {
            url = kAPI_URL + kAPI_COURSE + "/change-category-and-display-num"
            parameters = ["ids": ids,
                          "category_id": categoryID,
                          "old_ids": oldids] as [String : Any]
        }
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Product Category and Product
    //*****************************************************************
    
    //Get all course Category and course inside
    static func onGetAllProductCategoriesAndProducts(accID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT_CATEGORY + "?account_id=\(accID)&expand=fcGood"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getProductCategoryAndProductData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get all product Category
    static func onGetAllProductCategory(accID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT_CATEGORY + "?account_id=\(accID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getProductCategoryData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get all product
    static func onGetAllProduct(courseID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT + "?category_id=\(courseID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getProductData(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Product Category
    static func onAddProductCategory(productCategory:ProductCategoryData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT_CATEGORY
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["account_id": productCategory.account_id,
                          "display_num": productCategory.display_num,
                          "category_name": productCategory.category_name] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Edit Product Category
    static func onUpdateProductCategory(productCategory:ProductCategoryData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT_CATEGORY + "/\(productCategory.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["category_name": productCategory.category_name] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Product Category
    static func onDeleteProductCategory(productCategoryID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT_CATEGORY + "/\(productCategoryID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Swap Product Category
    static func onSwapProductCategory(ids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT_CATEGORY + "/update-display-num"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Product
    static func onAddProduct(product:ProductData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["category_id": product.category_id,
                          "item_category": product.item_category,
                          "item_name": product.item_name,
                          "unit_price": product.unit_price,
                          "fee_rate": product.fee_rate,
                          "display_num": product.display_num] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //update Product
    static func onUpdateProduct(product:ProductData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT + "/\(product.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["category_id": product.category_id,
                          "item_category": product.item_category,
                          "item_name": product.item_name,
                          "unit_price": product.unit_price,
                          "fee_rate": product.fee_rate ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Delete Product
    static func onDeleteProduct(productID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PRODUCT + "/\(productID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Swap Product
    static func onSwapProduct(type:Int,categoryID:Int,ids:[Int],oldids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        var url = ""
        var parameters = [String:Any]()
        
        if type == 1 {
            url = kAPI_URL + kAPI_PRODUCT + "/update-display-num"
            parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]
        } else {
            url = kAPI_URL + kAPI_PRODUCT + "/change-category-and-display-num"
            parameters = ["ids": ids,
                          "category_id": categoryID,
                          "old_ids": oldids] as [String : Any]
        }
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Company
    //*****************************************************************
    
    //Get Company Info
    static func onGetCompanyInfo(accID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COMPANY + "?account_id=\(accID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(CompanyData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getCompanyInfo(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Staff Info
    static func onGetStaffBasedOnPermissionAndCompany(companyID:Int,permission:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "?company_id=\(companyID)&permission=\(permission)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(StaffData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getStaffCompany(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Company Category
    static func onAddCompanyCategory(companyCategory:CompanyData,stampData:Data?,completion:@escaping(String) -> ()) {
        
        let url = kAPI_URL + kAPI_COMPANY
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["account_id": companyCategory.account_id,
                          "company_name": companyCategory.company_name,
                          "president_name": companyCategory.president_name,
                          "zip": companyCategory.zip,
                          "address1": companyCategory.address1,
                          "address2": companyCategory.address2,
                          "tel": companyCategory.tel] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            if let stampData = stampData {
                multipartFormData.append(stampData, withName: "stamp",fileName: "stamp.jpg", mimeType: "image/jpg")
            }
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        if json["stamp"].stringValue != "" {
                            completion(json["stamp"].stringValue)
                        } else {
                            completion("true")
                        }
                    case.failure( _):
                        completion("false")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion("false")
            }
        }
    }
    
    //Edit Product Category
    static func onUpdateCompanyCategory(companyCategory:CompanyData,stampData:Data?,completion:@escaping(String) -> ()) {
        
        let url = kAPI_URL + kAPI_COMPANY + "/update-c-company/\(companyCategory.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["company_name": companyCategory.company_name,
                          "president_name": companyCategory.president_name,
                          "zip": companyCategory.zip,
                          "address1": companyCategory.address1,
                          "address2": companyCategory.address2,
                          "tel": companyCategory.tel] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            if let stampData = stampData {
                multipartFormData.append(stampData, withName: "stamp",fileName: "stamp.jpg", mimeType: "image/jpg")
            }
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        if json["stamp"].stringValue != "" {
                            completion(json["stamp"].stringValue)
                        } else {
                            completion("true")
                        }
                    case.failure( _):
                        completion("false")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion("false")
            }
        }
    }
    
    //Delete Product Category
    static func onDeleteCompanyCategory(companyCategoryID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COMPANY + "/\(companyCategoryID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
           
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Swap Company Category
    static func onSwapCompanyCategory(ids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COMPANY + "/update-display-num"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Get Additional Info
    static func onGetAdditionalInfo(accountID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_ADDITION + "?account_id=\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(AdditionNoteData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getAdditionalInfo(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Update Additional Info
    static func onAddAdditionalInfo(additonalData:AdditionNoteData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + "v1/fc-cdetails"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["account_id": additonalData.account_id,
                          "advance_pay": additonalData.advance_pay,
                          "used_item": additonalData.used_item,
                          "used_item2": additonalData.used_item2,
                          "conserva": additonalData.conserva] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(AdditionNoteData.self))
                }
                
                let json = JSON(data)
                if json.count > 0 {
                    DBManager.getAdditionalInfo(data: json)
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Update Additional Info
    static func onUpdateAdditionalInfo(additonalData:AdditionNoteData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + "v1/fc-cdetails/\(additonalData.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["advance_pay": additonalData.advance_pay,
                          "used_item": additonalData.used_item,
                          "used_item2": additonalData.used_item2,
                          "conserva": additonalData.conserva] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(_):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on get Brochure without sign
    static func onGetBrochureWithoutSign(brochureID:Int,completion: @escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/export-pdf/\(brochureID)?type=2"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                completion(true,data as! String)
            case.failure(let error):
                print(error)
                completion(false,"")
            }
        }
    }
    
    //on get brochure with sign
    static func onGetBrochureWithSign(brochureID:Int,completion: @escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/export-pdf/\(brochureID)?type=1"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                completion(true,data as! String)
            case.failure(let error):
                print(error)
                completion(false,"")
            }
        }
    }
    
    //on get Contract without sign
    static func onGetContractWithoutSign(brochureID:Int,completion: @escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_CONTRACT + "/export-pdf/\(brochureID)?type=2"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                completion(true,data as! String)
            case.failure(let error):
                print(error)
                completion(false,"")
            }
        }
    }
    
    //on get Contract with sign
    static func onGetContractWithSign(brochureID:Int,completion: @escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_CONTRACT + "/export-pdf/\(brochureID)?type=1"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                completion(true,data as! String)
            case.failure(let error):
                print(error)
                completion(false,"")
            }
        }
    }
    
    //Add Company
    static func onAddContractCustomer(brochureID:Int,contractCus:ContractCustomerData,completion: @escaping IntCompletion) {
        
        let url = kAPI_URL + kAPI_CONTRACT_CUSTOMER
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "brochure_id": brochureID,
            "contract_date": contractCus.contract_date,
            "last_name": contractCus.last_name,
            "first_name": contractCus.first_name,
            "last_name_kana": contractCus.last_name_kana,
            "first_name_kana": contractCus.first_name_kana,
            "birthday": contractCus.birthday,
            "customer_no":contractCus.customer_no,
            "zip":contractCus.zip,
            "country":contractCus.country,
            "address1":contractCus.address1,
            "address2":contractCus.address2,
            "contract_url":contractCus.contract_url,
            "contract_signed_url":contractCus.contract_signed_url,
            "tel":contractCus.tel,
            "emergency_tel":contractCus.emergency_tel,
            "job":contractCus.job,
            "company_name":contractCus.company_name,
            "company_zip":contractCus.company_zip,
            "company_city":contractCus.company_city,
            "company_address1":contractCus.company_address1,
            "company_address2":contractCus.company_address2,
            "contract_representative":contractCus.contract_representative
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                let json = JSON(data)
                let id = json["id"].intValue
                completion(true,id)
            case.failure(let error):
                print(error)
                completion(false,0)
            }
        }
    }
    
    //Add Company
    static func onAddContractCompany(brochureID:Int,comData:CompanyData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CONTRACT_COMPANY
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "brochure_id": brochureID,
            "company_name": comData.company_name,
            "president_name": comData.president_name,
            "zip": comData.zip,
            "address1": comData.address1,
            "tel": comData.tel,
            "stamp": comData.stamp
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                _ = JSON(data)
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Company
    static func onAddSubCompany(brochureID:Int,comData:CompanyData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_CONTRACT_SUB_COMPANY
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [
            "brochure_id": brochureID,
            "company_name": comData.company_name,
            "president_name": comData.president_name,
            "zip": comData.zip,
            "address1": comData.address1,
            "tel": comData.tel
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(let data):
                _ = JSON(data)
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Course Order Data
    static func onAddCourseOrder(brochureID:Int,course:[CourseOrderData],index:Int,total:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_ORDER
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]

        GlobalVariables.sharedManager.courseIndex = index
    
        let parameters = [
            "brochure_id": brochureID,
            "course_name": course[index].course_name,
            "treatment_time": course[index].treatment_time,
            "unit_price": course[index].unit_price,
            "num_of_treat": course[index].num_of_treat,
            "total_time": course[index].total_time,
            "sub_total":course[index].sub_total,
            "index":course[index].index
            ] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success( _):
                if GlobalVariables.sharedManager.courseIndex! < total - 1 {
                    onAddCourseOrder(brochureID: brochureID, course: course, index: GlobalVariables.sharedManager.courseIndex! + 1, total: total, completion: completion)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Course Order Data
    static func onAddCourseOrderNew(brochureID:Int,course:[CourseOrderData],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COURSE_ORDER + "/create-bulk"
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]

        var course_names = [String]()
        var course_indexes = [Int]()
        var treatment_times = [Int]()
        var unit_prices = [Int]()
        var num_of_treats = [Int]()
        var total_times = [Int]()
        var sub_totals = [Int]()
        
        for i in 0 ..< course.count {
            course_names.append(course[i].course_name)
            course_indexes.append(course[i].index)
            treatment_times.append(course[i].treatment_time)
            unit_prices.append(course[i].unit_price)
            num_of_treats.append(course[i].num_of_treat)
            total_times.append(course[i].total_time)
            sub_totals.append(course[i].sub_total)
        }
        
        let parameters = [
            "brochure_id": brochureID,
            "course_name": course_names.joined(separator: ","),
            "index": course_indexes.map{String($0)}.joined(separator: ","),
            "treatment_time": treatment_times.map{String($0)}.joined(separator: ","),
            "unit_price": unit_prices.map{String($0)}.joined(separator: ","),
            "num_of_treat": num_of_treats.map{String($0)}.joined(separator: ","),
            "total_time": total_times.map{String($0)}.joined(separator: ","),
            "sub_total": sub_totals.map{String($0)}.joined(separator: ",")] as [String: Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Goods Order Data
    static func onAddGoodsOrder(brochureID:Int,goods:[ProductsOrderData],index:Int,total:Int,completion:@escaping(Bool) -> ()) {

        let url = kAPI_URL + kAPI_GOOD_ORDER
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]

        GlobalVariables.sharedManager.goodsIndex = index
        
        let parameters = [
            "brochure_id": brochureID,
            "item_name": goods[index].item_name,
            "item_category": goods[index].item_category,
            "unit_price": goods[index].unit_price,
            "num_of_goods": goods[index].num_of_goods,
            "sub_total": goods[index].sub_total,
            "tax_price":goods[index].tax_price,
            "goods_total":goods[index].goods_total,
            "index":goods[index].index
            ] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success( _):
                if GlobalVariables.sharedManager.goodsIndex! < total - 1 {
                    onAddGoodsOrder(brochureID: brochureID, goods: goods, index: GlobalVariables.sharedManager.goodsIndex! + 1, total: total, completion: completion)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onAddGoodsOrderNew(brochureID:Int,goods:[ProductsOrderData],completion:@escaping(Bool) -> ()) {

        let url = kAPI_URL + kAPI_GOOD_ORDER + "/create-bulk"
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]

        var item_names = [String]()
        var item_categories = [String]()
        var unit_prices = [Int]()
        var num_of_goods = [Int]()
        var sub_totals = [Int]()
        var tax_prices = [Int]()
        var goods_totals = [Int]()
        var goods_indexes = [Int]()
        
        for i in 0 ..< goods.count {
            item_names.append(goods[i].item_name)
            item_categories.append(goods[i].item_category)
            unit_prices.append(goods[i].unit_price)
            num_of_goods.append(goods[i].num_of_goods)
            sub_totals.append(goods[i].sub_total)
            tax_prices.append(goods[i].tax_price)
            goods_totals.append(goods[i].goods_total)
            goods_indexes.append(goods[i].index)
        }
        
        let parameters = [
            "brochure_id": brochureID,
            "item_name": item_names.joined(separator: ","),
            "item_category": item_categories.joined(separator: ","),
            "unit_price": unit_prices.map{String($0)}.joined(separator: ","),
            "num_of_goods": num_of_goods.map{String($0)}.joined(separator: ","),
            "sub_total": sub_totals.map{String($0)}.joined(separator: ","),
            "tax_price":tax_prices.map{String($0)}.joined(separator: ","),
            "goods_total":goods_totals.map{String($0)}.joined(separator: ","),
            "index":goods_indexes.map{String($0)}.joined(separator: ",")
            ] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Goods Order Data
    static func onAddSettlement(brochureID:Int,settlement:[SettlementData],index:Int,total:Int,completion:@escaping(Bool) -> ()) {

        let url = kAPI_URL + kAPI_SETTLEMENT
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]

        GlobalVariables.sharedManager.settlementIndex = index
        
        let parameters = [
            "brochure_id": brochureID,
            "display_num": settlement[index].display_num,
            "settlement_type": settlement[index].settlement_type,
            "institution_name": settlement[index].institution_name,
            "pay_type": settlement[index].pay_type,
            "settlement_date":settlement[index].settlement_date,
            "settlement_price":settlement[index].settlement_price,
            "settlement_count": settlement[index].settlement_count,
            "monthly_set_date": settlement[index].monthly_set_date,
            "monthly_set_price": settlement[index].monthly_set_price,
            "adjust_set_date":settlement[index].adjust_set_date,
            "adjust_set_price":settlement[index].adjust_set_price,
            "bonus_pay1":settlement[index].bonus_pay1,
            "bonus_date1":settlement[index].bonus_date1,
            "bonus_pay2":settlement[index].bonus_pay2,
            "bonus_date2":settlement[index].bonus_date2,
            "note":settlement[index].note,
            "index":settlement[index].index
            ] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(_ ):
                if GlobalVariables.sharedManager.settlementIndex! < total - 1 {
                    onAddSettlement(brochureID: brochureID, settlement: settlement, index: GlobalVariables.sharedManager.settlementIndex! + 1, total: total, completion: completion)
                } else {
                    completion(true)
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Goods Order Data
    static func onAddSettlementNew(brochureID:Int,settlement:[SettlementData],completion:@escaping(Bool) -> ()) {

        let url = kAPI_URL + kAPI_SETTLEMENT + "/create-bulk"
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]

        var display_num = [Int]()
        var settlement_type = [String]()
        var institution_name = [String]()
        var pay_type = [String]()
        var settlement_date = [Int]()
        var settlement_price = [Int]()
        var settlement_count = [Int]()
        var monthly_set_date = [Int]()
        var monthly_set_price = [Int]()
        var adjust_set_date = [Int]()
        var adjust_set_price = [Int]()
        var bonus_pay1 = [Int]()
        var bonus_date1 = [Int]()
        var bonus_pay2 = [Int]()
        var bonus_date2 = [Int]()
        var note = [String]()
        var index = [Int]()
        
        for i in 0 ..< settlement.count {
            display_num.append(settlement[i].display_num)
            settlement_type.append(settlement[i].settlement_type)
            institution_name.append(settlement[i].institution_name)
            pay_type.append(settlement[i].pay_type)
            settlement_date.append(settlement[i].settlement_date)
            settlement_price.append(settlement[i].settlement_price)
            settlement_count.append(settlement[i].settlement_count)
            monthly_set_date.append(settlement[i].monthly_set_date)
            monthly_set_price.append(settlement[i].monthly_set_price)
            adjust_set_date.append(settlement[i].adjust_set_date)
            adjust_set_price.append(settlement[i].adjust_set_price)
            bonus_pay1.append(settlement[i].bonus_pay1)
            bonus_date1.append(settlement[i].bonus_date1)
            bonus_pay2.append(settlement[i].bonus_pay2)
            bonus_date2.append(settlement[i].bonus_date2)
            note.append(settlement[i].note)
            index.append(settlement[i].index)
        }
        
        let parameters = [
            "brochure_id": brochureID,
            "display_num": display_num.map{String($0)}.joined(separator: ","),
            "settlement_type": settlement_type.joined(separator: ","),
            "institution_name": institution_name.joined(separator: ","),
            "pay_type": pay_type.joined(separator: ","),
            "settlement_date": settlement_date.map{String($0)}.joined(separator: ","),
            "settlement_price": settlement_price.map{String($0)}.joined(separator: ","),
            "settlement_count": settlement_count.map{String($0)}.joined(separator: ","),
            "monthly_set_date": monthly_set_date.map{String($0)}.joined(separator: ","),
            "monthly_set_price": monthly_set_price.map{String($0)}.joined(separator: ","),
            "adjust_set_date": adjust_set_date.map{String($0)}.joined(separator: ","),
            "adjust_set_price": adjust_set_price.map{String($0)}.joined(separator: ","),
            "bonus_pay1": bonus_pay1.map{String($0)}.joined(separator: ","),
            "bonus_date1": bonus_date1.map{String($0)}.joined(separator: ","),
            "bonus_pay2": bonus_pay2.map{String($0)}.joined(separator: ","),
            "bonus_date2": bonus_date2.map{String($0)}.joined(separator: ","),
            "note": note.joined(separator: ","),
            "index": index.map{String($0)}.joined(separator: ",")
            ] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
            case.success(_ ):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Brochure w Sign
    static func onAddBrochureSignature(brochureID:Int,signatureData:Data,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/update-brochure/\(brochureID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let parameters = ["broch_create_date": timestamp] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(signatureData, withName: "signed1",fileName: "signed1.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    switch(response.result) {
                    case .success( _):
                        completion(true)
                    case.failure( _):
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //Add Contract w Sign
    static func onAddContractSignature(brochureID:Int,signatureData:Data,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/update-brochure/\(brochureID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let parameters = ["cont_create_date": timestamp] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(signatureData, withName: "signed2",fileName: "signed2.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success( _):
                        completion(true)
                    case.failure( _):
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //Add Brochure w confirm sign
    static func onAddBrochureConfirmSignature(brochureID:Int,signatureData:Data,completion:@escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/update-brochure/\(brochureID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let parameters = ["hand_over_date": timestamp] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(signatureData, withName: "brochure_confirm_signed_url",fileName: "bro_confirm.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        completion(true,json["brochure_confirm_signed_url"].stringValue)
                    case.failure( _):
                        completion(false,"")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false,"")
            }
        }
    }
    
    //Add Contract w confirm sign
    static func onAddContractConfirmSignature(brochureID:Int,signatureData:Data,completion:@escaping StringCompletion) {
        
        let url = kAPI_URL + kAPI_BROCHURE + "/update-brochure/\(brochureID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let parameters = ["hand_over_date": timestamp] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(signatureData, withName: "contract_confirm_signed_url",fileName: "cont_confirm.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        completion(true,json["contract_confirm_signed_url"].stringValue)
                    case.failure( _):
                        completion(false,"")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false,"")
            }
        }
    }
    
    static func onAddCompanyData(companyID:Int,companySign:Data,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_COMPANY_STAMP + "/\(companyID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
        
        let parameters = [:] as [String : Any]
        
        AFManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(companySign, withName: "stamp",fileName: "stamp1.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        }, to:url,method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    switch(response.result) {
                    case .success( _):
                        completion(true)
                    case.failure( _):
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Staff
    //*****************************************************************
    
    //Get Staffs from AccountID
    static func onGetAllStaff(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(StaffData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getStaffCompany(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onGetAllStaffBasedOnPermission(permission:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "?permission=\(permission)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(StaffData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getStaffCompany(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onAddNewStaff(accID:Int,staff:StaffData,completion:@escaping(_ status: String) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "account_id": accID,
            "staff_name": staff.staff_name,
            "display_num": staff.display_num,
            "gender": staff.gender,
            "company_id": staff.company_id] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        let json = JSON(data)
                        completion(json["id"].stringValue)
                    case 400:
                        //exists
                        completion("existed")
                    default:
                        completion("false")
                    }
                }
            case.failure(let error):
                print(error)
                completion("false")
            }
        }
    }
    
    static func onUpdateStaff(staff:StaffData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "/\(staff.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "staff_name": staff.staff_name,
            "display_num": staff.display_num,
            "gender": staff.gender,
            "company_id": staff.company_id] as [String : Any]

        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onDeleteStaff(staffID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "/\(staffID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]

        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onUpdateStaffAvatar(staffID:Int,imageData:Data,completion:@escaping(String) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "/update-avatar/\(staffID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "avatar_url", fileName: "avatar_staff.jpg", mimeType: "image/jpg")
        }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch(response.result) {
                    case .success(let data):
                        let json = JSON(data)
                        completion(json["avatar_url"].stringValue)
                    case.failure( _):
                        completion("")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion("")
            }
        }
    }
    
    //on Swap Staff
    static func onSwapStaff(ids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "/update-display-num"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //on Swap Course
    static func onSwapStaffBetweenCompany(companyCategoryID:Int,ids:[Int],oldids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "/change-company-and-display-num"
        let parameters = ["ids": ids,
                          "company_id": companyCategoryID,
                          "old_ids": oldids] as [String : Any]

        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    // update permission on multi staff
    static func onUpdatePermissionMultiStaff(ids:[Int],permissions:[String],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_STAFF + "/update-multi-permission"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "permissions": permissions] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Bed
    //*****************************************************************
    
    //Get Beds from AccountID
    static func onGetAllBed(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BED
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(RoomData.self))
                    realm.delete(realm.objects(BedData.self))
                }
                
                let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
                if accountID == 0 { return }
                //Create temporary Room Data
                let room = RoomData()
                room.id = 1
                room.fc_account_id = accountID
                room.display_num = 1
                RealmServices.shared.create(room)
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getBedInfo(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onAddNewBed(accID:Int,bed:BedData,completion:@escaping(_ status: Int) -> ()) {
        
        let url = kAPI_URL + kAPI_BED
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "fc_account_id": accID,
            "bed_name": bed.bed_name,
            "display_num": bed.display_num,
            "note": bed.note] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(1)
                    case 400:
                        //exists
                        completion(2)
                    default:
                        completion(0)
                    }
                }
            case.failure(let error):
                print(error)
                completion(0)
            }
        }
    }
    
    static func onUpdateBed(bed:BedData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BED + "/\(bed.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "bed_name": bed.bed_name,
            "display_num": bed.display_num,
            "note": bed.note] as [String : Any]

        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onDeleteBed(bedID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BED + "/\(bedID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]

        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onSwapBed(ids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_BED + "/update-display-num"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Job
    //*****************************************************************
    
    static func onGetJobInfo(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_JOB
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(JobCategoryData.self))
                    realm.delete(realm.objects(JobData.self))
                }
                
                let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
                if accountID == 0 { return }
                //Create temporary Room Data
                let jobCategory = JobCategoryData()
                jobCategory.id = 1
                jobCategory.fc_account_id = accountID
                jobCategory.display_num = 1
                RealmServices.shared.create(jobCategory)
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getJobInfo(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //add newjob
    static func onAddNewJob(accID:Int,job:JobData,completion:@escaping(_ status: Int) -> ()) {
        
        let url = kAPI_URL + kAPI_JOBS
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "account_id": accID,
            "job": job.job,
            "display_num": job.display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(1)
                    case 400:
                        //exists
                        completion(2)
                    default:
                        completion(0)
                    }
                }
            case.failure(let error):
                print(error)
                completion(0)
            }
        }
    }
    
    static func onUpdateJob(job:JobData,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_JOBS + "/\(job.id)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = [
            "job": job.job,
            "display_num": job.display_num] as [String : Any]

        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onDeleteJob(jobID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_JOBS + "/\(jobID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]

        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onSwapJob(ids:[Int],display_num:[Int],completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_JOBS + "/update-display-num"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Payment Method
    //*****************************************************************
    
    static func onGetAllPaymentMethod(accountID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_PAYMENT + "?account_id=\(accountID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(PaymentCategoryData.self))
                    realm.delete(realm.objects(PaymentData.self))
                }
                
                let json = JSON(data)
                DBManager.getPaymentMethod(data: json)
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onAddNewPayment(accID:Int,payment:PaymentData,link:String,completion:@escaping(_ status: Int) -> ()) {
        
        let url = kAPI_URL + link
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["account_id": accID,
                          "category_id": payment.category_id,
                          "credit_company": payment.credit_company,
                          "display_num": payment.display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200,201:
                        //ok
                        completion(1)
                    case 400:
                        //exists
                        completion(2)
                    default:
                        completion(0)
                    }
                }
            case.failure(let error):
                print(error)
                completion(0)
            }
        }
    }
    
    static func onUpdatePayment(payment:PaymentData,link:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + link + "/\(payment.dbID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["credit_company": payment.credit_company,
                          "display_num": payment.display_num] as [String : Any]

        AFManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onDeletePayment(paymentID:Int,link:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + link + "/\(paymentID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]

        AFManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    static func onSwapPayment(ids:[Int],display_num:[Int],link:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + link + "/update-display-num"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        let parameters = ["ids": ids,
                          "display_num": display_num] as [String : Any]

        AFManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //ok
                        completion(true)
                    default:
                        completion(true)
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Messenger Category
    //*****************************************************************
    
    //Get Messenger Category
    static func onGetMessengerCategory(completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(MessengerCategoryData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getMessengerCategory(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Messenger Category
    static func onAddMessengerCategory(account_id:Int,name:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "fc_account_id": account_id,
            "category_name": name
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }
    
    //Edit Messenger Category
    static func onEditMessengerCategory(categoryID:Int,name:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER + "/\(categoryID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "category_name": name
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }
    
    //Delete Messenger Category
    static func onDeleteMessengerCategory(categoryID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER + "/\(categoryID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }
    
    //Get Messenger Category Item
    static func onGetMessengerCategoryItem(categoryID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER_ITEMS + "?fc_messenger_category_id=\(categoryID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear]
        
        AFManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            
            switch(response.result) {
            case.success(let data):
                let realm = RealmServices.shared.realm
                try! realm.write {
                    realm.delete(realm.objects(MessengerCategoryItemData.self))
                }
                
                let json = JSON(data)
                for i in 0 ..< json.count {
                    DBManager.getMessengerCategoryItem(data: json[i])
                }
                completion(true)
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    //Add Messenger Category Item
    static func onAddMessengerCategoryItem(categoryID:Int,title:String,content:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER_ITEMS
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "fc_messenger_category_id": categoryID,
            "title": title,
            "content": content
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }
    
    //Edit Messenger Category Item
    static func onEditMessengerCategoryItem(itemID:Int,title:String,content:String,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER_ITEMS + "/\(itemID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "title": title,
            "content": content
            ] as [String : Any]
        
        AFManager.request(url, method: .put, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }
    
    //Delete Messenger Category Item
    static func onDeleteMessengerCategoryItem(itemID:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_URL + kAPI_MESSENGER_ITEMS + "/\(itemID)"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        AFManager.request(url, method: .delete, parameters: nil, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Messenger Chat Server
    //*****************************************************************
    
    //Add Customer Chat
    static func onCreateCustomerChat(customerID:String,password:String,isShop:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_CHAT_URL + "user"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "customer_id": customerID,
            "password": password,
            "is_shop": isShop
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }
    
    //Login Chat Server
    static func onLoginChatServer(customerID:String,password:String,isShop:Int,completion:@escaping(Bool) -> ()) {
        
        let url = kAPI_CHAT_URL + "login"
        
        let secondTok: String = UserDefaults.standard.string(forKey: "token")!
        let bear = "Bearer " + secondTok
        let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
        
        let parameters = [
            "customer_id": customerID,
            "password": password,
            "is_shop": isShop
            ] as [String : Any]
        
        AFManager.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
            debugPrint(response)
            switch(response.result) {
                
            case.success( _):
                completion(true)
            case.failure( _):
                completion(false)
            }
        }
    }

}
