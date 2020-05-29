//
//  DBManager.swift
//  ABCarte2
//
//  Created by Long on 2018/08/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DBManager: NSObject {
    
    //*****************************************************************
    // MARK: - Account Tree Data
    //*****************************************************************
    
    static func getAccountTreeDataWithoutSelf(data:JSON)->AccTreeData {
        let accTree = AccTreeData()
        accTree.id = data["id"].intValue
        accTree.acc_name = data["acc_name"].stringValue
        accTree.account_id = data["account_id"].stringValue
        
        for i in 0 ..< data["children"].count {
            accTree.children.append(addChild(data: data["children"][i]))
        }
        return accTree
    }
    
    static func getAccountTreeData(data:JSON)->AccTreeData {
        let accTree = AccTreeData()
        accTree.id = data["id"].intValue
        
        if let status = UserPreferences.appHierarchy {
            if status == AppHierarchy.open.rawValue {
                //do nothing
            } else {
                GlobalVariables.sharedManager.hierarchyList.append(accTree.id)
            }
        }
        
        accTree.acc_name = data["acc_name"].stringValue
        accTree.account_id = data["account_id"].stringValue
        
        for i in 0 ..< data["children"].count {
            accTree.children.append(addChild(data: data["children"][i]))
        }
        return accTree
    }
    
    //add child
    static func addChild(data:JSON)->AccTreeData {
        let child = AccTreeData()
        child.id = data["id"].intValue
        
        if let status = UserPreferences.appHierarchy {
            if status == AppHierarchy.open.rawValue {
                //do nothing
            } else {
                GlobalVariables.sharedManager.hierarchyList.append(child.id)
            }
        }
        
        child.acc_name = data["acc_name"].stringValue
        child.account_id = data["account_id"].stringValue
        
        for i in 0 ..< data["children"].count {
            let subdata = data["children"][i]
            let newChild = addChild(data: subdata)
            child.children.append(newChild)
        }
        
        return child
    }
    
    //*****************************************************************
    // MARK: - Account Data
    //*****************************************************************
    static func getAccountData(data:JSON) {
        let newAccount = AccountData()
        newAccount.id = data["id"].intValue
        newAccount.acc_parent = data["acc_parent"].intValue
        newAccount.sub_acc = data["sub_acc"].stringValue
        newAccount.max_device = data["max_device"].intValue
        newAccount.group_group_id = data["group_group_id"].stringValue
        newAccount.group_id = data["group_id"].intValue
        newAccount.account_id = data["account_id"].stringValue
        newAccount.acc_memo_max = data["acc_memo_max"].intValue
        newAccount.acc_child = data["acc_child"].intValue
        newAccount.parent_sub_acc = data["parent_sub_acc"].stringValue
        newAccount.acc_free_memo_max = data["acc_free_memo_max"].intValue
        newAccount.secret_memo_password = data["secret_memo_password"].stringValue
        newAccount.acc_stamp_memo_max = data["acc_stamp_memo_max"].intValue
        newAccount.acc_name_kana = data["acc_name_kana"].stringValue
        newAccount.acc_disk_size = data["acc_disk_size"].stringValue
        newAccount.created_at = data["created_at"].intValue
        newAccount.acc_function = data["acc_function"].intValue
        newAccount.status = data["acc_function"].intValue
        newAccount.acc_name = data["acc_name"].stringValue
        newAccount.pic_limit = data["pic_limit"].intValue
        newAccount.settlement_url = data["settlement_url"].stringValue
        newAccount.qr_code = data["qr_code"].stringValue
        
        GlobalVariables.sharedManager.comName = data["acc_name"].stringValue
        
        newAccount.updated_at = data["updated_at"].intValue
        
        newAccount.acc_limit = data["acc_limit"].stringValue
        if data["acc_limit"].stringValue != "" {
            let arr = newAccount.acc_limit.components(separatedBy: ",")
            let intArray = arr.map { Int($0)!}
            GlobalVariables.sharedManager.appLimitation = intArray
        } else {
            GlobalVariables.sharedManager.appLimitation.removeAll()
        }
        
        newAccount.favorite_colors = data["favorite_colors"].stringValue
        if data["favorite_colors"].stringValue != "" {
            let arr = newAccount.favorite_colors.components(separatedBy: ",")
            GlobalVariables.sharedManager.accFavoriteColors = arr
        } else {
            GlobalVariables.sharedManager.accFavoriteColors.removeAll()
            //add color templates
            let colors = ["#ff0000","#ffbf00","#40ff00","#0080ff","#8000ff"]
            
            GlobalVariables.sharedManager.accFavoriteColors.append(contentsOf: colors)
        }
        newAccount.status = data["status"].intValue
        RealmServices.shared.create(newAccount)
    }
    
    //*****************************************************************
    // MARK: - Customer Data
    //*****************************************************************
    static func getCustomerData(data:JSON) {
        let newCustomer = CustomerData()
        newCustomer.id = data["id"].intValue
        newCustomer.fc_account_id = data["fc_account_id"].intValue
        newCustomer.fc_account_account_id = data["fc_account_account_id"].stringValue
        newCustomer.first_name = data["first_name"].stringValue
        newCustomer.last_name = data["last_name"].stringValue
        newCustomer.first_name_kana = data["first_name_kana"].stringValue
        newCustomer.last_name_kana = data["last_name_kana"].stringValue
        newCustomer.gender = data["gender"].intValue
        newCustomer.bloodtype = data["bloodtype"].intValue
        newCustomer.customer_no = data["customer_no"].stringValue
        
        if data["pic_url"].stringValue == "" {
            newCustomer.pic_url = data["pic_url"].stringValue
            newCustomer.thumb = newCustomer.pic_url
        } else {
            newCustomer.pic_url = kAPI_URL_AWS + data["pic_url"].stringValue
            
            let linkPath = (data["pic_url"].stringValue as NSString).deletingLastPathComponent
            let lastPath = (data["pic_url"].stringValue as NSString).lastPathComponent
            
            newCustomer.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
        }
        
        newCustomer.birthday = data["birthday"].intValue
        newCustomer.hobby = data["hobby"].stringValue
        newCustomer.email = data["email"].stringValue
        newCustomer.postal_code = data["postal_code"].stringValue
        newCustomer.address1 = data["address1"].stringValue
        newCustomer.address2 = data["address2"].stringValue
        newCustomer.address3 = data["address3"].stringValue
        newCustomer.responsible = data["responsible"].stringValue
        newCustomer.mail_block = data["mail_block"].intValue
        newCustomer.first_daycome = data["first_daycome"].intValue
        newCustomer.last_daycome = data["last_daycome"].intValue
        newCustomer.update_date = data["update_date"].intValue
        newCustomer.urgent_no = data["urgent_no"].stringValue
        newCustomer.memo1 = data["memo1"].stringValue
        newCustomer.memo2 = data["memo2"].stringValue
        newCustomer.created_at = data["created_at"].intValue
        newCustomer.updated_at = data["updated_at"].intValue
        newCustomer.selected_status = 0
        newCustomer.cus_status = data["customer_status"].intValue
        newCustomer.cus_dialogID = data["cus_dialogID"].stringValue
        newCustomer.cus_msg_inbox = data["cus_msg_inbox"].intValue
        
        if data["fcSecretMemos"].count > 0 {
            newCustomer.onSecret = 1
        } else {
            newCustomer.onSecret = 0
        }
        
        if data["fcAccount"].count > 0 {
            newCustomer.acc_name = data["fcAccount"]["acc_name"].stringValue
        }
        
        RealmServices.shared.create(newCustomer)
    }
    
    //*****************************************************************
    // MARK: - Get A Cus Data and Return
    //*****************************************************************
    static func getACustomerData(data:JSON)->CustomerData {
        let newCustomer = CustomerData()
        newCustomer.id = data["id"].intValue
        newCustomer.fc_account_id = data["fc_account_id"].intValue
        newCustomer.fc_account_account_id = data["fc_account_account_id"].stringValue
        newCustomer.first_name = data["first_name"].stringValue
        newCustomer.last_name = data["last_name"].stringValue
        newCustomer.first_name_kana = data["first_name_kana"].stringValue
        newCustomer.last_name_kana = data["last_name_kana"].stringValue
        newCustomer.gender = data["gender"].intValue
        newCustomer.bloodtype = data["bloodtype"].intValue
        newCustomer.customer_no = data["customer_no"].stringValue
        
        if data["pic_url"].stringValue == "" {
            newCustomer.pic_url = data["pic_url"].stringValue
            newCustomer.thumb = newCustomer.pic_url
        } else {
            newCustomer.pic_url = kAPI_URL_AWS + data["pic_url"].stringValue
            
            let linkPath = (data["pic_url"].stringValue as NSString).deletingLastPathComponent
            let lastPath = (data["pic_url"].stringValue as NSString).lastPathComponent
            
            newCustomer.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
        }
        
        newCustomer.birthday = data["birthday"].intValue
        newCustomer.hobby = data["hobby"].stringValue
        newCustomer.email = data["email"].stringValue
        newCustomer.postal_code = data["postal_code"].stringValue
        newCustomer.address1 = data["address1"].stringValue
        newCustomer.address2 = data["address2"].stringValue
        newCustomer.address3 = data["address3"].stringValue
        newCustomer.responsible = data["responsible"].stringValue
        newCustomer.mail_block = data["mail_block"].intValue
        newCustomer.first_daycome = data["first_daycome"].intValue
        newCustomer.last_daycome = data["last_daycome"].intValue
        newCustomer.update_date = data["update_date"].intValue
        newCustomer.urgent_no = data["urgent_no"].stringValue
        newCustomer.memo1 = data["memo1"].stringValue
        newCustomer.memo2 = data["memo2"].stringValue
        newCustomer.created_at = data["created_at"].intValue
        newCustomer.updated_at = data["updated_at"].intValue
        newCustomer.cus_status = data["customer_status"].intValue
        newCustomer.cus_dialogID = data["cus_dialogID"].stringValue
        newCustomer.cus_msg_inbox = data["cus_msg_inbox"].intValue
        
        if data["document_1"].stringValue != "" {
            newCustomer.document_1 = kAPI_URL_AWS + data["document_1"].stringValue
        }
        if data["document_2"].stringValue != "" {
            newCustomer.document_2 = kAPI_URL_AWS + data["document_2"].stringValue
        }
        if data["document_consent"].stringValue != "" {
            newCustomer.document_consent = kAPI_URL_AWS + data["document_consent"].stringValue
        }
        
        if data["fcSecretMemos"].count > 0 {
            newCustomer.onSecret = 1
        } else {
            newCustomer.onSecret = 0
        }
        
        if data["fcAccount"].count > 0 {
            newCustomer.acc_name = data["fcAccount"]["acc_name"].stringValue
        }
        
        return newCustomer
    }
    
    //*****************************************************************
    // MARK: - Get A Carte Data and Return
    //*****************************************************************
    static func getCartesData(data:JSON)->CarteData {
        let newCarte = CarteData()
        newCarte.id = data["id"].intValue
        newCarte.carte_id = data["carte_id"].stringValue
        newCarte.fc_customer_id = data["fc_customer_id"].intValue
        newCarte.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
        newCarte.create_date = data["create_date"].intValue
        newCarte.select_date = data["select_date"].intValue
        
        return newCarte
    }
    
    //*****************************************************************
    // MARK: - Get Customer Cartes with customer info
    //*****************************************************************
    static func getCartesDataWithCustomer(data:JSON) {
        let newCarte = CarteData()
        newCarte.id = data["id"].intValue
        newCarte.carte_id = data["carte_id"].stringValue
        newCarte.fc_customer_id = data["fc_customer_id"].intValue
        newCarte.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
        newCarte.create_date = data["create_date"].intValue
        newCarte.select_date = data["select_date"].intValue
        newCarte.account_name = data["fcAccount"]["acc_name"].stringValue
        
        if data["carte_photo"].stringValue.isEmpty {
            newCarte.carte_photo = data["carte_photo"].stringValue
        } else {
            if data["carte_photo"].stringValue.contains("160.16.137.252") {
                newCarte.carte_photo = data["carte_photo"].stringValue
            } else {
                newCarte.carte_photo = kAPI_URL_AWS + data["carte_photo"].stringValue
            }
        }
        
        newCarte.status = data["status"].intValue
        newCarte.selected_status = 0
        newCarte.staff_name = data["staff_name"].stringValue
        newCarte.bed_name = data["bed_name"].stringValue
        
        let dayCome = Utils.convertUnixTimestampUK(time: data["select_date"].intValue)
        newCarte.date_converted = dayCome
        
        if data["fcCustomer"].count > 0 {
            let cus = data["fcCustomer"]
            let newCus = SubCustomerData()
            
            newCus.id = cus["id"].intValue
            newCus.fc_account_id = cus["fc_account_id"].intValue
            newCus.fc_account_account_id = cus["fc_account_account_id"].stringValue
            newCus.first_name = cus["first_name"].stringValue
            newCus.last_name = cus["last_name"].stringValue
            newCus.first_name_kana = cus["first_name_kana"].stringValue
            newCus.last_name_kana = cus["last_name_kana"].stringValue
            newCus.gender = cus["gender"].intValue
            newCus.bloodtype = cus["bloodtype"].intValue
            newCus.customer_no = cus["customer_no"].stringValue
            
            if cus["pic_url"].stringValue == "" {
                newCus.pic_url = cus["pic_url"].stringValue
                newCus.thumb = newCus.pic_url
            } else {
                newCus.pic_url = kAPI_URL_AWS + cus["pic_url"].stringValue
                
                let linkPath = (cus["pic_url"].stringValue as NSString).deletingLastPathComponent
                let lastPath = (cus["pic_url"].stringValue as NSString).lastPathComponent
                
                newCus.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
            }
            
            newCus.birthday = cus["birthday"].intValue
            newCus.hobby = cus["hobby"].stringValue
            newCus.email = cus["email"].stringValue
            newCus.postal_code = cus["postal_code"].stringValue
            newCus.address1 = cus["address1"].stringValue
            newCus.address2 = cus["address2"].stringValue
            newCus.address3 = cus["address3"].stringValue
            newCus.responsible = cus["responsible"].stringValue
            newCus.mail_block = cus["mail_block"].intValue
            newCus.first_daycome = cus["first_daycome"].intValue
            newCus.last_daycome = cus["last_daycome"].intValue
            newCus.update_date = cus["update_date"].intValue
            newCus.urgent_no = cus["urgent_no"].stringValue
            newCus.memo1 = cus["memo1"].stringValue
            newCus.memo2 = cus["memo2"].stringValue
            newCus.created_at = cus["created_at"].intValue
            newCus.updated_at = cus["updated_at"].intValue
            newCus.selected_status = 0
            newCus.cus_status = cus["customer_status"].intValue
            
            newCarte.cus.append(newCus)
        }
        
        RealmServices.shared.create(newCarte)
    }
    
    //*****************************************************************
    // MARK: - Get Customer Cartes with memo info
    //*****************************************************************
    static func getCartesDataWithMemo(data:JSON) {
        let newCarte = CarteData()
        newCarte.id = data["id"].intValue
        newCarte.carte_id = data["carte_id"].stringValue
        newCarte.fc_customer_id = data["fc_customer_id"].intValue
        newCarte.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
        newCarte.create_date = data["create_date"].intValue
        newCarte.select_date = data["select_date"].intValue
        newCarte.account_name = data["account_name"].stringValue
        
        if data["carte_photo"].stringValue.isEmpty {
            newCarte.carte_photo = data["carte_photo"].stringValue
        } else {
            if data["carte_photo"].stringValue.contains("160.16.137.252") {
                newCarte.carte_photo = data["carte_photo"].stringValue
            } else {
                newCarte.carte_photo = kAPI_URL_AWS + data["carte_photo"].stringValue
            }
        }
        
        newCarte.status = data["status"].intValue
        newCarte.selected_status = 0
        newCarte.staff_name = data["staff_name"].stringValue
        newCarte.bed_name = data["bed_name"].stringValue
        
        if data["fcFreeMemos"].count > 0 {
            let memos = data["fcFreeMemos"]
            for i in 0 ..< memos.count {
                let newMemo = FreeMemoData()
                newMemo.id = memos[i]["id"].intValue
                newMemo.memo_id = memos[i]["memo_id"].stringValue
                newMemo.fc_customer_carte_id = memos[i]["fc_customer_carte_id"].intValue
                newMemo.fc_customer_carte_carte_id = memos[i]["fc_customer_carte_carte_id"].stringValue
                newMemo.title = memos[i]["title"].stringValue
                newMemo.position = memos[i]["position"].intValue
                newMemo.content = memos[i]["content"].stringValue
                newMemo.date = memos[i]["date"].intValue
                newMemo.type = memos[i]["type"].intValue
                newMemo.fc_customer_id = memos[i]["fc_customer_id"].intValue
                newMemo.fc_account_id = memos[i]["fc_account_id"].intValue
                newMemo.status = memos[i]["status"].intValue
                newMemo.created_at = memos[i]["created_at"].intValue
                newMemo.updated_at = memos[i]["updated_at"].intValue
                
                newCarte.free_memo.append(newMemo)
            }
        }
        
        if data["fcStampMemos"].count > 0 {
            let memos = data["fcStampMemos"]
            for i in 0 ..< memos.count {
                let newMemo = StampMemoData()
                newMemo.id = memos[i]["id"].intValue
                newMemo.memo_id = memos[i]["memo_id"].stringValue
                newMemo.fc_customer_carte_id = memos[i]["fc_customer_carte_id"].intValue
                newMemo.fc_customer_carte_carte_id = memos[i]["fc_customer_carte_carte_id"].stringValue
                newMemo.title = memos[i]["title"].stringValue
                newMemo.position = memos[i]["position"].intValue
                newMemo.content = memos[i]["content"].stringValue
                newMemo.date = memos[i]["date"].intValue
                newMemo.type = memos[i]["type"].intValue
                newMemo.fc_customer_id = memos[i]["fc_customer_id"].intValue
                newMemo.fc_account_id = memos[i]["fc_account_id"].intValue
                newMemo.status = memos[i]["status"].intValue
                newMemo.created_at = memos[i]["created_at"].intValue
                newMemo.updated_at = memos[i]["updated_at"].intValue
                
                newCarte.stamp_memo.append(newMemo)
            }
        }
        
        if data["fcUserMedia"].count > 0 {
            let media = data["fcUserMedia"]
            for i in 0 ..< media.count {
                let newMedia = MediaData()
                newMedia.id = media[i]["id"].intValue
                newMedia.media_id = media[i]["media_id"].stringValue
                newMedia.fc_customer_carte_id = media[i]["fc_customer_carte_id"].intValue
                newMedia.fc_customer_carte_carte_id = media[i]["fc_customer_carte_carte_id"].stringValue
                newMedia.date = media[i]["date"].intValue
                
                if media[i]["url"].stringValue == "" {
                    newMedia.url = media[i]["url"].stringValue
                    newMedia.thumb = newMedia.url
                } else {
                    newMedia.url = kAPI_URL_AWS + media[i]["url"].stringValue
                    
                    let linkPath = (media[i]["url"].stringValue as NSString).deletingLastPathComponent
                    let lastPath = (media[i]["url"].stringValue as NSString).lastPathComponent
                    
                    newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
                }
                
                newMedia.title = media[i]["title"].stringValue
                newMedia.comment = media[i]["comment"].stringValue
                newMedia.tag = media[i]["tag"].stringValue
                newMedia.type = media[i]["type"].intValue
                newMedia.status = media[i]["status"].intValue
                newMedia.created_at = media[i]["created_at"].intValue
                newMedia.updated_at = media[i]["updated_at"].intValue
                newMedia.fc_account_id = media[i]["fc_account_id"].intValue
                
                newCarte.medias.append(newMedia)
            }
        }
        
        if data["fcDocuments"].count > 0 {
            let doc = data["fcDocuments"]
            for i in 0 ..< doc.count {
                let newDoc = DocumentData()
                newDoc.id = doc[i]["id"].intValue
                newDoc.is_template = doc[i]["is_template"].intValue
                newDoc.sub_type = doc[i]["sub_type"].intValue
                newDoc.title = doc[i]["title"].stringValue
                newDoc.type = doc[i]["type"].intValue
                newDoc.document_no = doc[i]["document_no"].stringValue
                
                if doc[i]["fcDocumentPages"].count > 0 {
                    let page = doc[i]["fcDocumentPages"]
                    
                    for i in 0 ..< page.count {
                        let newPage = DocumentPageData()
                        newPage.id = page[i]["id"].intValue
                        newPage.fc_document_id = page[i]["fc_document_id"].intValue
                        newPage.page = page[i]["page"].intValue
                        
                        if page[i]["url_edit"].stringValue != "" {
                            newPage.url_edit = kAPI_URL_AWS + page[i]["url_edit"].stringValue
                        }
                        
                        if page[i]["url_original"].stringValue != "" {
                            newPage.url_original = kAPI_URL_AWS + page[i]["url_original"].stringValue
                        }
                        
                        newPage.fc_account_id = page[i]["fc_account_id"].intValue
                        newPage.status = page[i]["status"].intValue
                        newPage.created_at = page[i]["created_at"].intValue
                        newPage.updated_at = page[i]["updated_at"].intValue
                        newPage.is_edited = page[i]["is_edited"].intValue
                        
                        newDoc.document_pages.append(newPage)
                    }
                }
                newCarte.doc.append(newDoc)
            }
        }
        
        RealmServices.shared.create(newCarte)
    }
    
    //*****************************************************************
    // MARK: - Get Customer Cartes with media info
    //*****************************************************************
    static func getCartesDataWithMedias(data:JSON) {
        let newCarte = CarteData()
        newCarte.id = data["id"].intValue
        newCarte.carte_id = data["carte_id"].stringValue
        newCarte.fc_customer_id = data["fc_customer_id"].intValue
        newCarte.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
        newCarte.create_date = data["create_date"].intValue
        newCarte.select_date = data["select_date"].intValue
        
        if data["carte_photo"].stringValue.isEmpty {
            newCarte.carte_photo = data["carte_photo"].stringValue
        } else {
            if data["carte_photo"].stringValue.contains("160.16.137.252") {
                newCarte.carte_photo = data["carte_photo"].stringValue
            } else {
                newCarte.carte_photo = kAPI_URL_AWS + data["carte_photo"].stringValue
            }
        }
        
        if data["fcUserMedia"].count > 0 {
            let media = data["fcUserMedia"]
            
            var mediasData : [MediaData] = []
            for i in 0 ..< media.count {
                let newMedia = MediaData()
                newMedia.id = media[i]["id"].intValue
                newMedia.media_id = media[i]["media_id"].stringValue
                newMedia.fc_customer_carte_id = media[i]["fc_customer_carte_id"].intValue
                newMedia.fc_customer_carte_carte_id = media[i]["fc_customer_carte_carte_id"].stringValue
                newMedia.date = media[i]["date"].intValue
                
                if media[i]["url"].stringValue == "" {
                    newMedia.url = media[i]["url"].stringValue
                    newMedia.thumb = newMedia.url
                } else {
                    newMedia.url = kAPI_URL_AWS + media[i]["url"].stringValue
                    
                    let linkPath = (media[i]["url"].stringValue as NSString).deletingLastPathComponent
                    let lastPath = (media[i]["url"].stringValue as NSString).lastPathComponent
                    
                    newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
                }
                
                newMedia.title = media[i]["title"].stringValue
                newMedia.comment = media[i]["comment"].stringValue
                newMedia.tag = media[i]["tag"].stringValue
                newMedia.type = media[i]["type"].intValue
                newMedia.status = media[i]["status"].intValue
                newMedia.created_at = media[i]["created_at"].intValue
                newMedia.updated_at = media[i]["updated_at"].intValue
                newMedia.fc_account_id = media[i]["fc_account_id"].intValue
                
                mediasData.append(newMedia)
            }
            mediasData = mediasData.sorted(by: { $0.date > $1.date })
            
            for j in 0 ..< mediasData.count {
                newCarte.medias.append(mediasData[j])
            }
        }
        
        RealmServices.shared.create(newCarte)
    }
    
    //*****************************************************************
    // MARK: - Get Medias Data from Customer
    //*****************************************************************
    static func getMediasDataCus(data:JSON,date:String) {
        let newThumb = ThumbData()
        newThumb.date = date
        newThumb.id = Int(date.replacingOccurrences(of: "-", with: ""))!
        
        for i in 0 ..< data.count {
            let newMedia = MediaData()
            newMedia.id = data[i]["id"].intValue
            newMedia.fc_customer_carte_id = data[i]["fc_customer_carte_id"].intValue
            newMedia.type = data[i]["type"].intValue
            newMedia.comment = data[i]["comment"].stringValue
            newMedia.tag = data[i]["tag"].stringValue
            newMedia.title = data[i]["title"].stringValue
            newMedia.updated_at = data[i]["updated_at"].intValue
            newMedia.status = data[i]["status"].intValue
            newMedia.created_at = data[i]["created_at"].intValue
            
            if data[i]["url"].stringValue == "" {
                newMedia.url = data[i]["url"].stringValue
                newMedia.thumb = newMedia.url
            } else {
                newMedia.url = kAPI_URL_AWS + data[i]["url"].stringValue
                
                let linkPath = (data[i]["url"].stringValue as NSString).deletingLastPathComponent
                let lastPath = (data[i]["url"].stringValue as NSString).lastPathComponent
                
                newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
            }
            newMedia.media_id = data[i]["media_id"].stringValue
            newMedia.fc_customer_carte_carte_id = data[i]["fc_customer_carte_carte_id"].stringValue
            newMedia.date = data[i]["date"].intValue
            
            newThumb.medias.append(newMedia)
        }
        
        RealmServices.shared.create(newThumb)
    }
    
    //on Add Media New
    static func getMediasDataCusNew(data:JSON) {
        for i in 0 ..< data.count {
            let newMedia = MediaData()
            newMedia.id = data[i]["id"].intValue
            newMedia.fc_customer_carte_id = data[i]["fc_customer_carte_id"].intValue
            newMedia.type = data[i]["type"].intValue
            newMedia.comment = data[i]["comment"].stringValue
            newMedia.tag = data[i]["tag"].stringValue
            newMedia.title = data[i]["title"].stringValue
            newMedia.updated_at = data[i]["updated_at"].intValue
            newMedia.status = data[i]["status"].intValue
            newMedia.created_at = data[i]["created_at"].intValue
            
            if data[i]["url"].stringValue == "" {
                newMedia.url = data[i]["url"].stringValue
                newMedia.thumb = newMedia.url
            } else {
                newMedia.url = kAPI_URL_AWS + data[i]["url"].stringValue
                
                let linkPath = (data[i]["url"].stringValue as NSString).deletingLastPathComponent
                let lastPath = (data[i]["url"].stringValue as NSString).lastPathComponent
                
                newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
            }
            newMedia.media_id = data[i]["media_id"].stringValue
            newMedia.fc_customer_carte_carte_id = data[i]["fc_customer_carte_carte_id"].stringValue
            newMedia.date = data[i]["date"].intValue
            
//            newThumb.medias.append(newMedia)
        }
        
//        RealmServices.shared.create(newThumb)
    }
    
    //*****************************************************************
    // MARK: - Get Carte Medias Data
    //*****************************************************************
    static func getMediasData(data:JSON) {
        
        let newMedia = MediaData()
        
        newMedia.id = data["id"].intValue
        newMedia.media_id = data["media_id"].stringValue
        newMedia.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
        newMedia.fc_customer_carte_carte_id = data["fc_customer_carte_carte_id"].stringValue
        newMedia.date = data["date"].intValue
        
        if data["url"].stringValue == "" {
            newMedia.url = data["url"].stringValue
            newMedia.thumb = newMedia.url
        } else {
            newMedia.url = kAPI_URL_AWS + data["url"].stringValue
            
            let linkPath = (data["url"].stringValue as NSString).deletingLastPathComponent
            let lastPath = (data["url"].stringValue as NSString).lastPathComponent
            
            newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
        }
        
        newMedia.title = data["title"].stringValue
        newMedia.comment = data["comment"].stringValue
        newMedia.tag = data["tag"].stringValue
        newMedia.type = data["type"].intValue
        newMedia.status = data["status"].intValue
        newMedia.created_at = data["created_at"].intValue
        newMedia.updated_at = data["updated_at"].intValue
        newMedia.fc_account_id = data["fc_account_id"].intValue
        
        RealmServices.shared.create(newMedia)
    }
    
    //*****************************************************************
    // MARK: - Get Carte Memos Data
    //*****************************************************************
    static func getMemosData(data:JSON) {
        
        let newMemo = MemoData()
        let fcMemo = data["fcUserMemos"]
        
        newMemo.id = fcMemo["id"].intValue
        newMemo.status = fcMemo["status"].intValue
        newMemo.content = fcMemo["content"].stringValue
        newMemo.title = fcMemo["title"].stringValue
        newMemo.created_at = fcMemo["created_at"].intValue
        newMemo.updated_at = fcMemo["updated_at"].intValue
        newMemo.date = fcMemo["date"].intValue
        newMemo.fc_customer_carte_carte_id = fcMemo["fc_customer_carte_carte_id"].intValue
        newMemo.type = fcMemo["type"].intValue
        newMemo.fc_account_id = fcMemo["fc_account_id"].intValue
        newMemo.memo_id = fcMemo["memo_id"].stringValue
        newMemo.position = fcMemo["position"].intValue
        newMemo.fc_customer_carte_id = fcMemo["fc_customer_carte_id"].intValue
        newMemo.fc_customer_id = fcMemo["fc_customer_id"].intValue
        
        RealmServices.shared.create(newMemo)
    }
    
    //*****************************************************************
    // MARK: - Get Carte Free Memos Data
    //*****************************************************************
    static func getFreeMemosData(data:JSON) {
        
        let newMemo = FreeMemoData()
        
        newMemo.id = data["id"].intValue
        newMemo.memo_id = data["memo_id"].stringValue
        newMemo.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
        newMemo.fc_customer_carte_carte_id = data["fc_customer_carte_carte_id"].stringValue
        newMemo.title = data["title"].stringValue
        newMemo.position = data["position"].intValue
        newMemo.content = data["content"].stringValue
        newMemo.date = data["date"].intValue
        newMemo.type = data["type"].intValue
        newMemo.fc_customer_id = data["fc_customer_id"].intValue
        newMemo.fc_account_id = data["fc_account_id"].intValue
        newMemo.status = data["status"].intValue
        newMemo.created_at = data["created_at"].intValue
        newMemo.updated_at = data["updated_at"].intValue
        
        RealmServices.shared.create(newMemo)
    }
    
    //*****************************************************************
    // MARK: - Get Carte Stamp Memos Data
    //*****************************************************************
    static func getStampMemosData(data:JSON) {
        
        let newMemo = StampMemoData()
        
        newMemo.id = data["id"].intValue
        newMemo.memo_id = data["memo_id"].stringValue
        newMemo.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
        newMemo.fc_customer_carte_carte_id = data["fc_customer_carte_carte_id"].stringValue
        newMemo.title = data["title"].stringValue
        newMemo.position = data["position"].intValue
        newMemo.content = data["content"].stringValue
        newMemo.date = data["date"].intValue
        newMemo.type = data["type"].intValue
        newMemo.fc_customer_id = data["fc_customer_id"].intValue
        newMemo.fc_account_id = data["fc_account_id"].intValue
        newMemo.status = data["status"].intValue
        newMemo.created_at = data["created_at"].intValue
        newMemo.updated_at = data["updated_at"].intValue
        
        RealmServices.shared.create(newMemo)
    }
    
    //*****************************************************************
    // MARK: - Get Carte Stamp Memos Data and Return
    //*****************************************************************
    static func getStampMemoDataAndReturn(data:JSON)->StampMemoData {
        
        let newMemo = StampMemoData()
        
        newMemo.id = data["id"].intValue
        newMemo.memo_id = data["memo_id"].stringValue
        newMemo.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
        newMemo.fc_customer_carte_carte_id = data["fc_customer_carte_carte_id"].stringValue
        newMemo.title = data["title"].stringValue
        newMemo.position = data["position"].intValue
        newMemo.content = data["content"].stringValue
        newMemo.date = data["date"].intValue
        newMemo.type = data["type"].intValue
        newMemo.fc_customer_id = data["fc_customer_id"].intValue
        newMemo.fc_account_id = data["fc_account_id"].intValue
        newMemo.status = data["status"].intValue
        newMemo.created_at = data["created_at"].intValue
        newMemo.updated_at = data["updated_at"].intValue
        
        return newMemo
    }
    
    //*****************************************************************
    // MARK: - Get Stamp Category&Keywords Data
    //*****************************************************************
    
    static func onGetStampCategoriesAndKeywords(data:JSON) {
        let newStampCate = StampCategoryData()
        newStampCate.id = data["id"].intValue
        newStampCate.title = data["title"].stringValue
        newStampCate.fc_account_id = data["fc_account_id"].intValue
        newStampCate.status = data["status"].intValue
        newStampCate.created_at = data["created_at"].intValue
        newStampCate.updated_at = data["updated_at"].intValue
        
        //get keywords
        for i in 0 ..< data["fcKeyword"].count {
            let newKeywords = StampKeywordData()
            newKeywords.category_id = data["fcKeyword"][i]["category_id"].intValue
            newKeywords.content = data["fcKeyword"][i]["content"].stringValue
            newKeywords.id = data["fcKeyword"][i]["id"].intValue
            newStampCate.keywords.append(newKeywords)
        }
        
        RealmServices.shared.create(newStampCate)
    }
    
    //*****************************************************************
    // MARK: - Get Stamp Category Data
    //*****************************************************************
    static func getStampCategoryData(data:JSON) {
        let newStampCate = StampCategoryData()
        newStampCate.id = data["id"].intValue
        newStampCate.title = data["title"].stringValue
        newStampCate.fc_account_id = data["fc_account_id"].intValue
        newStampCate.status = data["status"].intValue
        newStampCate.created_at = data["created_at"].intValue
        newStampCate.updated_at = data["updated_at"].intValue
        
        RealmServices.shared.create(newStampCate)
    }
    
    //*****************************************************************
    // MARK: - Get Stamp Keywords Data
    //*****************************************************************
    static func getStampKeyword(data:JSON) {
        let newKey = StampKeywordData()
        newKey.id = data["id"].intValue
        newKey.content = data["content"].stringValue
        newKey.category_id = data["category_id"].intValue
        RealmServices.shared.create(newKey)
    }
    
    //*****************************************************************
    // MARK: - Get Stamp Content Data
    //*****************************************************************
    static func getStampContent(data:JSON) {
        let newContent = StampContentData()
        newContent.id = data["id"].intValue
        newContent.content = data["content"].stringValue
        newContent.category_id = data["category_id"].intValue
        RealmServices.shared.create(newContent)
    }
    
    //*****************************************************************
    // MARK: - Get Secret Memo Data
    //*****************************************************************
    static func getSecretMemoData(data:JSON) {
        let newSecret = SecretMemoData()
        newSecret.id = data["id"].intValue
        newSecret.secret_id = data["secret_id"].stringValue
        newSecret.fc_customer_id = data["fc_customer_id"].intValue
        newSecret.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
        newSecret.date = data["date"].intValue
        newSecret.content = data["content"].stringValue
        newSecret.status = data["status"].intValue
        newSecret.created_at = data["created_at"].intValue
        newSecret.updated_at = data["updated_at"].intValue
        newSecret.fc_account_id = data["fc_account_id"].intValue
        
        RealmServices.shared.create(newSecret)
    }
    
    //*****************************************************************
    // MARK: - Get Document Template Data
    //*****************************************************************
    
    static func getDocumentsData(data:JSON) {
        let newDoc = DocumentData()
        newDoc.id = data["id"].intValue
        newDoc.type = data["type"].intValue
        newDoc.sub_type = data["sub_type"].intValue
        newDoc.title = data["title"].stringValue
        newDoc.fc_account_id = data["fc_account_id"].intValue
        newDoc.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
        newDoc.status = data["status"].intValue
        newDoc.created_at = data["created_at"].intValue
        newDoc.updated_at = data["updated_at"].intValue
        newDoc.is_template = data["is_template"].intValue
        
        if data["fcDocumentPages"].count > 0 {
            let page = data["fcDocumentPages"]
            
            for i in 0 ..< page.count {
                let newPage = DocumentPageData()
                newPage.id = page[i]["id"].intValue
                newPage.fc_document_id = page[i]["fc_document_id"].intValue
                newPage.page = page[i]["page"].intValue
                
                if page[i]["url_edit"].stringValue != "" {
                    newPage.url_edit = kAPI_URL_AWS + page[i]["url_edit"].stringValue
                }
                
                if page[i]["url_original"].stringValue != "" {
                    newPage.url_original = kAPI_URL_AWS + page[i]["url_original"].stringValue
                }
                
                newPage.fc_account_id = page[i]["fc_account_id"].intValue
                newPage.status = page[i]["status"].intValue
                newPage.created_at = page[i]["created_at"].intValue
                newPage.updated_at = page[i]["updated_at"].intValue
                newPage.is_edited = page[i]["is_edited"].intValue
                
                newDoc.document_pages.append(newPage)
            }
        }
        
        RealmServices.shared.create(newDoc)
    }
    
    //*****************************************************************
    // MARK: - Get Videos Data
    //*****************************************************************
    static func getVideosData(data:JSON) {
        let newVideo = VideoData()
        newVideo.id = data["id"].intValue
        newVideo.application_id = data["application_id"].intValue
        newVideo.desc = data["description"].stringValue
        newVideo.is_premium = data["is_premium"].intValue
        newVideo.last_updated = data["last_updated"].intValue
        newVideo.status = data["status"].intValue
        newVideo.tags = data["tags"].stringValue
        newVideo.title = data["title"].stringValue
        newVideo.uploaded_at = data["uploaded_at"].intValue
        newVideo.url = data["url"].stringValue
        newVideo.video_duration = data["video_duration"].intValue
        newVideo.thumbnail = data["thumbnail"].stringValue
        
        RealmServices.shared.create(newVideo)
    }
    
    //*****************************************************************
    // MARK: - Get Brochure Data
    //*****************************************************************
    static func getBrochureData(data:JSON) {
        let newBrochure = BrochureData()
        newBrochure.id = data["id"].intValue
        newBrochure.account_id = data["account_id"].intValue
        newBrochure.customer_id = data["customer_id"].intValue
        newBrochure.user_name = data["user_name"].stringValue
        newBrochure.broch_serial_num = data["broch_serial_num"].stringValue
        newBrochure.cont_serial_num = data["cont_serial_num"].stringValue
        newBrochure.admission_fee = data["admission_fee"].intValue
        newBrochure.mship_start_date = data["mship_start_date"].intValue
        newBrochure.mship_end_date = data["mship_end_date"].intValue
        newBrochure.service_start_date = data["service_start_date"].intValue
        newBrochure.service_end_date = data["service_end_date"].intValue
        newBrochure.cours_total = data["cours_total"].intValue
        newBrochure.goods_total = data["goods_total"].intValue
        newBrochure.total = data["total"].intValue
        newBrochure.agreement_date = data["agreement_date"].intValue
        newBrochure.signed1 = data["signed1"].stringValue
        newBrochure.signed2 = data["signed2"].stringValue
        newBrochure.company_profile = data["company_profile"].intValue
        newBrochure.sub_company = data["sub_company"].intValue
        newBrochure.advance_pay = data["advance_pay"].intValue
        newBrochure.used_item = data["used_item"].stringValue
        newBrochure.used_item2 = data["used_item2"].stringValue
        newBrochure.conserva = data["conserva"].stringValue
        newBrochure.contract_staff = data["contract_staff"].stringValue
        newBrochure.broch_create_date = data["broch_create_date"].intValue
        newBrochure.cont_create_date = data["cont_create_date"].intValue
        newBrochure.note1 = data["note1"].stringValue
        newBrochure.note2 = data["note2"].stringValue
        newBrochure.status = data["status"].intValue
        newBrochure.brochure_confirm = data["brochure_confirm"].intValue
        newBrochure.created_at = data["created_at"].intValue
        newBrochure.updated_at = data["updated_at"].intValue
        newBrochure.total_tax = data["total_tax"].intValue
        newBrochure.brochure_url = data["brochure_url"].stringValue
        newBrochure.brochure_signed_url = data["brochure_signed_url"].stringValue
        newBrochure.contract_url = data["contract_url"].stringValue
        newBrochure.contract_signed_url = data["contract_signed_url"].stringValue
        newBrochure.sum_notreat = data["sum_notreat"].intValue
        newBrochure.sum_coursetime = data["sum_coursetime"].intValue
        newBrochure.sum_nogoods = data["sum_nogoods"].intValue
        newBrochure.select_date = data["select_date"].intValue
        newBrochure.broch_print_date = data["broch_print_date"].intValue
        newBrochure.cont_print_date = data["cont_print_date"].intValue
        newBrochure.brochure_confirm_signed_url = data["brochure_confirm_signed_url"].stringValue
        newBrochure.contract_confirm_signed_url = data["contract_confirm_signed_url"].stringValue
        newBrochure.hand_over_date = data["hand_over_date"].intValue
        RealmServices.shared.create(newBrochure)
    }
    
    //*****************************************************************
    // MARK: - Get Course Category and Course
    //*****************************************************************
    static func getCourseCategoryAndCourseData(data:JSON) {
        let newCourseCategory = CourseCategoryData()
        newCourseCategory.id = data["id"].intValue
        newCourseCategory.account_id = data["account_id"].intValue
        newCourseCategory.display_num = data["display_num"].intValue
        newCourseCategory.category_name = data["category_name"].stringValue
        newCourseCategory.status = data["status"].intValue
        newCourseCategory.created_at = data["created_at"].intValue
        newCourseCategory.updated_at = data["updated_at"].intValue
        
        for i in 0 ..< data["fcMcourse"].count {
            let course = data["fcMcourse"]
            let newCourse = CourseData()
            newCourse.id = course[i]["id"].intValue
            newCourse.category_id = course[i]["category_id"].intValue
            newCourse.display_num = course[i]["display_num"].intValue
            newCourse.course_name = course[i]["course_name"].stringValue
            newCourse.treatment_time = course[i]["treatment_time"].intValue
            newCourse.unit_price = course[i]["unit_price"].intValue
            newCourse.fee_rate = course[i]["fee_rate"].intValue
            newCourse.requir_items = course[i]["requir_items"].stringValue
            newCourse.status = course[i]["status"].intValue
            newCourse.created_at = course[i]["created_at"].intValue
            newCourse.updated_at = course[i]["updated_at"].intValue
            
            for j in 0 ..< course[i]["FcGood"].count {
                let product = course[i]["FcGood"]
                let newProduct = ProductData()
                newProduct.id = product[j]["id"].intValue
                newProduct.item_category = product[j]["item_category"].stringValue
                newProduct.item_name = product[j]["item_name"].stringValue
                newProduct.unit_price = product[j]["unit_price"].intValue
                newProduct.fee_rate = product[j]["fee_rate"].intValue
                newProduct.display_num = product[j]["display_num"].intValue
                newCourse.products.append(newProduct)
            }
            RealmServices.shared.create(newCourse)
        }
        RealmServices.shared.create(newCourseCategory)
    }
    
    //*****************************************************************
    // MARK: - Get Course Category Data
    //*****************************************************************
    static func getCourseCategoryData(data:JSON) {
        let newCourseCategory = CourseCategoryData()
        newCourseCategory.id = data["id"].intValue
        newCourseCategory.account_id = data["account_id"].intValue
        newCourseCategory.display_num = data["display_num"].intValue
        newCourseCategory.category_name = data["category_name"].stringValue
        newCourseCategory.status = data["status"].intValue
        newCourseCategory.created_at = data["created_at"].intValue
        newCourseCategory.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newCourseCategory)
    }
    
    //*****************************************************************
    // MARK: - Get Course Data
    //*****************************************************************
    
    static func getCourseData(data:JSON) {
        let newCourse = CourseData()
        newCourse.id = data["id"].intValue
        newCourse.category_id = data["category_id"].intValue
        newCourse.display_num = data["display_num"].intValue
        newCourse.course_name = data["course_name"].stringValue
        newCourse.treatment_time = data["treatment_time"].intValue
        newCourse.unit_price = data["unit_price"].intValue
        newCourse.fee_rate = data["fee_rate"].intValue
        newCourse.requir_items = data["requir_items"].stringValue
        newCourse.status = data["status"].intValue
        newCourse.created_at = data["created_at"].intValue
        newCourse.updated_at = data["updated_at"].intValue
        
        for i in 0 ..< data["fcGood"].count {
            let product = data["fcGood"]
            let newProduct = ProductData()
            newProduct.id = product[i]["id"].intValue
            newProduct.category_id = product[i]["category_id"].intValue
            newProduct.display_num = product[i]["display_num"].intValue
            newProduct.item_name = product[i]["item_name"].stringValue
            newProduct.item_category = product[i]["item_category"].stringValue
            newProduct.unit_price = product[i]["unit_price"].intValue
            newProduct.fee_rate = product[i]["fee_rate"].intValue
            newProduct.status = product[i]["status"].intValue
            newProduct.created_at = product[i]["created_at"].intValue
            newProduct.updated_at = product[i]["updated_at"].intValue
            newCourse.products.append(newProduct)
        }
        RealmServices.shared.create(newCourse)
    }
    
    //*****************************************************************
    // MARK: - Get Product Category and Product
    //*****************************************************************
    
    static func getProductCategoryAndProductData(data:JSON) {
        let newProductCategory = ProductCategoryData()
        newProductCategory.id = data["id"].intValue
        newProductCategory.account_id = data["account_id"].intValue
        newProductCategory.display_num = data["display_num"].intValue
        newProductCategory.category_name = data["category_name"].stringValue
        newProductCategory.status = data["status"].intValue
        newProductCategory.created_at = data["created_at"].intValue
        newProductCategory.updated_at = data["updated_at"].intValue
        
        for i in 0 ..< data["fcGood"].count {
            let product = data["fcGood"]
            let newProduct = ProductData()
            newProduct.id = product[i]["id"].intValue
            newProduct.category_id = product[i]["category_id"].intValue
            newProduct.display_num = product[i]["display_num"].intValue
            newProduct.item_name = product[i]["item_name"].stringValue
            newProduct.item_category = product[i]["item_category"].stringValue
            newProduct.unit_price = product[i]["unit_price"].intValue
            newProduct.fee_rate = product[i]["fee_rate"].intValue
            newProduct.status = product[i]["status"].intValue
            newProduct.created_at = product[i]["created_at"].intValue
            newProduct.updated_at = product[i]["updated_at"].intValue
            RealmServices.shared.create(newProduct)
        }
        RealmServices.shared.create(newProductCategory)
    }
    
    //*****************************************************************
    // MARK: - Get Products Category Data
    //*****************************************************************
    static func getProductCategoryData(data:JSON) {
        let newCourseCategory = ProductCategoryData()
        newCourseCategory.id = data["id"].intValue
        newCourseCategory.account_id = data["account_id"].intValue
        newCourseCategory.display_num = data["display_num"].intValue
        newCourseCategory.category_name = data["category_name"].stringValue
        newCourseCategory.status = data["status"].intValue
        newCourseCategory.created_at = data["created_at"].intValue
        newCourseCategory.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newCourseCategory)
    }
    
    //*****************************************************************
    // MARK: - Get Products Data
    //*****************************************************************
    static func getProductData(data:JSON) {
        let newCourse = ProductData()
        newCourse.id = data["id"].intValue
        newCourse.category_id = data["category_id"].intValue
        newCourse.display_num = data["display_num"].intValue
        newCourse.item_name = data["item_name"].stringValue
        newCourse.item_category = data["item_category"].stringValue
        newCourse.unit_price = data["unit_price"].intValue
        newCourse.fee_rate = data["fee_rate"].intValue
        newCourse.status = data["status"].intValue
        newCourse.created_at = data["created_at"].intValue
        newCourse.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newCourse)
    }
    
    //*****************************************************************
    // MARK: - Get Company Info
    //*****************************************************************
    
    static func getCompanyInfo(data:JSON) {
        let newCompany = CompanyData()
        newCompany.id = data["id"].intValue
        newCompany.account_id = data["account_id"].intValue
        newCompany.company_name = data["company_name"].stringValue
        newCompany.president_name = data["president_name"].stringValue
        newCompany.zip = data["zip"].stringValue
        newCompany.address1 = data["address1"].stringValue
        newCompany.address2 = data["address2"].stringValue
        newCompany.tel = data["tel"].stringValue
        newCompany.stamp = data["stamp"].stringValue
        newCompany.display_num = data["display_num"].intValue
        newCompany.status = data["status"].intValue
        newCompany.created_at = data["created_at"].intValue
        newCompany.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newCompany)
    }
    
    //*****************************************************************
    // MARK: - Get Staff Company
    //*****************************************************************
    
    static func getStaffCompany(data:JSON) {
        let newStaff = StaffData()
        newStaff.id = data["id"].intValue
        newStaff.account_id = data["account_id"].intValue
        newStaff.company_id = data["company_id"].intValue
        newStaff.display_num = data["display_num"].intValue
        newStaff.staff_name = data["staff_name"].stringValue
        newStaff.avatar_url = data["avatar_url"].stringValue
        newStaff.gender = data["gender"].intValue
        if data["permission"].stringValue == "" {
            newStaff.permission = "0"
        } else {
            newStaff.permission = data["permission"].stringValue
        }
        newStaff.status = data["status"].intValue
        newStaff.created_at = data["created_at"].intValue
        newStaff.updated_at = data["updated_at"].intValue
        
        if data["fcCompany"].count > 0 {
            newStaff.company_name = data["fcCompany"]["company_name"].stringValue
        }
            
        RealmServices.shared.create(newStaff)
    }
    
    //*****************************************************************
    // MARK: - Get Additional Info
    //*****************************************************************
    
    static func getAdditionalInfo(data:JSON) {
        let newAddition = AdditionNoteData()
        newAddition.id = data["id"].intValue
        newAddition.account_id = data["account_id"].intValue
        newAddition.advance_pay = data["advance_pay"].intValue
        newAddition.used_item = data["used_item"].stringValue
        newAddition.used_item2 = data["used_item2"].stringValue
        newAddition.conserva = data["conserva"].stringValue
        newAddition.status = data["status"].intValue
        newAddition.created_at = data["created_at"].intValue
        newAddition.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newAddition)
    }
    
    //*****************************************************************
    // MARK: - Get Job Info
    //*****************************************************************
    
    static func getJobInfo(data:JSON) {
        let newJob = JobData()
        newJob.id = data["id"].intValue
        newJob.account_id = data["account_id"].intValue
        newJob.display_num = data["display_num"].intValue
        newJob.job = data["job"].stringValue
        newJob.status = data["status"].intValue
        newJob.created_at = data["created_at"].intValue
        newJob.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newJob)
    }
    
    //*****************************************************************
    // MARK: - Get Contract Customer Info
    //*****************************************************************
    
    static func getContractCustomerInfo(data:JSON) {
        let newContractCus = ContractCustomerData()
        newContractCus.id = data["id"].intValue
        newContractCus.brochure_id = data["brochure_id"].intValue
        newContractCus.contract_date = data["contract_date"].intValue
        newContractCus.last_name = data["last_name"].stringValue
        newContractCus.first_name = data["first_name"].stringValue
        newContractCus.last_name_kana = data["last_name_kana"].stringValue
        newContractCus.first_name_kana = data["first_name_kana"].stringValue
        newContractCus.birthday = data["birthday"].intValue
        newContractCus.first_name_kana = data["first_name_kana"].stringValue
        newContractCus.birthday = data["birthday"].intValue
        newContractCus.customer_no = data["customer_no"].stringValue
        newContractCus.zip = data["zip"].stringValue
        newContractCus.country = data["country"].stringValue
        newContractCus.address1 = data["address1"].stringValue
        newContractCus.address2 = data["address2"].stringValue
        newContractCus.contract_url = data["contract_url"].stringValue
        newContractCus.contract_signed_url = data["contract_signed_url"].stringValue
        newContractCus.tel = data["tel"].stringValue
        newContractCus.emergency_tel = data["emergency_tel"].stringValue
        newContractCus.job = data["job"].stringValue
        newContractCus.company_name = data["company_name"].stringValue
        newContractCus.company_zip = data["company_zip"].stringValue
        newContractCus.company_city = data["company_city"].stringValue
        newContractCus.company_address1 = data["company_address1"].stringValue
        newContractCus.company_address2 = data["company_address2"].stringValue
        newContractCus.status = data["status"].intValue
        newContractCus.created_at = data["created_at"].intValue
        newContractCus.updated_at = data["updated_at"].intValue
        newContractCus.contract_representative = data["contract_representative"].stringValue
        RealmServices.shared.create(newContractCus)
    }
    
    //*****************************************************************
    // MARK: - Get Messenger Category
    //*****************************************************************
    
    static func getMessengerCategory(data:JSON) {
        let newMsgCategory = MessengerCategoryData()
        newMsgCategory.id = data["id"].intValue
        newMsgCategory.fc_account_id = data["fc_account_id"].intValue
        newMsgCategory.category_name = data["category_name"].stringValue
        newMsgCategory.status = data["status"].intValue
        newMsgCategory.created_at = data["created_at"].intValue
        newMsgCategory.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newMsgCategory)
    }
    
    //*****************************************************************
    // MARK: - Get Messenger Category Item
    //*****************************************************************
    
    static func getMessengerCategoryItem(data:JSON) {
        let newMsgCategoryItem = MessengerCategoryItemData()
        newMsgCategoryItem.id = data["id"].intValue
        newMsgCategoryItem.fc_messenger_category_id = data["fc_messenger_category_id"].intValue
        newMsgCategoryItem.content = data["content"].stringValue
        newMsgCategoryItem.title = data["title"].stringValue
        newMsgCategoryItem.status = data["status"].intValue
        newMsgCategoryItem.created_at = data["created_at"].intValue
        newMsgCategoryItem.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newMsgCategoryItem)
    }
    
    //*****************************************************************
    // MARK: - Get Bed
    //*****************************************************************
    
    static func getBedInfo(data:JSON) {
        let newBed = BedData()
        newBed.id = data["id"].intValue
        newBed.account_id = data["fc_account_id"].intValue
        newBed.display_num = data["display_num"].intValue
        newBed.bed_name = data["bed_name"].stringValue
        newBed.note = data["note"].stringValue
        newBed.status = data["status"].intValue
        newBed.created_at = data["created_at"].intValue
        newBed.updated_at = data["updated_at"].intValue
        RealmServices.shared.create(newBed)
    }
    
    //*****************************************************************
    // MARK: - Get Payment Method
    //*****************************************************************
        
    static func getPaymentMethod(data:JSON) {
        
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        if accountID == 0 { return }
        
        //Create temporary Payment Category
        let creditCategory = PaymentCategoryData()
        creditCategory.id = 1
        creditCategory.account_id = accountID
        creditCategory.category_name = "クレジットカード"
        creditCategory.display_num = 1
        creditCategory.status = 10
        RealmServices.shared.create(creditCategory)
        
        let shoppingCategory = PaymentCategoryData()
        shoppingCategory.id = 2
        shoppingCategory.account_id = accountID
        shoppingCategory.category_name = "ショッピングクレジット"
        shoppingCategory.display_num = 2
        shoppingCategory.status = 10
        RealmServices.shared.create(shoppingCategory)
        
        let emoneyCategory = PaymentCategoryData()
        emoneyCategory.id = 3
        emoneyCategory.account_id = accountID
        emoneyCategory.category_name = "電子マネー"
        emoneyCategory.display_num = 3
        emoneyCategory.status = 10
        RealmServices.shared.create(emoneyCategory)
        
        //create id temp
        var id = 1
        
        if data["fcCredit"].count > 0 {
            let json = data["fcCredit"]
            for i in 0 ..< json.count {
                let newPayment = PaymentData()
                newPayment.id = id
                newPayment.dbID = json[i]["id"].intValue
                newPayment.category_id = 1
                newPayment.credit_company = json[i]["credit_company"].stringValue
                newPayment.display_num = json[i]["display_num"].intValue
                newPayment.status = json[i]["status"].intValue
                newPayment.created_at = json[i]["created_at"].intValue
                newPayment.updated_at = json[i]["updated_at"].intValue
                RealmServices.shared.create(newPayment)
                id += 1
            }
        }
        
        if data["fcShoppingCredit"].count > 0 {
            let json = data["fcShoppingCredit"]
            for i in 0 ..< json.count {
                let newPayment = PaymentData()
                newPayment.id = id
                newPayment.dbID = json[i]["id"].intValue
                newPayment.category_id = 2
                newPayment.credit_company = json[i]["credit_company"].stringValue
                newPayment.display_num = json[i]["display_num"].intValue
                newPayment.status = json[i]["status"].intValue
                newPayment.created_at = json[i]["created_at"].intValue
                newPayment.updated_at = json[i]["updated_at"].intValue
                RealmServices.shared.create(newPayment)
                id += 1
            }
        }
        
        if data["fcMoney"].count > 0 {
            let json = data["fcMoney"]
            for i in 0 ..< json.count {
                let newPayment = PaymentData()
                newPayment.id = id
                newPayment.dbID = json[i]["id"].intValue
                newPayment.category_id = 3
                newPayment.credit_company = json[i]["credit_company"].stringValue
                newPayment.display_num = json[i]["display_num"].intValue
                newPayment.status = json[i]["status"].intValue
                newPayment.created_at = json[i]["created_at"].intValue
                newPayment.updated_at = json[i]["updated_at"].intValue
                RealmServices.shared.create(newPayment)
                id += 1
            }
        }
    }
}
